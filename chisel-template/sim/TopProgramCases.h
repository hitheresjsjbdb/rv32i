#pragma once

#include "TopTestFramework.h"

namespace top_test::cases {

inline ProgramSpec fibonacci10() {
    using namespace isa;

    return ProgramSpec{
        .name = "fib10",
        .instructions = {
            addi(1, 0, 0),
            addi(2, 0, 1),
            addi(3, 0, 10),
            addi(4, 0, 0),
            beq(4, 3, 24),
            add(5, 1, 2),
            add(1, 2, 0),
            add(2, 5, 0),
            addi(4, 4, 1),
            beq(0, 0, -20),
            sw(1, 0, 0),
            lw(6, 0, 0),
            beq(6, 1, 8),
            beq(0, 0, 0),
            beq(6, 1, 0),
        },
        .haltPc = 56,
        .expectedRs1 = 55,
        .expectedRs2 = 55,
        .maxCycles = 200,
    };
}

}  // namespace top_test::cases