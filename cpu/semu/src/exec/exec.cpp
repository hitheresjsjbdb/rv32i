#include "cpu/cpu.h"
#include "isa/decoder.h"
#include "exec/exec.h"
#include "semu/semu.h"
#include "mem/mem.h"
#include "run/run.h"
#include "diff/diff.h"
#include <capstone/capstone.h>

extern CPU cpu;
extern SemuStatus semuStatus;
csh handle;

inline bool decodeAndExec(word_t inst) {
    return instMatch(inst);
}

void initCapstone() {
    auto err = cs_open(CS_ARCH_RISCV, CS_MODE_RISCV32, &handle);
    if (err != CS_ERR_OK) {
        printf("Failed to initialize capstone: %s\n", cs_strerror(err));
        exit(EXIT_FAILURE);
    }
}

void displayInst(word_t pc) {
    cs_insn* insn;
    word_t inst = instRead(pc);
    size_t count = cs_disasm(handle, reinterpret_cast<uint8_t*>(&inst), 4, pc, 1, &insn);
    assert(count > 0);
    printf("0x%08lx:\t%s\t%s\n", insn->address, insn->mnemonic, insn->op_str);
}

bool cpuExecOnce(bool flag) {
    instFetch();
    if (!decodeAndExec(cpu.inst)) return false;
    if (flag) displayInst(cpu.pc);
    pcUpdate();
    return true;
}

bool cpuExec(uint32_t n) {
    assert(n != 0);
    for (uint32_t i {}; i < n; i++) {
        sim::exec();
        bool success = cpuExecOnce(n <= 10);
        bool pass = diffTest();
        if (pass == false) {
            semuStatus.state = SEMU::HALT;
            printf("Error occurrd at pc = 0x%08x\n\n", cpu.previousPc);
            displayInst(cpu.previousPc);
            printf("\n");
            return false;
        }
        if (success == false) {
            semuStatus.state = SEMU::HALT;
            std::cout << "Unsupported instruction: ";
            std::cout << "0x" << std::hex << std::setw(8) << std::setfill('0') << cpu.inst;
            std::cout << " at pc = " << std::hex << std::setw(8) << std::setfill('0') << cpu.pc << std::endl;
                return false;   // terminated with error(s)
            }
        semuStatus.numOfInst++;
        if (semuStatus.state != SEMU::RUN) return success;  // terminated successfully
    }
    return true;
}
