#pragma once

#include <common.h>

struct CPU {
    word_t pc;
    word_t snpc;
    word_t dnpc;
    word_t inst;
};

void instFetch();

void pcUpdate();

