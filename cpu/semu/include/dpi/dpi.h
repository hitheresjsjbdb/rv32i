#pragma once

#include <common.h>
#include "Vriscv__Dpi.h"
#include "svdpi.h"

namespace sim {

    word_t getReg(size_t idx);
    word_t getPC();

}

