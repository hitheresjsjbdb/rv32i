error id: file://<WORKSPACE>/src/main/scala/rv32I/Controller.scala:
file://<WORKSPACE>/src/main/scala/rv32I/Controller.scala
empty definition using pc, found symbol in pc: 
empty definition using semanticdb
empty definition using fallback
non-local guesses:
	 -chisel3/io/bundleAluControl/ctrlSigned.
	 -chisel3/io/bundleAluControl/ctrlSigned#
	 -chisel3/io/bundleAluControl/ctrlSigned().
	 -chisel3/util/io/bundleAluControl/ctrlSigned.
	 -chisel3/util/io/bundleAluControl/ctrlSigned#
	 -chisel3/util/io/bundleAluControl/ctrlSigned().
	 -utils/io/bundleAluControl/ctrlSigned.
	 -utils/io/bundleAluControl/ctrlSigned#
	 -utils/io/bundleAluControl/ctrlSigned().
	 -io/bundleAluControl/ctrlSigned.
	 -io/bundleAluControl/ctrlSigned#
	 -io/bundleAluControl/ctrlSigned().
	 -scala/Predef.io.bundleAluControl.ctrlSigned.
	 -scala/Predef.io.bundleAluControl.ctrlSigned#
	 -scala/Predef.io.bundleAluControl.ctrlSigned().
offset: 668
uri: file://<WORKSPACE>/src/main/scala/rv32I/Controller.scala
text:
```scala
package rv32I

import chisel3._
import chisel3.util._

import utils._

class ControllerIO extends Bundle {
    val bundleControlIn = Flipped(new BundleControl()) // 来自译码器
    val bundleAluControl = Flipped(new BundleAluControl())  // 到ALU
    val bundleMemDataControl = Flipped(new BundleMemDataControl())  // 到数据内存
    val bundleControlOut = new BundleControl()  // 到其他
}

class Controller extends Module {
    val io = IO(new ControllerIO)

    // alu
    io.bundleAluControl.ctrlALUSrc := io.bundleControlIn.ctrlALUSrc
    io.bundleAluControl.ctrlJAL := io.bundleControlIn.ctrlJAL
    io.bundleAluControl.ctrlOP := io.bundleControlIn.ctrlOP
    io.bundleAluControl.@@ctrlSigned := io.bundleControlIn.ctrlSigned
    io.bundleAluControl.ctrlBranch := io.bundleControlIn.ctrlBranch

    // 内存单元
    io.bundleMemDataControl.ctrlLSType := io.bundleControlIn.ctrlALUSrc
    io.bundleMemDataControl.ctrlLoad := io.bundleControlIn.ctrlLoad
    io.bundleMemDataControl.ctrlSigned := io.bundleControlIn.ctrlSigned
    io.bundleMemDataControl.ctrlStore := io.bundleControlIn.ctrlStore
    
    // 其他
    io.bundleControlOut <> io.bundleControlIn
}
```


#### Short summary: 

empty definition using pc, found symbol in pc: 