#include "mem/mem.h"

constexpr word_t dataMemAddrOffset {0U};
constexpr auto dataMemSize {0x8000U};
constexpr auto instMemSize {0x8000U};

static word_t dataMem[dataMemSize] {};

static word_t instMem[instMemSize] {
    0b0000000'00000'00000'000'00001'00100'11,    // addi x1,x0,0    
    0b0000000'00001'00000'000'00010'00100'11,    // addi x2,x0,1    
    0b0000000'01010'00000'000'00011'00100'11,    // addi x3,x0,10   
    0b0000000'00000'00000'000'00100'00100'11,    // addi x4,x0,0

    0b0000000'00011'00100'000'11000'11000'11,    // beq x4,x3,done  
    0b0000000'00010'00001'000'00101'01100'11,    // add x5,x1,x2    
    0b0000000'00000'00010'000'00001'01100'11,    // add x1,x2,x0    
    0b0000000'00000'00101'000'00010'01100'11,    // add x2,x5,x0    
    0b0000000'00001'00100'000'00100'00100'11,    // addi x4,x4,1    
    0b1111111'00000'00000'000'01101'11000'11,    // beq x0,x0,loop  

    0b0000000'00001'00000'010'00000'01000'11,    // sw x1,0(x0)     
    0b0000000'00000'00000'010'00110'00000'11,    // lw x6,0(x0)     
    0b0000000'00001'00110'000'01000'11000'11,    // beq x6,x1,halt  
    0b0000000'00000'00000'000'00000'11000'11,    // beq x0,x0,fail  
    0b0000000'00001'00000'000'00000'11100'11,    // ebreak
};

word_t memRead(size_t addr, size_t length) {
    assert(addr < dataMemAddrOffset + dataMemSize && addr >= dataMemAddrOffset);
    uint8_t *p {reinterpret_cast<uint8_t*>(dataMem)};
    p += (addr - dataMemAddrOffset);
    switch (length) {
        case 1: return *p;
        case 2: return *reinterpret_cast<uint16_t*>(p);
        case 4: return *reinterpret_cast<uint32_t*>(p);
        default: return 0;
    }
}

void memWrite(size_t addr, word_t data, size_t length) {
    assert(addr < dataMemAddrOffset + dataMemSize && addr >= dataMemAddrOffset);
    uint8_t *p {reinterpret_cast<uint8_t*>(dataMem)};
    p += (addr - dataMemAddrOffset);
    switch (length) {
        case 1: *p = data; break;
        case 2: *reinterpret_cast<uint16_t*>(p) = data; break;
        case 4: *reinterpret_cast<uint32_t*>(p) = data; break;
        default: break;
    }
}

word_t instRead(size_t addr) {
    assert(addr < instMemSize);
    uint8_t *p {reinterpret_cast<uint8_t*>(instMem)};
    p += addr;
    return *reinterpret_cast<word_t*>(p);
}