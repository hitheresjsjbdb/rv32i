#include "cpu/init.h"
#include "isa/decoder.h"
#include "cpu/reg.h"
#include "cpu/cpu.h"
#include "mem/mem.h"
#include "semu/semu.h"
#include "exec/exec.h"
#include "run/run.h"
#include "bus/wishbone.h"

extern CPU cpu;
extern SemuStatus semuStatus;

void init() {
    instParsing();
    initCapstone();
    sim::resetWishboneDiff();
    sim::reset();
    cpu.pc = instMemAddrOffset;
    R(0) = 0;
    semuStatus.state = SEMU::READY;
    semuStatus.numOfInst = 0;
    semuStatus.numOfCycle = 0;
}
