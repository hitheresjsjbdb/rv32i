#include "cpu/init.h"
#include "sdb/sdb.h"
#include "run/run.h"
#include "mem/mem.h"

int main(int argc, char *argv[]) {
    if (argc > 1) loadMemFromHex(argv[1]);
    sim::waveInit("wave.vcd");
    init();
    sdbLoop();
    sim::end();
}