// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vriscv.h for the primary calling header

#ifndef VERILATED_VRISCV___024ROOT_H_
#define VERILATED_VRISCV___024ROOT_H_  // guard

#include "verilated.h"


class Vriscv__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vriscv___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    VL_IN8(clk,0,0);
    VL_IN8(rst,0,0);
    CData/*0:0*/ riscv__DOT__InsMemRW;
    CData/*0:0*/ riscv__DOT__ExtSel;
    VL_OUT8(done,0,0);
    CData/*0:0*/ riscv__DOT__DMCtrl;
    CData/*0:0*/ riscv__DOT__PCWrite;
    CData/*1:0*/ riscv__DOT__ALUSrcB;
    CData/*1:0*/ riscv__DOT__NPCOp;
    CData/*1:0*/ riscv__DOT__WDSel;
    CData/*3:0*/ riscv__DOT__ALUOp;
    CData/*2:0*/ riscv__DOT__U_ControlUnit__DOT__State;
    CData/*2:0*/ riscv__DOT__U_ControlUnit__DOT__NxtState;
    CData/*0:0*/ riscv__DOT__U_ControlUnit__DOT__AR;
    CData/*0:0*/ riscv__DOT__U_ControlUnit__DOT__MEM;
    CData/*0:0*/ riscv__DOT__U_ControlUnit__DOT__WB;
    CData/*0:0*/ riscv__DOT__U_ControlUnit__DOT__EX;
    CData/*0:0*/ riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp;
    CData/*4:0*/ __Vdlyvdim0__riscv__DOT__U_RF__DOT__register__v0;
    CData/*0:0*/ __Vdlyvset__riscv__DOT__U_RF__DOT__register__v0;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__rst__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__riscv__DOT__InsMemRW__0;
    CData/*0:0*/ __VactDidInit;
    CData/*0:0*/ __VactContinue;
    SData/*9:0*/ riscv__DOT____Vcellinp__U_IM__addr;
    SData/*11:0*/ riscv__DOT____Vcellinp__U_MUX_3to1_B__Z;
    SData/*9:0*/ __Vtrigprevexpr___TOP__riscv__DOT____Vcellinp__U_IM__addr__0;
    IData/*31:0*/ riscv__DOT__PC;
    IData/*31:0*/ riscv__DOT__NPC;
    IData/*31:0*/ riscv__DOT__in_ins;
    IData/*31:0*/ riscv__DOT__out_ins;
    IData/*31:0*/ riscv__DOT__RD;
    IData/*31:0*/ riscv__DOT__Imm32;
    IData/*31:0*/ riscv__DOT__WD;
    IData/*31:0*/ riscv__DOT__RD1;
    IData/*31:0*/ riscv__DOT__RD1_r;
    IData/*31:0*/ riscv__DOT__RD2_r;
    IData/*31:0*/ riscv__DOT__B;
    IData/*31:0*/ riscv__DOT__ALU_result;
    IData/*31:0*/ riscv__DOT__ALU_result_r;
    IData/*31:0*/ __Vdlyvval__riscv__DOT__U_RF__DOT__register__v0;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<IData/*31:0*/, 32> riscv__DOT__U_RF__DOT__register;
    VlUnpacked<IData/*31:0*/, 1024> riscv__DOT__U_DM__DOT__memory;
    VlUnpacked<CData/*0:0*/, 4> __Vm_traceActivity;
    VlTriggerVec<1> __VstlTriggered;
    VlTriggerVec<3> __VactTriggered;
    VlTriggerVec<3> __VnbaTriggered;

    // INTERNAL VARIABLES
    Vriscv__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vriscv___024root(Vriscv__Syms* symsp, const char* v__name);
    ~Vriscv___024root();
    VL_UNCOPYABLE(Vriscv___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
