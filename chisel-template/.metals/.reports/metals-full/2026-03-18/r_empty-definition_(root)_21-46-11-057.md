error id: file://<WORKSPACE>/src/main/scala/utlis/ImmCode.scala:chisel3/package.fromStringToLiteral#U(+1).
file://<WORKSPACE>/src/main/scala/utlis/ImmCode.scala
empty definition using pc, found symbol in pc: 
found definition using semanticdb; symbol chisel3/package.fromStringToLiteral#U(+1).
empty definition using fallback
non-local guesses:

offset: 163
uri: file://<WORKSPACE>/src/main/scala/utlis/ImmCode.scala
text:
```scala
package utlis

import chisel3._

object IMM_TYPES {
    val IMM_SEL_WIDTH = 3

    val IMM_X = "b000".U(IMM_SEL_WIDTH.W)  // 不使用立即数 / 默认 0
    val IMM_I = "b001".U@@(IMM_SEL_WIDTH.W)  // I-type
    val IMM_S = "b010".U(IMM_SEL_WIDTH.W)  // S-type
    val IMM_B = "b011".U(IMM_SEL_WIDTH.W)  // B-type
    val IMM_J = "b100".U(IMM_SEL_WIDTH.W)  // J-type
}
```


#### Short summary: 

empty definition using pc, found symbol in pc: 