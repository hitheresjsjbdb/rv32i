#include "cpu/init.h"
#include "sdb/sdb.h"
#include "run/run.h"

int main() {
    sim::waveInit("wave.vcd");
    init();
    sdbLoop();
    sim::end();
}