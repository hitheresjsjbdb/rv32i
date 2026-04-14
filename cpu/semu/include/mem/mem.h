#pragma once

#include <common.h>

constexpr word_t dataMemAddrOffset {0U};
constexpr word_t instMemAddrOffset {0x0000'2000U};

word_t memRead(size_t addr, size_t length);
void memWrite(size_t addr, word_t data, size_t length);
word_t instRead(size_t addr);
bool loadMemFromHex(char * filename);