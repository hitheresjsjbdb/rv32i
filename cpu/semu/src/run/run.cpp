#include "run/run.h"
#include "semu/semu.h"
#include <verilated.h>
#include "verilated_vcd_c.h"
#include <memory>
#include "Vriscv.h"

extern SemuStatus semuStatus;

auto dut {std::make_unique<Vriscv>()};
auto tfp {std::make_unique<VerilatedVcdC>()};
vluint64_t sim_time = 0;

void sim::waveInit(std::string wavePath) {
    Verilated::traceEverOn(true);
    dut->trace(tfp.get(), 99);
    tfp->open(wavePath.c_str());
}

void sim::tick() {
    dut->clk = 0;
    dut->eval();
    tfp->dump(sim_time);
    sim_time++;
    dut->clk = 1;
    dut->eval();
    tfp->dump(sim_time);
    sim_time++;
    semuStatus.numOfCycle++;
}

void sim::reset() {
    dut->rst = 0;
    tick();
    dut->rst = 1;
    tick();
    dut->rst = 0;
    tick();
}

void sim::exec() {
    int i {};
    for (int i {}; ; i++) {
        tick();
        if (dut->done) break;
        if (i > 10) {
            std::cout << "DUT failed to execute" << std::endl;
            exit(EXIT_FAILURE);
        }
    }
    tick();
}

void sim::end() {
    static bool isCleanup {false};
    if (!isCleanup) {
        isCleanup = true;
        tfp->close();
        tfp.reset();
        dut.reset();
    }
}
