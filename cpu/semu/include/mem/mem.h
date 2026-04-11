#pragma once

#include <common.h>

word_t memRead(size_t addr, size_t length);
void memWrite(size_t addr, word_t data, size_t length);
word_t instRead(size_t addr);