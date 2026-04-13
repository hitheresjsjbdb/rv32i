#include "diff/diff.h"
#include "semu/semu.h"
#include "cpu/reg.h"
#include "cpu/cpu.h"
#include "dpi/dpi.h"

extern CPU cpu;

static bool checkReg() {
    bool success {true};
    for (int i {}; i < 32; i++) {
        word_t dutReg = sim::getReg(i);
        if (dutReg != R(i)) {
            printf("Reg check failed: DUT's reg[%d] = %d, while SEMU's reg[%d] = %d\n", i, dutReg, i, R(i));
            success = false;
        }
    }
    return success;
}

static bool checkPC() {
    word_t dutPC = sim::getPC();
    if (cpu.pc != dutPC) {
        printf("PC check failed: DUT's pc = %d, while SEMU's pc = %d\n", dutPC, cpu.pc);
        return false;
    }
    return true;
}

bool diffTest() {
    bool pcPass = checkPC();
    bool regPass = checkReg();
    return pcPass && regPass;
}
