#include "sdb/sdb.h"
#include "semu/semu.h"
#include "cpu/reg.h"
#include "run/run.h"

#include <readline/readline.h>
#include <readline/history.h>

static bool running {true};

void cmd_help(std::vector<std::string>&);
void cmd_q(std::vector<std::string>&);
void cmd_c(std::vector<std::string>&);
void cmd_si(std::vector<std::string>&);
void cmd_r(std::vector<std::string>&);

std::vector<Command> commands {
    { "help", "Display information about all supported commands", cmd_help },
    { "q",    "Exit sdb",                                         cmd_q    },
    { "c",    "Continue the execution of the program",            cmd_c    },
    { "si",   "Single-step execution, execute N steps",           cmd_si   },
    { "r" ,   "Display all resgisters",                           cmd_r    },
};

static std::string getReadline() {
    static char *line_read = NULL;

    if (line_read) {
        free(line_read);
        line_read = NULL;
    }

    line_read = readline("(sdb) ");

    if (line_read && *line_read) {
        add_history(line_read);
    }

    return std::string(line_read);
}

std::vector<std::string> split(const std::string& str) {
    std::istringstream iss(str);
    std::vector<std::string> result;
    std::string word;

    while (iss >> word) {
        result.push_back(word);
    }
    return result;
}

void commandMatch(std::vector<std::string> &args) {
    for (auto &cmd : commands) {
        if (cmd.name == args.at(0)) {
            cmd.handler(args);
            return;
        }
    }
    std::cout << "Unknown command: " << args.at(0) << std::endl;
}

void sdbLoop() {
    while (running) {
        auto str = getReadline();
        auto args = split(str);
        if (args.size() >= 1) commandMatch(args);
    }
}


void cmd_help(std::vector<std::string> &args) {
    if (args.size() == 1) {
        for (auto &cmd : commands) {
            std::cout << cmd.name << "\t - \t" << cmd.description << std::endl;
        }
    }
    else {
        for (auto &cmd : commands) {
            if (args.at(1) == cmd.name) {
                std::cout << cmd.name << "\t - \t" << cmd.description << std::endl;
                return;
            }
        }
        std::cout << "Unsupported command: " << args.at(1) << std::endl;
    }       
}

void cmd_q(std::vector<std::string>& args) {
    (void) args;
    running = false;
}

void cmd_c(std::vector<std::string>& args) {
    (void) args;
    semuLoop(-1);
}

void cmd_si(std::vector<std::string>& args) {
    if (args.size() > 1) {
        uint32_t n {};
        try {
            n = static_cast<uint32_t>(std::stoi(args.at(1)));
        } catch (const std::invalid_argument& e) {
            std::cout << args.at(1) << " is not a number" << std::endl;
            return;
        } catch (const std::out_of_range& e) {
            std::cout << "Number " << args.at(1) << " is out of range" << std::endl;
            return;
        }
        semuLoop(n);
    }
    else semuLoop(1);
}

void cmd_r(std::vector<std::string>& args) {
    (void) args;
    displayRegs();
}
