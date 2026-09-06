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
    const svScope scope = svGetScopeFromName("TOP.riscv.U_ControlUnit");
    assert(scope);
    svSetScope(scope);
    return static_cast<word_t>(DPI_getPC());
}

sim::PipelinePerformanceCounters sim::getPipelinePerformanceCounters() {
    const svScope scope = svGetScopeFromName("TOP.riscv.U_ControlUnit");
    assert(scope);
    svSetScope(scope);
    return {
        static_cast<uint32_t>(DPI_getIfWaitCycles()),
        static_cast<uint32_t>(DPI_getLoadHazardCycles()),
        static_cast<uint32_t>(DPI_getMemWaitCycles()),
        static_cast<uint32_t>(DPI_getRedirectCount())
    };
}

void sim::displayPipelinePerformanceCounters() {
    const auto counters {getPipelinePerformanceCounters()};
    std::cout << "Pipeline stalls: instruction="
              << counters.instructionWaitCycles
              << ", load-hazard=" << counters.loadHazardCycles
              << ", data-memory=" << counters.memoryWaitCycles
              << ", redirects=" << counters.redirectCount << std::endl;
}

int instFetch(int addr) {
    return instRead(addr);
}
