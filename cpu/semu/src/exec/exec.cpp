#include "cpu/cpu.h"
#include "isa/decoder.h"
#include "exec/exec.h"
#include "semu/semu.h"

extern CPU cpu;
extern SemuStatus semuStatus;

inline bool decodeAndExec(word_t inst) {
    return instMatch(inst);
}

bool cpuExecOnce() {
    instFetch();
    if (!decodeAndExec(cpu.inst)) return false;
    pcUpdate();
    return true;
}

bool cpuExec(uint32_t n) {
    assert(n != 0);
    for (uint32_t i {}; i < n; i++) {
        bool success = cpuExecOnce();
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
