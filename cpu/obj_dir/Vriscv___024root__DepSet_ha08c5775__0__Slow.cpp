// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vriscv.h for the primary calling header

#include "Vriscv__pch.h"
#include "Vriscv__Syms.h"
#include "Vriscv___024root.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vriscv___024root___dump_triggers__stl(Vriscv___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vriscv___024root___eval_triggers__stl(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vriscv___024root___dump_triggers__stl(vlSelf);
    }
#endif
}
