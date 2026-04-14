#include <stdint.h>
#include <stdio.h>
#include <capstone/capstone.h>
#include <iostream>
#include <string>
#include <fstream>
#include <assert.h>

constexpr size_t instMemSize {1024U};

csh handle;
uint32_t instMem[instMemSize] {};
size_t size {};

void initCapstone() {
    auto err = cs_open(CS_ARCH_RISCV, CS_MODE_RISCV32, &handle);
    if (err != CS_ERR_OK) {
        printf("Failed to initialize capstone: %s\n", cs_strerror(err));
        exit(EXIT_FAILURE);
    }
}

void displayInst(uint32_t pc) {
    cs_insn* insn;
    uint32_t inst = instMem[pc/4];
    size_t count = cs_disasm(handle, reinterpret_cast<uint8_t*>(&inst), 4, pc, 1, &insn);
    assert(count > 0);
    printf("0x%08lx:\t%s\t%s\n", insn->address, insn->mnemonic, insn->op_str);
}

bool loadMemFromHex(char * filename) {
    std::ifstream file(filename);
    if (!file.is_open()) {
        std::cout << "Failed to open " << filename << std::endl;
        return false;
    }
    std::string line;
    for (size; std::getline(file, line); size++) {
        if (size > instMemSize) return false;
        instMem[size] = std::stoul(line, nullptr, 16);
    }
    return true;
}

int main(int argc, char *argv[]) {
    initCapstone();
    if (argc > 1) loadMemFromHex(argv[1]);
    for (size_t pc {}; pc < size * 4; pc+=4) {
        displayInst(pc);
    }
}