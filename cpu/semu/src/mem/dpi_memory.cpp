#include "mem/mem.h"

// DPI hook used by IM when DIFFTEST is enabled.  The RTL now accesses the
// instruction image directly; this function is intentionally independent of
// any bus protocol.
extern "C" unsigned long long instructionMemoryRead(int addr) {
    const word_t lineAddress {static_cast<word_t>(addr) & ~word_t {0x7U}};
    const unsigned long long low {instRead(lineAddress)};
    const unsigned long long high {instRead(lineAddress + 4U)};
    return low | (high << 32U);
}
