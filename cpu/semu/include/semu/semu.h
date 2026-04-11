#pragma once

#include <common.h>

using State = enum class SEMU {
    READY, RUN, STOP, HALT
};

struct SemuStatus {
    State state;
    uint32_t numOfInst;
};

void semuLoop(uint32_t n);