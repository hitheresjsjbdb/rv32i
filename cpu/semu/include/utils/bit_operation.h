#pragma once

#include <common.h>

using BitState = enum class Bit {
    RESET = 0, SET
};

inline void setBit(word_t& num, size_t bit, BitState value) {
    assert(bit < sizeof(word_t) * 8);
    word_t mask {1U << bit};
    num = value == Bit::SET ? num | mask : num & ~mask;
}

inline word_t bitMask(word_t num, size_t hBit, size_t lBit) {
    assert(hBit < 32);
    assert(lBit < 32);
    assert(hBit >= lBit);
    size_t length {hBit - lBit + 1U};
    word_t mask {((1U << length) - 1U) << lBit};
    return (num & mask) >> lBit;
}

template<size_t length>
inline word_t signExt(word_t num) {
    struct { sword_t _num : length; } _num;
    _num._num = num;
    return _num._num;
}
