#include <common.h>

struct Command {
    std::string name;
    std::string description;
    std::function<void(std::vector<std::string>&)> handler;
};

void sdbLoop();