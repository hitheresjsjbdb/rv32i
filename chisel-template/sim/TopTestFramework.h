#pragma once

#include <verilated.h>
#include <verilated_vcd_c.h>

#include <cstdint>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

#include "VTop.h"

namespace top_test {

struct ProgramSpec {
    std::string name;
    std::vector<uint32_t> instructions;
    uint32_t haltPc = 0;
    uint32_t expectedRs1 = 0;
    uint32_t expectedRs2 = 0;
    int maxCycles = 200;
};

struct RunSummary {
    bool success = false;
    int cycles = 0;
    uint32_t pc = 0;
    uint32_t inst = 0;
    uint32_t rs1 = 0;
    uint32_t rs2 = 0;
    uint32_t result = 0;
    bool branch = false;
};

namespace isa {

inline uint32_t maskSignedImmediate(int32_t value, int width) {
    const uint32_t mask = width == 32 ? 0xffffffffu : ((1u << width) - 1u);
    return static_cast<uint32_t>(value) & mask;
}

inline uint32_t encodeR(uint32_t funct7, uint32_t rs2, uint32_t rs1, uint32_t funct3, uint32_t rd, uint32_t opcode) {
    return ((funct7 & 0x7fu) << 25) |
           ((rs2 & 0x1fu) << 20) |
           ((rs1 & 0x1fu) << 15) |
           ((funct3 & 0x7u) << 12) |
           ((rd & 0x1fu) << 7) |
           (opcode & 0x7fu);
}

inline uint32_t encodeI(int32_t imm, uint32_t rs1, uint32_t funct3, uint32_t rd, uint32_t opcode) {
    const uint32_t imm12 = maskSignedImmediate(imm, 12);
    return (imm12 << 20) |
           ((rs1 & 0x1fu) << 15) |
           ((funct3 & 0x7u) << 12) |
           ((rd & 0x1fu) << 7) |
           (opcode & 0x7fu);
}

inline uint32_t encodeS(int32_t imm, uint32_t rs2, uint32_t rs1, uint32_t funct3, uint32_t opcode) {
    const uint32_t imm12 = maskSignedImmediate(imm, 12);
    const uint32_t immHi = (imm12 >> 5) & 0x7fu;
    const uint32_t immLo = imm12 & 0x1fu;
    return (immHi << 25) |
           ((rs2 & 0x1fu) << 20) |
           ((rs1 & 0x1fu) << 15) |
           ((funct3 & 0x7u) << 12) |
           (immLo << 7) |
           (opcode & 0x7fu);
}

inline uint32_t encodeB(int32_t offset, uint32_t rs2, uint32_t rs1, uint32_t funct3, uint32_t opcode) {
    if ((offset & 1) != 0) {
        throw std::runtime_error("B-type offset must be 2-byte aligned");
    }

    const uint32_t imm13 = maskSignedImmediate(offset, 13);
    const uint32_t bit12 = (imm13 >> 12) & 0x1u;
    const uint32_t bit11 = (imm13 >> 11) & 0x1u;
    const uint32_t bits10To5 = (imm13 >> 5) & 0x3fu;
    const uint32_t bits4To1 = (imm13 >> 1) & 0xfu;

    return (bit12 << 31) |
           (bits10To5 << 25) |
           ((rs2 & 0x1fu) << 20) |
           ((rs1 & 0x1fu) << 15) |
           ((funct3 & 0x7u) << 12) |
           (bits4To1 << 8) |
           (bit11 << 7) |
           (opcode & 0x7fu);
}

inline uint32_t add(uint32_t rd, uint32_t rs1, uint32_t rs2) {
    return encodeR(0x00, rs2, rs1, 0x0, rd, 0x33);
}

inline uint32_t addi(uint32_t rd, uint32_t rs1, int32_t imm) {
    return encodeI(imm, rs1, 0x0, rd, 0x13);
}

inline uint32_t lw(uint32_t rd, uint32_t rs1, int32_t imm) {
    return encodeI(imm, rs1, 0x2, rd, 0x03);
}

inline uint32_t sw(uint32_t rs2, uint32_t rs1, int32_t imm) {
    return encodeS(imm, rs2, rs1, 0x2, 0x23);
}

inline uint32_t beq(uint32_t rs1, uint32_t rs2, int32_t offset) {
    return encodeB(offset, rs2, rs1, 0x0, 0x63);
}

}  // namespace isa

class TopSimulator {
  public:
    static constexpr uint32_t kInstBytes = 4;

