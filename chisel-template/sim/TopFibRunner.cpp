#include <verilated.h>

#include <cstdlib>
#include <iostream>
#include <string>

#include "TopProgramCases.h"
#include "TopTestFramework.h"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);

    const std::string wavePath = argc >= 2 ? argv[1] : "build/verilator/Top/top.vcd";
    const auto spec = top_test::cases::fibonacci10();

    top_test::TopSimulator simulator(wavePath);
    const auto summary = simulator.run(spec);

    simulator.printSummary(spec, summary);

    if (!summary.success) {
        std::cerr << "expected rs1=" << spec.expectedRs1
                  << " rs2=" << spec.expectedRs2 << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}