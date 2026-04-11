#include "cpu/init.h"
#include "isa/decoder.h"
#include "cpu/reg.h"
#include "cpu/cpu.h"
#include "semu/semu.h"

extern CPU cpu;
extern SemuStatus semuStatus;

void init() {
    instParsing();
    cpu.pc = 0;
    R(0) = 0;
    semuStatus.state = SEMU::READY;
    semuStatus.numOfInst = 0;
}