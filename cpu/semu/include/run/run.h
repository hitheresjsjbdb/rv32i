#pragma once

#include <common.h>

namespace sim {
    void waveInit(std::string wavePath);
    void tick();
    void reset();
    bool exec();
    void end();
}