#include "semu/semu.h"
#include "exec/exec.h"

SemuStatus semuStatus {};


void semuLoop(uint32_t n) {
    semuStatus.state = SEMU::RUN;
    bool success = cpuExec(n);
    if (semuStatus.state == SEMU::HALT && success == true) {
        std::cout << "SEMU terminated successfully" << std::endl;
        std::cout << semuStatus.numOfInst << " instruction(s) were executed" << std::endl;
    }
    else if (semuStatus.state == SEMU::HALT && success == false) {
        std::cout << "SEMU terminated with errors" << std::endl;
        std::cout << semuStatus.numOfInst << " instruction(s) were executed" << std::endl;
    }
}


