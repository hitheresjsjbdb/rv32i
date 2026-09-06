#pragma once

#include <common.h>
#include "Vriscv__Dpi.h"
#include "svdpi.h"

namespace sim {

    struct PipelinePerformanceCounters {
        uint32_t instructionWaitCycles;
        uint32_t loadHazardCycles;
        uint32_t memoryWaitCycles;
        uint32_t redirectCount;
    };

    word_t getReg(size_t idx);
    word_t getPC();
    PipelinePerformanceCounters getPipelinePerformanceCounters();
    void displayPipelinePerformanceCounters();

}
