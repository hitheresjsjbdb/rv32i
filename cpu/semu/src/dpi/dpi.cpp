#include "dpi/dpi.h"
#include "mem/mem.h"

word_t sim::getReg(size_t idx) {
    const svScope scope = svGetScopeFromName("TOP.riscv.U_RF");
    assert(scope);
    svSetScope(scope);
    assert(idx < 32);
    return static_cast<word_t>(DPI_getReg(idx));
}

word_t sim::getPC() {
    const svScope scope = svGetScopeFromName("TOP.riscv");
    assert(scope);
    svSetScope(scope);
    return static_cast<word_t>(DPI_getPC());
}

int instFetch(int addr) {
    return instRead(addr);
}