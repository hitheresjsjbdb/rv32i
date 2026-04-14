// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VRISCV__SYMS_H_
#define VERILATED_VRISCV__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vriscv.h"

// INCLUDE MODULE CLASSES
#include "Vriscv___024root.h"

// DPI TYPES for DPI Export callbacks (Internal use)
using Vriscv__Vcb_DPI_getPC_t = void (*) (Vriscv__Syms* __restrict vlSymsp, IData/*31:0*/ &DPI_getPC__Vfuncrtn);
using Vriscv__Vcb_DPI_getReg_t = void (*) (Vriscv__Syms* __restrict vlSymsp, IData/*31:0*/ idx, IData/*31:0*/ &DPI_getReg__Vfuncrtn);

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES)Vriscv__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vriscv* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vriscv___024root               TOP;

    // SCOPE NAMES
    VerilatedScope __Vscope_riscv__U_NPC;
    VerilatedScope __Vscope_riscv__U_RF;

    // CONSTRUCTORS
    Vriscv__Syms(VerilatedContext* contextp, const char* namep, Vriscv* modelp);
    ~Vriscv__Syms();

    // METHODS
    const char* name() { return TOP.name(); }
};

#endif  // guard
