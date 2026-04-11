#include "isa/decoder.h"
#include "isa/rv32.h"
#include "utils/bit_operation.h"
#include "cpu/reg.h"
#include "cpu/cpu.h"
#include "semu/semu.h"
#include "mem/mem.h"

#include <iomanip>

extern CPU cpu;
extern SemuStatus semuStatus;

static size_t rd   {};
static size_t rs1  {};
static size_t rs2  {};
static word_t imm  {}; 
static word_t inst {};

std::vector<Pattern> instPattern {
    { "0000000 ????? ????? 000 ????? 01100 11", Name::ADD,    Type::R, []() { R(rd) = R(rs1) + R(rs2); } },
    { "0100000 ????? ????? 000 ????? 01100 11", Name::SUB,    Type::R, []() { R(rd) = R(rs1) - R(rs2); } },
    { "0000000 ????? ????? 111 ????? 01100 11", Name::AND,    Type::R, []() { R(rd) = R(rs1) & R(rs2); } },
    { "0000000 ????? ????? 110 ????? 01100 11", Name::SUB,    Type::R, []() { R(rd) = R(rs1) | R(rs2); } },
    { "0000000 ????? ????? 001 ????? 00100 11", Name::SLL,    Type::R, []() { R(rd) = R(rs1) << (R(rs2) & 0x1f); } },
    { "0000000 ????? ????? 101 ????? 00100 11", Name::SRL,    Type::R, []() { R(rd) = R(rs1) >> (R(rs2) & 0x1f); } },
    { "0100000 ????? ????? 101 ????? 00100 11", Name::SRA,    Type::R, []() { R(rd) = static_cast<sword_t>(R(rs1)) >> (R(rs2) & 0x1f); } },
    { "0000000 ????? ????? 100 ????? 01100 11", Name::XOR,    Type::R, []() { R(rd) = R(rs1) ^ R(rs2); } },

    { "??????? ????? ????? 110 ????? 00100 11", Name::ORI,    Type::I, []() { R(rd) = R(rs1) | imm; } },
    { "??????? ????? ????? 000 ????? 00100 11", Name::ADDI,   Type::I, []() { R(rd) = R(rs1) + imm; } },
    { "??????? ????? ????? 010 ????? 00000 11", Name::LW,     Type::I, []() { R(rd) = memRead(R(rs1) + imm, 4); } },
    { "??????? ????? ????? 000 ????? 11001 11", Name::JALR,   Type::I, []() { cpu.dnpc = (imm + R(rs1)) & ~0x1U; R(rd) = cpu.snpc; } },
    { "0000000 00001 00000 000 00000 11100 11", Name::EBREAK, Type::I, []() { semuStatus.state = SEMU::HALT; } },

    { "??????? ????? ????? 010 ????? 01000 11", Name::SW,     Type::S, []() { memWrite(imm + R(rs1), R(rs2), 4); } },

    { "??????? ????? ????? 000 ????? 11000 11", Name::BEQ,    Type::B, []() { cpu.dnpc = R(rs1) == R(rs2) ? cpu.pc + imm : cpu.snpc; } },
    { "??????? ????? ????? 001 ????? 11000 11", Name::BNE,    Type::B, []() { cpu.dnpc = R(rs1) != R(rs2) ? cpu.pc + imm : cpu.snpc; } },

    { "??????? ????? ????? ??? ????? 11011 11", Name::JAL,    Type::J, []() { cpu.dnpc = cpu.pc + imm; R(rd) = cpu.snpc; } },
};

inline void getRd() {
    rd  = bitMask(inst, 11, 7);
}

inline void getRs1() {
    rs1 = bitMask(inst, 19, 15);
}

inline void getRs2() {
    rs2 = bitMask(inst, 24, 20);
}

inline void getImm(InstType type) {
    switch (type) {
        case Type::I: imm = signExt<12>(bitMask(inst, 31, 20)); break;
        case Type::S: imm = (signExt<7>(bitMask(inst, 31, 25)) << 5) | bitMask(inst, 11, 7); break;
        case Type::B: imm = (signExt<1>(bitMask(inst, 31, 31)) << 12) | (bitMask(inst, 30, 25) << 5) | (bitMask(inst, 11, 8) << 1) | (bitMask(inst, 7, 7) << 11); break;
        case Type::J: imm = (signExt<1>(bitMask(inst, 31, 31)) << 20) | (bitMask(inst, 30, 21) << 1) | (bitMask(inst, 20, 20) << 11) | (bitMask(inst, 19, 12) << 12); break;
        default: break;
    }
}

void getDecodeValue(InstType type) {
    switch (type) {
        case Type::R: getRs1(); getRs2(); getRd();                  break;
        case Type::I: getRs1();           getRd(); getImm(Type::I); break;
        case Type::S: getRs1(); getRs2();          getImm(Type::S); break;
        case Type::B: getRs1(); getRs2();          getImm(Type::B); break;
        case Type::J:                     getRd(); getImm(Type::J); break;
        default: break;
    }
}

bool instMatch(word_t inst) {
    ::inst = inst;
    for (auto &ip : instPattern) {
        if ((::inst & ip.mask) == ip.value) {
            getDecodeValue(ip.type);
            ip.exec();
            R(0) = 0;
            return true;
        }
    }
    return false;
}

void instParsing() {
    for (auto &ip : instPattern) {
        size_t idx {31};
        for (auto &ch : ip.pattern) {
            if (ch == '0') {
                setBit(ip.value, idx, Bit::RESET);
                setBit(ip.mask,  idx, Bit::SET);
                idx--;
            }
            else if (ch == '1') {
                setBit(ip.value, idx, Bit::SET);
                setBit(ip.mask,  idx, Bit::SET);
                idx--;
            }
            else if (ch == '?') {
                setBit(ip.value, idx, Bit::RESET);
                setBit(ip.mask,  idx, Bit::RESET);
                idx--;
            }
        }
    }
}   