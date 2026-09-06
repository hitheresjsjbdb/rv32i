#include "run/run.h"
#include "semu/semu.h"
#include <verilated.h>
#include "verilated_vcd_c.h"
#include <memory>
#include "Vriscv.h"
#include "bus/wishbone.h"

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
    semuStatus.numOfCycle++;;
}

void sim::reset() {
    dut->iwb_dat_i = 0;
    dut->iwb_ack_i = 0;
    dut->iwb_err_i = 0;
    dut->dwb_dat_i = 0;
    dut->dwb_ack_i = 0;
    dut->dwb_err_i = 0;
    dut->rst = 0;
    tick();
    dut->rst = 1;
    tick();
    dut->rst = 0;
    tick();
}

bool sim::exec() {
    int i {};
    for (int i {}; ; i++) {
        tick();
        if (!wishboneDiffPassed()) {
            std::cout << "Wishbone difftest failed" << std::endl;
            return false;
        }
        if (dut->done) break;
        if (i > 64) {
            std::cout << "DUT failed to execute" << std::endl;
            return false;
        }
    }
    return true;
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
