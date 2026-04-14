// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "VTop__Syms.h"


VL_ATTR_COLD void VTop___024root__trace_init_sub__TOP__0(VTop___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root__trace_init_sub__TOP__0\n"); );
    // Init
    const int c = vlSymsp->__Vm_baseCode;
    // Body
    tracep->declBit(c+42,"clock", false,-1);
    tracep->declBit(c+43,"reset", false,-1);
    tracep->declBus(c+44,"io_addr", false,-1, 31,0);
    tracep->declBus(c+45,"io_inst", false,-1, 31,0);
    tracep->declBit(c+46,"io_bundleCtrl_ctrlJump", false,-1);
    tracep->declBit(c+47,"io_bundleCtrl_ctrlJAL", false,-1);
    tracep->declBit(c+48,"io_bundleCtrl_ctrlBranch", false,-1);
    tracep->declBit(c+49,"io_bundleCtrl_ctrlRegWrite", false,-1);
    tracep->declBit(c+50,"io_bundleCtrl_ctrlLoad", false,-1);
    tracep->declBit(c+51,"io_bundleCtrl_ctrlStore", false,-1);
    tracep->declBit(c+52,"io_bundleCtrl_ctrlALUSrc", false,-1);
    tracep->declBus(c+53,"io_bundleCtrl_ctrlOP", false,-1, 3,0);
    tracep->declBit(c+54,"io_ctrlBranchToPc", false,-1);
    tracep->declBit(c+55,"io_ctrlJumpToPc", false,-1);
    tracep->declBus(c+56,"io_resultALU", false,-1, 31,0);
    tracep->declBus(c+57,"io_rs1", false,-1, 31,0);
    tracep->declBus(c+58,"io_rs2", false,-1, 31,0);
    tracep->declBus(c+59,"io_imm", false,-1, 31,0);
    tracep->declBit(c+60,"io_resultBranch", false,-1);
    tracep->declBus(c+61,"io_result", false,-1, 31,0);
    tracep->declBit(c+62,"io_instWriteEn", false,-1);
    tracep->declBus(c+63,"io_instWriteAddr", false,-1, 31,0);
    tracep->declBus(c+64,"io_instWriteData", false,-1, 31,0);
    tracep->declBit(c+65,"io_dataWriteEn", false,-1);
    tracep->declBus(c+66,"io_dataWriteAddr", false,-1, 31,0);
    tracep->declBus(c+67,"io_dataWriteData", false,-1, 31,0);
    tracep->pushNamePrefix("Top ");
    tracep->declBit(c+42,"clock", false,-1);
    tracep->declBit(c+43,"reset", false,-1);
    tracep->declBus(c+44,"io_addr", false,-1, 31,0);
    tracep->declBus(c+45,"io_inst", false,-1, 31,0);
    tracep->declBit(c+46,"io_bundleCtrl_ctrlJump", false,-1);
    tracep->declBit(c+47,"io_bundleCtrl_ctrlJAL", false,-1);
    tracep->declBit(c+48,"io_bundleCtrl_ctrlBranch", false,-1);
    tracep->declBit(c+49,"io_bundleCtrl_ctrlRegWrite", false,-1);
    tracep->declBit(c+50,"io_bundleCtrl_ctrlLoad", false,-1);
    tracep->declBit(c+51,"io_bundleCtrl_ctrlStore", false,-1);
    tracep->declBit(c+52,"io_bundleCtrl_ctrlALUSrc", false,-1);
    tracep->declBus(c+53,"io_bundleCtrl_ctrlOP", false,-1, 3,0);
    tracep->declBit(c+48,"io_ctrlBranchToPc", false,-1);
    tracep->declBit(c+46,"io_ctrlJumpToPc", false,-1);
    tracep->declBus(c+56,"io_resultALU", false,-1, 31,0);
    tracep->declBus(c+57,"io_rs1", false,-1, 31,0);
    tracep->declBus(c+58,"io_rs2", false,-1, 31,0);
    tracep->declBus(c+59,"io_imm", false,-1, 31,0);
    tracep->declBit(c+60,"io_resultBranch", false,-1);
    tracep->declBus(c+61,"io_result", false,-1, 31,0);
    tracep->declBit(c+62,"io_instWriteEn", false,-1);
    tracep->declBus(c+63,"io_instWriteAddr", false,-1, 31,0);
    tracep->declBus(c+64,"io_instWriteData", false,-1, 31,0);
    tracep->declBit(c+65,"io_dataWriteEn", false,-1);
    tracep->declBus(c+66,"io_dataWriteAddr", false,-1, 31,0);
    tracep->declBus(c+67,"io_dataWriteData", false,-1, 31,0);
    tracep->declBit(c+42,"pcReg_clock", false,-1);
    tracep->declBit(c+43,"pcReg_reset", false,-1);
    tracep->declBus(c+44,"pcReg_io_addrOut", false,-1, 31,0);
    tracep->declBit(c+46,"pcReg_io_ctrlJump", false,-1);
    tracep->declBit(c+48,"pcReg_io_ctrlBranch", false,-1);
    tracep->declBit(c+60,"pcReg_io_resultBranch", false,-1);
    tracep->declBus(c+61,"pcReg_io_addrTarget", false,-1, 31,0);
    tracep->declBit(c+42,"memInst_clock", false,-1);
    tracep->declBus(c+44,"memInst_io_addr", false,-1, 31,0);
    tracep->declBus(c+45,"memInst_io_inst", false,-1, 31,0);
    tracep->declBit(c+62,"memInst_io_extWriteEn", false,-1);
    tracep->declBus(c+63,"memInst_io_extWriteAddr", false,-1, 31,0);
    tracep->declBus(c+64,"memInst_io_extWriteData", false,-1, 31,0);
    tracep->declBus(c+45,"decoder_io_inst", false,-1, 31,0);
    tracep->declBit(c+46,"decoder_io_bundleCtrl_ctrlJump", false,-1);
    tracep->declBit(c+47,"decoder_io_bundleCtrl_ctrlJAL", false,-1);
    tracep->declBit(c+48,"decoder_io_bundleCtrl_ctrlBranch", false,-1);
    tracep->declBit(c+49,"decoder_io_bundleCtrl_ctrlRegWrite", false,-1);
    tracep->declBit(c+50,"decoder_io_bundleCtrl_ctrlLoad", false,-1);
    tracep->declBit(c+51,"decoder_io_bundleCtrl_ctrlStore", false,-1);
    tracep->declBit(c+52,"decoder_io_bundleCtrl_ctrlALUSrc", false,-1);
    tracep->declBus(c+53,"decoder_io_bundleCtrl_ctrlOP", false,-1, 3,0);
    tracep->declBus(c+68,"decoder_io_bundleReg_rs1", false,-1, 4,0);
    tracep->declBus(c+69,"decoder_io_bundleReg_rs2", false,-1, 4,0);
    tracep->declBus(c+70,"decoder_io_bundleReg_rd", false,-1, 4,0);
    tracep->declBus(c+59,"decoder_io_imm", false,-1, 31,0);
    tracep->declBit(c+42,"registers_clock", false,-1);
    tracep->declBit(c+49,"registers_io_ctrlRegWrite", false,-1);
    tracep->declBus(c+61,"registers_io_dataWrite", false,-1, 31,0);
    tracep->declBus(c+68,"registers_io_bundleReg_rs1", false,-1, 4,0);
    tracep->declBus(c+69,"registers_io_bundleReg_rs2", false,-1, 4,0);
    tracep->declBus(c+70,"registers_io_bundleReg_rd", false,-1, 4,0);
    tracep->declBus(c+57,"registers_io_dataRead1", false,-1, 31,0);
    tracep->declBus(c+58,"registers_io_dataRead2", false,-1, 31,0);
    tracep->declBit(c+46,"registers_io_ctrlJump", false,-1);
    tracep->declBus(c+44,"registers_io_pc", false,-1, 31,0);
    tracep->declBit(c+52,"alu_io_bundleAluControl_ctrlALUSrc", false,-1);
    tracep->declBit(c+46,"alu_io_bundleAluControl_ctrlJump", false,-1);
    tracep->declBit(c+47,"alu_io_bundleAluControl_ctrlJAL", false,-1);
    tracep->declBus(c+53,"alu_io_bundleAluControl_ctrlOP", false,-1, 3,0);
    tracep->declBus(c+57,"alu_io_dataRead1", false,-1, 31,0);
    tracep->declBus(c+58,"alu_io_dataRead2", false,-1, 31,0);
    tracep->declBus(c+59,"alu_io_imm", false,-1, 31,0);
    tracep->declBus(c+44,"alu_io_pc", false,-1, 31,0);
    tracep->declBit(c+60,"alu_io_resultBranch", false,-1);
    tracep->declBus(c+56,"alu_io_resultAlu", false,-1, 31,0);
    tracep->declBit(c+42,"memData_clock", false,-1);
    tracep->declBit(c+50,"memData_io_bundleMemDataControl_ctrlLoad", false,-1);
    tracep->declBit(c+51,"memData_io_bundleMemDataControl_ctrlStore", false,-1);
    tracep->declBus(c+56,"memData_io_resultALU", false,-1, 31,0);
    tracep->declBus(c+58,"memData_io_dataStore", false,-1, 31,0);
    tracep->declBus(c+61,"memData_io_result", false,-1, 31,0);
    tracep->declBit(c+65,"memData_io_extWriteEn", false,-1);
    tracep->declBus(c+66,"memData_io_extWriteAddr", false,-1, 31,0);
    tracep->declBus(c+67,"memData_io_extWriteData", false,-1, 31,0);
    tracep->declBit(c+46,"controller_io_bundleControlIn_ctrlJump", false,-1);
    tracep->declBit(c+47,"controller_io_bundleControlIn_ctrlJAL", false,-1);
    tracep->declBit(c+48,"controller_io_bundleControlIn_ctrlBranch", false,-1);
    tracep->declBit(c+49,"controller_io_bundleControlIn_ctrlRegWrite", false,-1);
    tracep->declBit(c+50,"controller_io_bundleControlIn_ctrlLoad", false,-1);
    tracep->declBit(c+51,"controller_io_bundleControlIn_ctrlStore", false,-1);
    tracep->declBit(c+52,"controller_io_bundleControlIn_ctrlALUSrc", false,-1);
    tracep->declBus(c+53,"controller_io_bundleControlIn_ctrlOP", false,-1, 3,0);
    tracep->declBit(c+52,"controller_io_bundleAluControl_ctrlALUSrc", false,-1);
    tracep->declBit(c+46,"controller_io_bundleAluControl_ctrlJump", false,-1);
    tracep->declBit(c+47,"controller_io_bundleAluControl_ctrlJAL", false,-1);
    tracep->declBus(c+53,"controller_io_bundleAluControl_ctrlOP", false,-1, 3,0);
    tracep->declBit(c+50,"controller_io_bundleMemDataControl_ctrlLoad", false,-1);
    tracep->declBit(c+51,"controller_io_bundleMemDataControl_ctrlStore", false,-1);
    tracep->declBit(c+46,"controller_io_bundleControlOut_ctrlJump", false,-1);
    tracep->declBit(c+48,"controller_io_bundleControlOut_ctrlBranch", false,-1);
    tracep->declBit(c+49,"controller_io_bundleControlOut_ctrlRegWrite", false,-1);
    tracep->pushNamePrefix("alu ");
    tracep->declBit(c+52,"io_bundleAluControl_ctrlALUSrc", false,-1);
    tracep->declBit(c+46,"io_bundleAluControl_ctrlJump", false,-1);
    tracep->declBit(c+47,"io_bundleAluControl_ctrlJAL", false,-1);
    tracep->declBus(c+53,"io_bundleAluControl_ctrlOP", false,-1, 3,0);
    tracep->declBus(c+57,"io_dataRead1", false,-1, 31,0);
    tracep->declBus(c+58,"io_dataRead2", false,-1, 31,0);
    tracep->declBus(c+59,"io_imm", false,-1, 31,0);
    tracep->declBus(c+44,"io_pc", false,-1, 31,0);
    tracep->declBit(c+60,"io_resultBranch", false,-1);
    tracep->declBus(c+56,"io_resultAlu", false,-1, 31,0);
    tracep->declBus(c+1,"operand1", false,-1, 31,0);
    tracep->declBus(c+2,"operand2", false,-1, 31,0);
    tracep->declBus(c+3,"addResult", false,-1, 31,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("controller ");
    tracep->declBit(c+46,"io_bundleControlIn_ctrlJump", false,-1);
    tracep->declBit(c+47,"io_bundleControlIn_ctrlJAL", false,-1);
    tracep->declBit(c+48,"io_bundleControlIn_ctrlBranch", false,-1);
    tracep->declBit(c+49,"io_bundleControlIn_ctrlRegWrite", false,-1);
    tracep->declBit(c+50,"io_bundleControlIn_ctrlLoad", false,-1);
    tracep->declBit(c+51,"io_bundleControlIn_ctrlStore", false,-1);
    tracep->declBit(c+52,"io_bundleControlIn_ctrlALUSrc", false,-1);
    tracep->declBus(c+53,"io_bundleControlIn_ctrlOP", false,-1, 3,0);
    tracep->declBit(c+52,"io_bundleAluControl_ctrlALUSrc", false,-1);
    tracep->declBit(c+46,"io_bundleAluControl_ctrlJump", false,-1);
    tracep->declBit(c+47,"io_bundleAluControl_ctrlJAL", false,-1);
    tracep->declBus(c+53,"io_bundleAluControl_ctrlOP", false,-1, 3,0);
    tracep->declBit(c+50,"io_bundleMemDataControl_ctrlLoad", false,-1);
    tracep->declBit(c+51,"io_bundleMemDataControl_ctrlStore", false,-1);
    tracep->declBit(c+46,"io_bundleControlOut_ctrlJump", false,-1);
    tracep->declBit(c+48,"io_bundleControlOut_ctrlBranch", false,-1);
    tracep->declBit(c+49,"io_bundleControlOut_ctrlRegWrite", false,-1);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("decoder ");
    tracep->declBus(c+45,"io_inst", false,-1, 31,0);
    tracep->declBit(c+46,"io_bundleCtrl_ctrlJump", false,-1);
    tracep->declBit(c+47,"io_bundleCtrl_ctrlJAL", false,-1);
    tracep->declBit(c+48,"io_bundleCtrl_ctrlBranch", false,-1);
    tracep->declBit(c+49,"io_bundleCtrl_ctrlRegWrite", false,-1);
    tracep->declBit(c+50,"io_bundleCtrl_ctrlLoad", false,-1);
    tracep->declBit(c+51,"io_bundleCtrl_ctrlStore", false,-1);
    tracep->declBit(c+52,"io_bundleCtrl_ctrlALUSrc", false,-1);
    tracep->declBus(c+53,"io_bundleCtrl_ctrlOP", false,-1, 3,0);
    tracep->declBus(c+68,"io_bundleReg_rs1", false,-1, 4,0);
    tracep->declBus(c+69,"io_bundleReg_rs2", false,-1, 4,0);
    tracep->declBus(c+70,"io_bundleReg_rd", false,-1, 4,0);
    tracep->declBus(c+59,"io_imm", false,-1, 31,0);
    tracep->declBus(c+45,"immGen_io_inst", false,-1, 31,0);
    tracep->declBus(c+4,"immGen_io_immSel", false,-1, 2,0);
    tracep->declBus(c+59,"immGen_io_imm", false,-1, 31,0);
    tracep->declBus(c+71,"opcode", false,-1, 6,0);
    tracep->declBus(c+72,"funct3", false,-1, 2,0);
    tracep->declBit(c+73,"bit30", false,-1);
    tracep->pushNamePrefix("immGen ");
    tracep->declBus(c+45,"io_inst", false,-1, 31,0);
    tracep->declBus(c+4,"io_immSel", false,-1, 2,0);
    tracep->declBus(c+59,"io_imm", false,-1, 31,0);
    tracep->declBus(c+74,"imm_i", false,-1, 31,0);
    tracep->declBus(c+75,"imm_s", false,-1, 31,0);
    tracep->declBus(c+76,"imm_b", false,-1, 31,0);
    tracep->declBus(c+77,"imm_j", false,-1, 31,0);
    tracep->popNamePrefix(2);
    tracep->pushNamePrefix("memData ");
    tracep->declBit(c+42,"clock", false,-1);
    tracep->declBit(c+50,"io_bundleMemDataControl_ctrlLoad", false,-1);
    tracep->declBit(c+51,"io_bundleMemDataControl_ctrlStore", false,-1);
    tracep->declBus(c+56,"io_resultALU", false,-1, 31,0);
    tracep->declBus(c+58,"io_dataStore", false,-1, 31,0);
    tracep->declBus(c+61,"io_result", false,-1, 31,0);
    tracep->declBit(c+65,"io_extWriteEn", false,-1);
    tracep->declBus(c+66,"io_extWriteAddr", false,-1, 31,0);
    tracep->declBus(c+67,"io_extWriteData", false,-1, 31,0);
    tracep->declBit(c+84,"mem_dataLoad_MPORT_en", false,-1);
    tracep->declBus(c+5,"mem_dataLoad_MPORT_addr", false,-1, 9,0);
    tracep->declBus(c+6,"mem_dataLoad_MPORT_data", false,-1, 31,0);
    tracep->declBus(c+67,"mem_MPORT_data", false,-1, 31,0);
    tracep->declBus(c+78,"mem_MPORT_addr", false,-1, 9,0);
    tracep->declBit(c+84,"mem_MPORT_mask", false,-1);
    tracep->declBit(c+65,"mem_MPORT_en", false,-1);
    tracep->declBus(c+58,"mem_MPORT_1_data", false,-1, 31,0);
    tracep->declBus(c+5,"mem_MPORT_1_addr", false,-1, 9,0);
    tracep->declBit(c+84,"mem_MPORT_1_mask", false,-1);
    tracep->declBit(c+79,"mem_MPORT_1_en", false,-1);
    tracep->declBus(c+80,"cpuWordAddr", false,-1, 31,0);
    tracep->declBus(c+81,"extWordAddr", false,-1, 31,0);
    tracep->declBus(c+6,"dataLoad", false,-1, 31,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("memInst ");
    tracep->declBit(c+42,"clock", false,-1);
    tracep->declBus(c+44,"io_addr", false,-1, 31,0);
    tracep->declBus(c+45,"io_inst", false,-1, 31,0);
    tracep->declBit(c+62,"io_extWriteEn", false,-1);
    tracep->declBus(c+63,"io_extWriteAddr", false,-1, 31,0);
    tracep->declBus(c+64,"io_extWriteData", false,-1, 31,0);
    tracep->declBit(c+84,"mem_io_inst_MPORT_en", false,-1);
    tracep->declBus(c+7,"mem_io_inst_MPORT_addr", false,-1, 9,0);
    tracep->declBus(c+45,"mem_io_inst_MPORT_data", false,-1, 31,0);
    tracep->declBus(c+64,"mem_MPORT_data", false,-1, 31,0);
    tracep->declBus(c+82,"mem_MPORT_addr", false,-1, 9,0);
    tracep->declBit(c+84,"mem_MPORT_mask", false,-1);
    tracep->declBit(c+62,"mem_MPORT_en", false,-1);
    tracep->declBus(c+8,"cpuWordAddr", false,-1, 31,0);
    tracep->declBus(c+83,"extWordAddr", false,-1, 31,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("pcReg ");
    tracep->declBit(c+42,"clock", false,-1);
    tracep->declBit(c+43,"reset", false,-1);
    tracep->declBus(c+44,"io_addrOut", false,-1, 31,0);
    tracep->declBit(c+46,"io_ctrlJump", false,-1);
    tracep->declBit(c+48,"io_ctrlBranch", false,-1);
    tracep->declBit(c+60,"io_resultBranch", false,-1);
    tracep->declBus(c+61,"io_addrTarget", false,-1, 31,0);
    tracep->declBus(c+9,"regPC", false,-1, 31,0);
    tracep->popNamePrefix(1);
    tracep->pushNamePrefix("registers ");
    tracep->declBit(c+42,"clock", false,-1);
    tracep->declBit(c+49,"io_ctrlRegWrite", false,-1);
    tracep->declBus(c+61,"io_dataWrite", false,-1, 31,0);
    tracep->declBus(c+68,"io_bundleReg_rs1", false,-1, 4,0);
    tracep->declBus(c+69,"io_bundleReg_rs2", false,-1, 4,0);
    tracep->declBus(c+70,"io_bundleReg_rd", false,-1, 4,0);
    tracep->declBus(c+57,"io_dataRead1", false,-1, 31,0);
    tracep->declBus(c+58,"io_dataRead2", false,-1, 31,0);
    tracep->declBit(c+46,"io_ctrlJump", false,-1);
    tracep->declBus(c+44,"io_pc", false,-1, 31,0);
    tracep->declBus(c+10,"regs_0", false,-1, 31,0);
    tracep->declBus(c+11,"regs_1", false,-1, 31,0);
    tracep->declBus(c+12,"regs_2", false,-1, 31,0);
    tracep->declBus(c+13,"regs_3", false,-1, 31,0);
    tracep->declBus(c+14,"regs_4", false,-1, 31,0);
    tracep->declBus(c+15,"regs_5", false,-1, 31,0);
    tracep->declBus(c+16,"regs_6", false,-1, 31,0);
    tracep->declBus(c+17,"regs_7", false,-1, 31,0);
    tracep->declBus(c+18,"regs_8", false,-1, 31,0);
    tracep->declBus(c+19,"regs_9", false,-1, 31,0);
    tracep->declBus(c+20,"regs_10", false,-1, 31,0);
    tracep->declBus(c+21,"regs_11", false,-1, 31,0);
    tracep->declBus(c+22,"regs_12", false,-1, 31,0);
    tracep->declBus(c+23,"regs_13", false,-1, 31,0);
    tracep->declBus(c+24,"regs_14", false,-1, 31,0);
    tracep->declBus(c+25,"regs_15", false,-1, 31,0);
    tracep->declBus(c+26,"regs_16", false,-1, 31,0);
    tracep->declBus(c+27,"regs_17", false,-1, 31,0);
    tracep->declBus(c+28,"regs_18", false,-1, 31,0);
    tracep->declBus(c+29,"regs_19", false,-1, 31,0);
    tracep->declBus(c+30,"regs_20", false,-1, 31,0);
    tracep->declBus(c+31,"regs_21", false,-1, 31,0);
    tracep->declBus(c+32,"regs_22", false,-1, 31,0);
    tracep->declBus(c+33,"regs_23", false,-1, 31,0);
    tracep->declBus(c+34,"regs_24", false,-1, 31,0);
    tracep->declBus(c+35,"regs_25", false,-1, 31,0);
    tracep->declBus(c+36,"regs_26", false,-1, 31,0);
    tracep->declBus(c+37,"regs_27", false,-1, 31,0);
    tracep->declBus(c+38,"regs_28", false,-1, 31,0);
    tracep->declBus(c+39,"regs_29", false,-1, 31,0);
    tracep->declBus(c+40,"regs_30", false,-1, 31,0);
    tracep->declBus(c+41,"regs_31", false,-1, 31,0);
    tracep->popNamePrefix(2);
}

VL_ATTR_COLD void VTop___024root__trace_init_top(VTop___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root__trace_init_top\n"); );
    // Body
    VTop___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void VTop___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void VTop___024root__trace_chg_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void VTop___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void VTop___024root__trace_register(VTop___024root* vlSelf, VerilatedVcd* tracep) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root__trace_register\n"); );
    // Body
    tracep->addFullCb(&VTop___024root__trace_full_top_0, vlSelf);
    tracep->addChgCb(&VTop___024root__trace_chg_top_0, vlSelf);
    tracep->addCleanupCb(&VTop___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void VTop___024root__trace_full_sub_0(VTop___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void VTop___024root__trace_full_top_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root__trace_full_top_0\n"); );
    // Init
    VTop___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<VTop___024root*>(voidSelf);
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    VTop___024root__trace_full_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void VTop___024root__trace_full_sub_0(VTop___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root__trace_full_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    // Body
    bufp->fullIData(oldp+1,(vlSelf->Top__DOT__alu__DOT__operand1),32);
    bufp->fullIData(oldp+2,(vlSelf->Top__DOT__alu__DOT__operand2),32);
    bufp->fullIData(oldp+3,(vlSelf->Top__DOT__alu__DOT__addResult),32);
    bufp->fullCData(oldp+4,(vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel),3);
    bufp->fullSData(oldp+5,(vlSelf->Top__DOT__memData__DOT__mem_dataLoad_MPORT_addr),10);
    bufp->fullIData(oldp+6,(vlSelf->Top__DOT__memData__DOT__mem
                            [vlSelf->Top__DOT__memData__DOT__mem_dataLoad_MPORT_addr]),32);
    bufp->fullSData(oldp+7,((0x3ffU & (vlSelf->Top__DOT__pcReg__DOT__regPC 
                                       >> 2U))),10);
    bufp->fullIData(oldp+8,((vlSelf->Top__DOT__pcReg__DOT__regPC 
                             >> 2U)),32);
    bufp->fullIData(oldp+9,(vlSelf->Top__DOT__pcReg__DOT__regPC),32);
    bufp->fullIData(oldp+10,(vlSelf->Top__DOT__registers__DOT__regs_0),32);
    bufp->fullIData(oldp+11,(vlSelf->Top__DOT__registers__DOT__regs_1),32);
    bufp->fullIData(oldp+12,(vlSelf->Top__DOT__registers__DOT__regs_2),32);
    bufp->fullIData(oldp+13,(vlSelf->Top__DOT__registers__DOT__regs_3),32);
    bufp->fullIData(oldp+14,(vlSelf->Top__DOT__registers__DOT__regs_4),32);
    bufp->fullIData(oldp+15,(vlSelf->Top__DOT__registers__DOT__regs_5),32);
    bufp->fullIData(oldp+16,(vlSelf->Top__DOT__registers__DOT__regs_6),32);
    bufp->fullIData(oldp+17,(vlSelf->Top__DOT__registers__DOT__regs_7),32);
    bufp->fullIData(oldp+18,(vlSelf->Top__DOT__registers__DOT__regs_8),32);
    bufp->fullIData(oldp+19,(vlSelf->Top__DOT__registers__DOT__regs_9),32);
    bufp->fullIData(oldp+20,(vlSelf->Top__DOT__registers__DOT__regs_10),32);
    bufp->fullIData(oldp+21,(vlSelf->Top__DOT__registers__DOT__regs_11),32);
    bufp->fullIData(oldp+22,(vlSelf->Top__DOT__registers__DOT__regs_12),32);
    bufp->fullIData(oldp+23,(vlSelf->Top__DOT__registers__DOT__regs_13),32);
    bufp->fullIData(oldp+24,(vlSelf->Top__DOT__registers__DOT__regs_14),32);
    bufp->fullIData(oldp+25,(vlSelf->Top__DOT__registers__DOT__regs_15),32);
    bufp->fullIData(oldp+26,(vlSelf->Top__DOT__registers__DOT__regs_16),32);
    bufp->fullIData(oldp+27,(vlSelf->Top__DOT__registers__DOT__regs_17),32);
    bufp->fullIData(oldp+28,(vlSelf->Top__DOT__registers__DOT__regs_18),32);
    bufp->fullIData(oldp+29,(vlSelf->Top__DOT__registers__DOT__regs_19),32);
    bufp->fullIData(oldp+30,(vlSelf->Top__DOT__registers__DOT__regs_20),32);
    bufp->fullIData(oldp+31,(vlSelf->Top__DOT__registers__DOT__regs_21),32);
    bufp->fullIData(oldp+32,(vlSelf->Top__DOT__registers__DOT__regs_22),32);
    bufp->fullIData(oldp+33,(vlSelf->Top__DOT__registers__DOT__regs_23),32);
    bufp->fullIData(oldp+34,(vlSelf->Top__DOT__registers__DOT__regs_24),32);
    bufp->fullIData(oldp+35,(vlSelf->Top__DOT__registers__DOT__regs_25),32);
    bufp->fullIData(oldp+36,(vlSelf->Top__DOT__registers__DOT__regs_26),32);
    bufp->fullIData(oldp+37,(vlSelf->Top__DOT__registers__DOT__regs_27),32);
    bufp->fullIData(oldp+38,(vlSelf->Top__DOT__registers__DOT__regs_28),32);
    bufp->fullIData(oldp+39,(vlSelf->Top__DOT__registers__DOT__regs_29),32);
    bufp->fullIData(oldp+40,(vlSelf->Top__DOT__registers__DOT__regs_30),32);
    bufp->fullIData(oldp+41,(vlSelf->Top__DOT__registers__DOT__regs_31),32);
    bufp->fullBit(oldp+42,(vlSelf->clock));
    bufp->fullBit(oldp+43,(vlSelf->reset));
    bufp->fullIData(oldp+44,(vlSelf->io_addr),32);
    bufp->fullIData(oldp+45,(vlSelf->io_inst),32);
    bufp->fullBit(oldp+46,(vlSelf->io_bundleCtrl_ctrlJump));
    bufp->fullBit(oldp+47,(vlSelf->io_bundleCtrl_ctrlJAL));
    bufp->fullBit(oldp+48,(vlSelf->io_bundleCtrl_ctrlBranch));
    bufp->fullBit(oldp+49,(vlSelf->io_bundleCtrl_ctrlRegWrite));
    bufp->fullBit(oldp+50,(vlSelf->io_bundleCtrl_ctrlLoad));
    bufp->fullBit(oldp+51,(vlSelf->io_bundleCtrl_ctrlStore));
    bufp->fullBit(oldp+52,(vlSelf->io_bundleCtrl_ctrlALUSrc));
    bufp->fullCData(oldp+53,(vlSelf->io_bundleCtrl_ctrlOP),4);
    bufp->fullBit(oldp+54,(vlSelf->io_ctrlBranchToPc));
    bufp->fullBit(oldp+55,(vlSelf->io_ctrlJumpToPc));
    bufp->fullIData(oldp+56,(vlSelf->io_resultALU),32);
    bufp->fullIData(oldp+57,(vlSelf->io_rs1),32);
    bufp->fullIData(oldp+58,(vlSelf->io_rs2),32);
    bufp->fullIData(oldp+59,(vlSelf->io_imm),32);
    bufp->fullBit(oldp+60,(vlSelf->io_resultBranch));
    bufp->fullIData(oldp+61,(vlSelf->io_result),32);
    bufp->fullBit(oldp+62,(vlSelf->io_instWriteEn));
    bufp->fullIData(oldp+63,(vlSelf->io_instWriteAddr),32);
    bufp->fullIData(oldp+64,(vlSelf->io_instWriteData),32);
    bufp->fullBit(oldp+65,(vlSelf->io_dataWriteEn));
    bufp->fullIData(oldp+66,(vlSelf->io_dataWriteAddr),32);
    bufp->fullIData(oldp+67,(vlSelf->io_dataWriteData),32);
    bufp->fullCData(oldp+68,((0x1fU & (vlSelf->io_inst 
                                       >> 0xfU))),5);
    bufp->fullCData(oldp+69,((0x1fU & (vlSelf->io_inst 
                                       >> 0x14U))),5);
    bufp->fullCData(oldp+70,((0x1fU & (vlSelf->io_inst 
                                       >> 7U))),5);
    bufp->fullCData(oldp+71,((0x7fU & vlSelf->io_inst)),7);
    bufp->fullCData(oldp+72,((7U & (vlSelf->io_inst 
                                    >> 0xcU))),3);
    bufp->fullBit(oldp+73,((1U & (vlSelf->io_inst >> 0x1eU))));
    bufp->fullIData(oldp+74,(((((vlSelf->io_inst >> 0x1fU)
                                 ? 0xfffffU : 0U) << 0xcU) 
                              | (vlSelf->io_inst >> 0x14U))),32);
    bufp->fullIData(oldp+75,(((((vlSelf->io_inst >> 0x1fU)
                                 ? 0xfffffU : 0U) << 0xcU) 
                              | ((0xfe0U & (vlSelf->io_inst 
                                            >> 0x14U)) 
                                 | (0x1fU & (vlSelf->io_inst 
                                             >> 7U))))),32);
    bufp->fullIData(oldp+76,(((((vlSelf->io_inst >> 0x1fU)
                                 ? 0x7ffffU : 0U) << 0xdU) 
                              | ((0x1000U & (vlSelf->io_inst 
                                             >> 0x13U)) 
                                 | ((0x800U & (vlSelf->io_inst 
                                               << 4U)) 
                                    | ((0x7e0U & (vlSelf->io_inst 
                                                  >> 0x14U)) 
                                       | (0x1eU & (vlSelf->io_inst 
                                                   >> 7U))))))),32);
    bufp->fullIData(oldp+77,(((((vlSelf->io_inst >> 0x1fU)
                                 ? 0x7ffU : 0U) << 0x15U) 
                              | ((0x100000U & (vlSelf->io_inst 
                                               >> 0xbU)) 
                                 | ((0xff000U & vlSelf->io_inst) 
                                    | ((0x800U & (vlSelf->io_inst 
                                                  >> 9U)) 
                                       | (0x7feU & 
                                          (vlSelf->io_inst 
                                           >> 0x14U))))))),32);
    bufp->fullSData(oldp+78,((0x3ffU & (vlSelf->io_dataWriteAddr 
                                        >> 2U))),10);
    bufp->fullBit(oldp+79,(((~ (IData)(vlSelf->io_dataWriteEn)) 
                            & (IData)(vlSelf->io_bundleCtrl_ctrlStore))));
    bufp->fullIData(oldp+80,((vlSelf->io_resultALU 
                              >> 2U)),32);
    bufp->fullIData(oldp+81,((vlSelf->io_dataWriteAddr 
                              >> 2U)),32);
    bufp->fullSData(oldp+82,((0x3ffU & (vlSelf->io_instWriteAddr 
                                        >> 2U))),10);
    bufp->fullIData(oldp+83,((vlSelf->io_instWriteAddr 
                              >> 2U)),32);
    bufp->fullBit(oldp+84,(1U));
}
