#include "bus/wishbone.h"
#include "mem/mem.h"

#include <array>

namespace {

std::array<word_t, 1024> shadowDataMemory {};
bool diffPassed {true};
uint64_t instructionTransferCount {};
uint64_t dataTransferCount {};

void reportFailure(const char *kind, word_t address,
                   word_t dut, word_t expected) {
    std::fprintf(stderr,
                 "Wishbone %s mismatch at 0x%08x: DUT=0x%08x, expected=0x%08x\n",
                 kind, address, dut, expected);
    diffPassed = false;
}

} // namespace

extern "C" unsigned long long instructionBusRead(int addr) {
    const word_t lineAddress {static_cast<word_t>(addr) & ~word_t {0x7U}};
    const unsigned long long low {instRead(lineAddress)};
    const unsigned long long high {instRead(lineAddress + 4U)};
    return low | (high << 32U);
}

extern "C" void instructionWishboneCheck(int addr, int readData) {
    const word_t address {static_cast<word_t>(addr)};
    const word_t dutData {static_cast<word_t>(readData)};

    if ((address & 0x3U) != 0U) {
        std::fprintf(stderr,
                     "Wishbone instruction address is not aligned: 0x%08x\n",
                     address);
        diffPassed = false;
    }
    else {
        const word_t expected {instRead(address)};
        if (dutData != expected)
            reportFailure("instruction read", address, dutData, expected);
    }
    instructionTransferCount++;
}

extern "C" void dataWishboneCheck(int addr, int writeData, int readData,
                                   unsigned char writeEnable) {
    const word_t address {static_cast<word_t>(addr)};
    const size_t index {(address >> 2U) & 0x3ffU};
    const word_t dutReadData {static_cast<word_t>(readData)};

    if (writeEnable) {
        shadowDataMemory[index] = static_cast<word_t>(writeData);
    }
    else if (dutReadData != shadowDataMemory[index]) {
        reportFailure("data read", address, dutReadData,
                      shadowDataMemory[index]);
    }
    dataTransferCount++;
}

namespace sim {

void resetWishboneDiff() {
    shadowDataMemory = {};
    diffPassed = true;
    instructionTransferCount = 0;
    dataTransferCount = 0;
}

bool wishboneDiffPassed() {
    return diffPassed;
}

void displayWishboneDiffStats() {
    std::cout << "Wishbone difftest: " << instructionTransferCount
              << " instruction transfer(s), " << dataTransferCount
              << " data transfer(s)" << std::endl;
}

} // namespace sim
