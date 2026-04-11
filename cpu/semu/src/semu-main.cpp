#include "cpu/init.h"
#include "semu/semu.h"
#include "cpu/reg.h"

#include "exec/exec.h"


int main() {
    init();
    while (true) {
        char opt {};
        std::cout << "(semu) ";
        std::cin >> opt;
        if(opt == 's') semuLoop(1);
        if(opt == 'r') displayRegs();
        if(opt == 'q') return 0;
        if(opt == 'c') semuLoop(-1);
    }
    semuLoop(-1);
    displayRegs();
}