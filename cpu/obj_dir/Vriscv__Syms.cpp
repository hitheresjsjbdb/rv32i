// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vriscv__pch.h"
#include "Vriscv.h"
#include "Vriscv___024root.h"

void Vriscv___024root____Vdpiexp_riscv__DOT__U_NPC__DOT__DPI_getPC_TOP(Vriscv__Syms* __restrict vlSymsp, IData/*31:0*/ &DPI_getPC__Vfuncrtn);
void Vriscv___024root____Vdpiexp_riscv__DOT__U_RF__DOT__DPI_getReg_TOP(Vriscv__Syms* __restrict vlSymsp, IData/*31:0*/ idx, IData/*31:0*/ &DPI_getReg__Vfuncrtn);

// FUNCTIONS
Vriscv__Syms::~Vriscv__Syms()
{
}

Vriscv__Syms::Vriscv__Syms(VerilatedContext* contextp, const char* namep, Vriscv* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
{
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-9);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    // Setup scopes
    __Vscope_riscv__U_NPC.configure(this, name(), "riscv.U_NPC", "U_NPC", -9, VerilatedScope::SCOPE_OTHER);
    __Vscope_riscv__U_RF.configure(this, name(), "riscv.U_RF", "U_RF", -9, VerilatedScope::SCOPE_OTHER);
    // Setup export functions
    for (int __Vfinal = 0; __Vfinal < 2; ++__Vfinal) {
        __Vscope_riscv__U_NPC.exportInsert(__Vfinal, "DPI_getPC", (void*)(&Vriscv___024root____Vdpiexp_riscv__DOT__U_NPC__DOT__DPI_getPC_TOP));
        __Vscope_riscv__U_RF.exportInsert(__Vfinal, "DPI_getReg", (void*)(&Vriscv___024root____Vdpiexp_riscv__DOT__U_RF__DOT__DPI_getReg_TOP));
    }
}
