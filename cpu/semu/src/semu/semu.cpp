#include "semu/semu.h"
#include "exec/exec.h"
#include "run/run.h"

SemuStatus semuStatus {};


void semuLoop(uint32_t n) {
    if (semuStatus.state == SEMU::HALT) {
        std::cout << "Program terminated" << std::endl;
        return;
    }
    semuStatus.state = SEMU::RUN;
    bool success = cpuExec(n);
    if (semuStatus.state == SEMU::HALT && success == true) {
        sim::end();
        std::cout << "SEMU terminated successfully" << std::endl;
        std::cout << semuStatus.numOfInst << " instruction(s) were executed" << std::endl;
        std::cout << "Executed " << semuStatus.numOfCycle << " clock cycle(s)"  << std::endl;
        std::cout << "CPI: " << static_cast<double>(semuStatus.numOfCycle) / static_cast<double>(semuStatus.numOfInst) << std::endl;
    }
    else if (semuStatus.state == SEMU::HALT && success == false) {
        sim::end();
        std::cout << "SEMU terminated with errors" << std::endl;
        std::cout << semuStatus.numOfInst << " instruction(s) were executed" << std::endl;
        std::cout << "Executed " << semuStatus.numOfCycle << " clock cycle(s)"  << std::endl;
        std::cout << "CPI: " << static_cast<double>(semuStatus.numOfCycle) / static_cast<double>(semuStatus.numOfInst) << std::endl;
    }
}


