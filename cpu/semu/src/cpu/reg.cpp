#include "cpu/reg.h"
#include "cpu/cpu.h"

extern CPU cpu;

static word_t regs[32] {};

std::string regName[32] {
    "$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2",
    "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5",
    "a6", "a7", "s2", "s3", "s4", "s5", "s6", "s7",
    "s8", "s9", "s10", "s11", "t3", "t4", "t5", "t6"
};

word_t &R(size_t idx) {
    assert(idx < 32);
    return regs[idx];
}

void displayRegs() {
    std::cout << " index | name | value \t\t index | name | value " << std::endl;
    for (size_t i {}; i < 16; i++) {
        printf("%6ld |%5s | 0x%08x\t%6ld |%5s | 0x%08x\n",
                i, regName[i].c_str(), regs[i],
                i+16, regName[i+16].c_str(), regs[i+16]);
    }
    printf("       |   pc | 0x%08x\n", cpu.pc);
}