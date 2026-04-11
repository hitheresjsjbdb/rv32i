#pragma once

#include <common.h>

using InstName = enum class Name {
    ADD, SUB, AND, OR, SLL, SRL, SRA, XOR,  /* R-type */
    ORI, ADDI, LW, SW, BEQ, BNE, JAL, JALR,
    EBREAK,
};

using InstType = enum class Type {
    R, I, S, B, U, J,
};

struct Pattern {
    std::string pattern;
    InstName name;
    InstType type;
    std::function<void()> exec;
    
    word_t mask {};
    word_t value {};
};