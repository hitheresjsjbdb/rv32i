#include "cpu/cpu.h"
#include "mem/mem.h"

CPU cpu {};

void instFetch() {
    cpu.inst = instRead(cpu.pc);
    cpu.snpc = cpu.pc + 4;
    cpu.dnpc = cpu.snpc;
}

void pcUpdate() {
    cpu.pc = cpu.dnpc;
}
