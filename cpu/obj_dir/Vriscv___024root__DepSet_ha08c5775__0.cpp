// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vriscv.h for the primary calling header

#include "Vriscv__pch.h"
#include "Vriscv__Syms.h"
#include "Vriscv___024root.h"

void Vriscv___024root____Vdpiexp_riscv__DOT__U_NPC__DOT__DPI_getPC_TOP(Vriscv__Syms* __restrict vlSymsp, IData/*31:0*/ &DPI_getPC__Vfuncrtn) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root____Vdpiexp_riscv__DOT__U_NPC__DOT__DPI_getPC_TOP\n"); );
    // Init
    // Body
    DPI_getPC__Vfuncrtn = vlSymsp->TOP.riscv__DOT__PC;
}

extern "C" int instFetch(int addr);

VL_INLINE_OPT void Vriscv___024root____Vdpiimwrap_riscv__DOT__U_IM__DOT__instFetch_TOP(IData/*31:0*/ addr, IData/*31:0*/ &instFetch__Vfuncrtn) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root____Vdpiimwrap_riscv__DOT__U_IM__DOT__instFetch_TOP\n"); );
    // Body
    int addr__Vcvt;
    for (size_t addr__Vidx = 0; addr__Vidx < 1; ++addr__Vidx) addr__Vcvt = addr;
    int instFetch__Vfuncrtn__Vcvt;
    instFetch__Vfuncrtn__Vcvt = instFetch(addr__Vcvt);
    instFetch__Vfuncrtn = instFetch__Vfuncrtn__Vcvt;
}

void Vriscv___024root____Vdpiexp_riscv__DOT__U_RF__DOT__DPI_getReg_TOP(Vriscv__Syms* __restrict vlSymsp, IData/*31:0*/ idx, IData/*31:0*/ &DPI_getReg__Vfuncrtn) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root____Vdpiexp_riscv__DOT__U_RF__DOT__DPI_getReg_TOP\n"); );
    // Init
    // Body
    DPI_getReg__Vfuncrtn = vlSymsp->TOP.riscv__DOT__U_RF__DOT__register
        [(0x1fU & idx)];
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vriscv___024root___dump_triggers__act(Vriscv___024root* vlSelf);
#endif  // VL_DEBUG

void Vriscv___024root___eval_triggers__act(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_triggers__act\n"); );
    // Body
    vlSelf->__VactTriggered.set(0U, (((IData)(vlSelf->clk) 
                                      & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))) 
                                     | ((IData)(vlSelf->rst) 
                                        & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__rst__0)))));
    vlSelf->__VactTriggered.set(1U, (((IData)(vlSelf->riscv__DOT__InsMemRW) 
                                      != (IData)(vlSelf->__Vtrigprevexpr___TOP__riscv__DOT__InsMemRW__0)) 
                                     | ((IData)(vlSelf->riscv__DOT____Vcellinp__U_IM__addr) 
                                        != (IData)(vlSelf->__Vtrigprevexpr___TOP__riscv__DOT____Vcellinp__U_IM__addr__0))));
    vlSelf->__VactTriggered.set(2U, ((IData)(vlSelf->clk) 
                                     & (~ (IData)(vlSelf->__Vtrigprevexpr___TOP__clk__0))));
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
    vlSelf->__Vtrigprevexpr___TOP__rst__0 = vlSelf->rst;
    vlSelf->__Vtrigprevexpr___TOP__riscv__DOT__InsMemRW__0 
        = vlSelf->riscv__DOT__InsMemRW;
    vlSelf->__Vtrigprevexpr___TOP__riscv__DOT____Vcellinp__U_IM__addr__0 
        = vlSelf->riscv__DOT____Vcellinp__U_IM__addr;
    if (VL_UNLIKELY((1U & (~ (IData)(vlSelf->__VactDidInit))))) {
        vlSelf->__VactDidInit = 1U;
        vlSelf->__VactTriggered.set(1U, 1U);
    }
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vriscv___024root___dump_triggers__act(vlSelf);
    }
#endif
}
