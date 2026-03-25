error id: file://<WORKSPACE>/src/main/scala/rv32I/ImmGen.scala:
file://<WORKSPACE>/src/main/scala/rv32I/ImmGen.scala
empty definition using pc, found symbol in pc: 
empty definition using semanticdb
empty definition using fallback
non-local guesses:
	 -chisel3/IMM_SEL_WIDTH.
	 -config/Configs.IMM_SEL_WIDTH.
	 -utils/IMM_TYPES.IMM_SEL_WIDTH.
	 -IMM_SEL_WIDTH.
	 -scala/Predef.IMM_SEL_WIDTH.
offset: 186
uri: file://<WORKSPACE>/src/main/scala/rv32I/ImmGen.scala
text:
```scala
package rv32I

import chisel3._
import config.Configs._
import utils.IMM_TYPES._

class ImmGenIO extends Bundle {
    val inst = Input(UInt(INST_WIDTH.W))
    val immSel = Input(UInt(IMM@@_SEL_WIDTH.W))
    val imm = Output(UInt(DATA_WIDTH.W))
}
```


#### Short summary: 

empty definition using pc, found symbol in pc: 