import chisel3.RawModule
import chisel3.stage.ChiselStage

import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Path, Paths}

import scala.collection.mutable.ArrayBuffer
import scala.jdk.CollectionConverters._

object GenerateVerilog extends App {
  private sealed trait LayoutMode {
    def name: String

    def shouldSplit(moduleName: String): Boolean
  }

  private case object AutoLayout extends LayoutMode {
    override val name: String = "auto"

    override def shouldSplit(moduleName: String): Boolean = moduleName == "Top"
  }

  private case object SingleFileLayout extends LayoutMode {
    override val name: String = "single"

    override def shouldSplit(moduleName: String): Boolean = false
  }

  private case object SplitFileLayout extends LayoutMode {
    override val name: String = "split"

    override def shouldSplit(moduleName: String): Boolean = true
  }

  private final case class ModuleEntry(
    canonicalName: String,
    aliases: Seq[String],
    generator: () => RawModule
  )

  private final case class Config(
    targetName: String = "Top",
    targetDir: Option[Path] = None,
    layoutMode: LayoutMode = AutoLayout,
    listOnly: Boolean = false
  )

  private val moduleEntries = Seq(
    ModuleEntry("PCReg", Seq("pcreg"), () => new rv32I.PCReg),
    ModuleEntry("MemInst", Seq("meminst"), () => new rv32I.MemInst),
    ModuleEntry("ImmGen", Seq("immgen"), () => new rv32I.ImmGen),
    ModuleEntry("Decoder", Seq("decoder"), () => new rv32I.Decoder),
    ModuleEntry("Controller", Seq("controller"), () => new rv32I.Controller),
    ModuleEntry("Registers", Seq("registers"), () => new rv32I.Registers),
    ModuleEntry("Alu", Seq("alu", "ALU"), () => new rv32I.Alu),
    ModuleEntry("MemData", Seq("mem", "memdata"), () => new rv32I.MemData),
    ModuleEntry("Top", Seq("top"), () => new rv32I.Top)
  )

  private val modulesByAlias: Map[String, ModuleEntry] =
    moduleEntries.flatMap { entry =>
      (entry.canonicalName +: entry.aliases).map(alias => alias.toLowerCase -> entry)
    }.toMap

  private val ModuleStartPattern = "^\\s*module\\s+([A-Za-z_][A-Za-z0-9_$]*)\\b.*$".r
  private val ModuleEndPattern = "^\\s*endmodule\\b.*$".r

  private val config = parseArgs(args.toSeq)

  if (config.listOnly) {
    printAvailableModules()
  } else if (config.targetName.equalsIgnoreCase("all")) {
    val rootDir = config.targetDir.getOrElse(Paths.get("generated"))
    moduleEntries.foreach { entry =>
      emitModule(entry, rootDir.resolve(entry.canonicalName), config.layoutMode)
    }
  } else {
    val entry = resolveModule(config.targetName)
    val outputDir = config.targetDir.getOrElse(Paths.get("generated", entry.canonicalName))
    emitModule(entry, outputDir, config.layoutMode)
  }

  private def parseArgs(rawArgs: Seq[String]): Config = {
    val listOnly = rawArgs.exists(arg => arg == "--list" || arg == "list")
    val layoutMode = rawArgs.collectFirst(Function.unlift(parseLayoutMode)).getOrElse(AutoLayout)
    val positionalArgs = rawArgs.filterNot(isFlag)

    Config(
      targetName = positionalArgs.headOption.getOrElse("Top"),
      targetDir = positionalArgs.lift(1).map(Paths.get(_)),
      layoutMode = layoutMode,
      listOnly = listOnly
    )
  }

  private def isFlag(arg: String): Boolean = {
    arg == "--list" ||
    arg == "list" ||
    parseLayoutMode(arg).nonEmpty
  }

  private def parseLayoutMode(arg: String): Option[LayoutMode] = {
    arg.toLowerCase match {
      case "auto" | "--auto" => Some(AutoLayout)
      case "single" | "--single" => Some(SingleFileLayout)
      case "split" | "--split" => Some(SplitFileLayout)
      case _ => None
    }
  }

  private def printAvailableModules(): Unit = {
    val names = moduleEntries.map(_.canonicalName).mkString("\n")
    println("Available modules:")
    println(names)
  }

  private def resolveModule(moduleName: String): ModuleEntry = {
    modulesByAlias.getOrElse(
      moduleName.toLowerCase,
      throw new IllegalArgumentException(
        s"Unknown module '$moduleName'. Available modules: ${moduleEntries.map(_.canonicalName).mkString(", ")}"
      )
    )
  }

  private def emitModule(entry: ModuleEntry, targetDir: Path, layoutMode: LayoutMode): Unit = {
    Files.createDirectories(targetDir)
    clearVerilogFiles(targetDir)
    val combinedVerilogPath = targetDir.resolve(s"${entry.canonicalName}.v")

    val emittedVerilog = (new ChiselStage).emitVerilog(
      entry.generator(),
      Array("--target-dir", targetDir.toString)
    )

    if (layoutMode.shouldSplit(entry.canonicalName)) {
      val modules = splitVerilogModules(emittedVerilog)
      modules.foreach { case (moduleName, source) =>
        writeText(targetDir.resolve(s"$moduleName.v"), source)
      }
      Files.deleteIfExists(combinedVerilogPath)
    }

    println(s"Generated ${entry.canonicalName} into ${targetDir.toAbsolutePath} with layout=${layoutMode.name}")
  }

  private def clearVerilogFiles(targetDir: Path): Unit = {
    if (Files.exists(targetDir)) {
      val existingFiles = Files.list(targetDir)
      try {
        existingFiles.iterator().asScala
          .filter(path => Files.isRegularFile(path) && path.getFileName.toString.endsWith(".v"))
          .foreach(Files.delete)
      } finally {
        existingFiles.close()
      }
    }
  }

  private def splitVerilogModules(verilogSource: String): Seq[(String, String)] = {
    val headerLines = ArrayBuffer.empty[String]
    val modules = ArrayBuffer.empty[(String, String)]
    val currentModuleLines = ArrayBuffer.empty[String]

    var currentModuleName: Option[String] = None
    var currentHeader = Vector.empty[String]
    var encounteredFirstModule = false

    verilogSource.linesIterator.foreach { line =>
      currentModuleName match {
        case None =>
          line match {
            case ModuleStartPattern(moduleName) =>
              if (!encounteredFirstModule) {
                currentHeader = headerLines.toVector
                encounteredFirstModule = true
              }
              currentModuleName = Some(moduleName)
              currentModuleLines.clear()
              currentModuleLines += line
            case _ =>
              if (!encounteredFirstModule) {
                headerLines += line
              }
          }
        case Some(moduleName) =>
          currentModuleLines += line
          if (ModuleEndPattern.pattern.matcher(line).matches()) {
            val fileLines =
              if (currentHeader.nonEmpty) currentHeader ++ Vector("") ++ currentModuleLines.toVector
              else currentModuleLines.toVector
            modules += moduleName -> (fileLines.mkString("\n") + "\n")
            currentModuleName = None
          }
      }
    }

    if (currentModuleName.nonEmpty) {
      throw new IllegalStateException("Failed to split Verilog output: unterminated module block")
    }

    modules.toVector
  }

  private def writeText(path: Path, content: String): Unit = {
    Files.write(path, content.getBytes(StandardCharsets.UTF_8))
  }
}