    explicit TopSimulator(const std::string& wavePath)
        : dut_(std::make_unique<VTop>()), trace_(std::make_unique<VerilatedVcdC>()), wavePath_(wavePath) {
        Verilated::traceEverOn(true);
        dut_->trace(trace_.get(), 99);
        trace_->open(wavePath_.c_str());
    }

    ~TopSimulator() {
        if (trace_ != nullptr) {
            trace_->close();
        }
        if (dut_ != nullptr) {
            dut_->final();
        }
    }

    TopSimulator(const TopSimulator&) = delete;
    TopSimulator& operator=(const TopSimulator&) = delete;

    RunSummary run(const ProgramSpec& spec) {
        loadProgram(spec.instructions);

        for (int cycle = 0; cycle < spec.maxCycles; ++cycle) {
            const bool reachedHalt = (dut_->io_addr == spec.haltPc) && dut_->io_resultBranch;
            if (reachedHalt) {
                RunSummary summary = snapshot();
                summary.success = summary.rs1 == spec.expectedRs1 && summary.rs2 == spec.expectedRs2;
                summary.cycles = cycle;
                return summary;
            }

            tick();
        }

        RunSummary summary = snapshot();
        summary.success = false;
        summary.cycles = spec.maxCycles;
        return summary;
    }

    void printSummary(const ProgramSpec& spec, const RunSummary& summary) const {
        if (summary.success) {
            std::cout << spec.name << " finished successfully" << std::endl;
        } else {
            std::cerr << spec.name << " did not halt as expected" << std::endl;
        }

        std::cout << "cycles=" << summary.cycles
                  << " pc=" << summary.pc
                  << " inst=" << hex32(summary.inst)
                  << " rs1=" << summary.rs1
                  << " rs2=" << summary.rs2
                  << " result=" << summary.result
                  << " branch=" << static_cast<int>(summary.branch)
                  << std::endl;
    }

  private:
    std::unique_ptr<VTop> dut_;
    std::unique_ptr<VerilatedVcdC> trace_;
    std::string wavePath_;
    uint64_t simTime_ = 0;

    void tick() {
        dut_->clock = 0;
        dut_->eval();
        trace_->dump(simTime_++);

        dut_->clock = 1;
        dut_->eval();
        trace_->dump(simTime_++);
    }

    void clearExternalPorts() {
        dut_->io_instWriteEn = 0;
        dut_->io_instWriteAddr = 0;
        dut_->io_instWriteData = 0;
        dut_->io_dataWriteEn = 0;
        dut_->io_dataWriteAddr = 0;
        dut_->io_dataWriteData = 0;
    }

    void loadProgram(const std::vector<uint32_t>& program) {
        dut_->reset = 1;
        clearExternalPorts();
        dut_->eval();
        trace_->dump(simTime_++);

        for (size_t index = 0; index < program.size(); ++index) {
            dut_->io_instWriteEn = 1;
            dut_->io_instWriteAddr = static_cast<uint32_t>(index * kInstBytes);
            dut_->io_instWriteData = program[index];
            tick();
        }

        clearExternalPorts();
        tick();

        dut_->reset = 0;
        dut_->eval();
        trace_->dump(simTime_++);
    }

    RunSummary snapshot() const {
        RunSummary summary;
        summary.pc = dut_->io_addr;
        summary.inst = dut_->io_inst;
        summary.rs1 = dut_->io_rs1;
        summary.rs2 = dut_->io_rs2;
        summary.result = dut_->io_result;
        summary.branch = dut_->io_resultBranch;
        return summary;
    }

    static std::string hex32(uint32_t value) {
        std::ostringstream stream;
        stream << "0x" << std::hex << std::setw(8) << std::setfill('0') << value;
        return stream.str();
    }
};

}  // namespace top_test