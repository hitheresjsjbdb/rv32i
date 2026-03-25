#include <verilated.h>
#include "VPCReg.h"
#include <iostream>
#include <memory>

static void tick(VPCReg* dut) {
    dut->clock = 0;
    dut->eval();

    dut->clock = 1;
    dut->eval();
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    auto dut = std::make_unique<VPCReg>();

    dut->reset = 1;
    dut->io_ctrlJump = 0;
    dut->io_ctrlBranch = 0;
    dut->io_resultBranch = 0;
    dut->io_addrTarget = 0;
    tick(dut.get());

    dut->reset = 0;

    tick(dut.get());
    std::cout << "pc after 1 tick = 0x" << std::hex << dut->io_addrOut << std::endl;

    tick(dut.get());
    std::cout << "pc after 2 ticks = 0x" << std::hex << dut->io_addrOut << std::endl;

    dut->io_ctrlJump = 1;
    dut->io_addrTarget = 0x100;
    tick(dut.get());

    dut->io_ctrlJump = 0;
    std::cout << "pc after jump = 0x" << std::hex << dut->io_addrOut << std::endl;

    dut->final();
    return 0;
}