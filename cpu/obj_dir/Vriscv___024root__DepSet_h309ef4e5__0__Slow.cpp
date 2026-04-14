// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vriscv.h for the primary calling header

#include "Vriscv__pch.h"
#include "Vriscv___024root.h"

VL_ATTR_COLD void Vriscv___024root___eval_static(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_static\n"); );
}

VL_ATTR_COLD void Vriscv___024root___eval_initial__TOP(Vriscv___024root* vlSelf);

VL_ATTR_COLD void Vriscv___024root___eval_initial(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_initial\n"); );
    // Body
    Vriscv___024root___eval_initial__TOP(vlSelf);
    vlSelf->__Vm_traceActivity[3U] = 1U;
    vlSelf->__Vm_traceActivity[2U] = 1U;
    vlSelf->__Vm_traceActivity[1U] = 1U;
    vlSelf->__Vm_traceActivity[0U] = 1U;
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = vlSelf->clk;
    vlSelf->__Vtrigprevexpr___TOP__rst__0 = vlSelf->rst;
    vlSelf->__Vtrigprevexpr___TOP__riscv__DOT__InsMemRW__0 = 1U;
    vlSelf->__Vtrigprevexpr___TOP__riscv__DOT____Vcellinp__U_IM__addr__0 
        = vlSelf->riscv__DOT____Vcellinp__U_IM__addr;
}

VL_ATTR_COLD void Vriscv___024root___eval_initial__TOP(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_initial__TOP\n"); );
    // Body
    vlSelf->riscv__DOT__InsMemRW = 1U;
    vlSelf->riscv__DOT__U_RF__DOT__register[0U] = 0U;
}

VL_ATTR_COLD void Vriscv___024root___eval_final(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_final\n"); );
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vriscv___024root___dump_triggers__stl(Vriscv___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vriscv___024root___eval_phase__stl(Vriscv___024root* vlSelf);

VL_ATTR_COLD void Vriscv___024root___eval_settle(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_settle\n"); );
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelf->__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY((0x64U < __VstlIterCount))) {
#ifdef VL_DEBUG
            Vriscv___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("/home/pan/rv32-jichaung/cpu/rtl/rtl/riscv.v", 22, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vriscv___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelf->__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vriscv___024root___dump_triggers__stl(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VstlTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

extern const VlUnpacked<CData/*2:0*/, 128> Vriscv__ConstPool__TABLE_h3ef576a5_0;

VL_ATTR_COLD void Vriscv___024root___stl_sequent__TOP__0(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___stl_sequent__TOP__0\n"); );
    // Init
    CData/*6:0*/ __Vtableidx1;
    __Vtableidx1 = 0;
    // Body
    vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 0U;
    vlSelf->riscv__DOT__DMCtrl = 0U;
    if ((1U & (~ (vlSelf->riscv__DOT__out_ins >> 6U)))) {
        if ((0x20U & vlSelf->riscv__DOT__out_ins)) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 4U)))) {
                if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                              >> 3U)))) {
                    if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                                  >> 2U)))) {
                        if ((2U & vlSelf->riscv__DOT__out_ins)) {
                            if ((1U & vlSelf->riscv__DOT__out_ins)) {
                                vlSelf->riscv__DOT__DMCtrl = 1U;
                            }
                        }
                    }
                }
            }
        } else if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                             >> 4U)))) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 3U)))) {
                if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                              >> 2U)))) {
                    if ((2U & vlSelf->riscv__DOT__out_ins)) {
                        if ((1U & vlSelf->riscv__DOT__out_ins)) {
                            vlSelf->riscv__DOT__DMCtrl = 0U;
                        }
                    }
                }
            }
        }
    }
    vlSelf->done = (0U == (IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__State));
    vlSelf->riscv__DOT____Vcellinp__U_IM__addr = (0x3ffU 
                                                  & (vlSelf->riscv__DOT__PC 
                                                     >> 2U));
    vlSelf->riscv__DOT__WDSel = 0U;
    vlSelf->riscv__DOT__RD1 = vlSelf->riscv__DOT__U_RF__DOT__register
        [(0x1fU & (vlSelf->riscv__DOT__out_ins >> 0xfU))];
    vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
    vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
    vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 1U;
    vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 1U;
    vlSelf->riscv__DOT__ALUOp = 0U;
    vlSelf->riscv__DOT__ALUSrcB = 0U;
    vlSelf->riscv__DOT__ExtSel = 1U;
    vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z 
        = (0xfffU & ((0x63U == (0x7fU & vlSelf->riscv__DOT__out_ins))
                      ? ((0x800U & (vlSelf->riscv__DOT__out_ins 
                                    >> 0x14U)) | ((0x400U 
                                                   & (vlSelf->riscv__DOT__out_ins 
                                                      << 3U)) 
                                                  | ((0x3f0U 
                                                      & (vlSelf->riscv__DOT__out_ins 
                                                         >> 0x15U)) 
                                                     | (0xfU 
                                                        & (vlSelf->riscv__DOT__out_ins 
                                                           >> 8U)))))
                      : ((0x23U == (0x7fU & vlSelf->riscv__DOT__out_ins))
                          ? ((0xfe0U & (vlSelf->riscv__DOT__out_ins 
                                        >> 0x14U)) 
                             | (0x1fU & (vlSelf->riscv__DOT__out_ins 
                                         >> 7U))) : 
                         (vlSelf->riscv__DOT__out_ins 
                          >> 0x14U))));
    if ((0x40U & vlSelf->riscv__DOT__out_ins)) {
        if ((0x20U & vlSelf->riscv__DOT__out_ins)) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 4U)))) {
                if ((8U & vlSelf->riscv__DOT__out_ins)) {
                    if ((4U & vlSelf->riscv__DOT__out_ins)) {
                        if ((2U & vlSelf->riscv__DOT__out_ins)) {
                            if ((1U & vlSelf->riscv__DOT__out_ins)) {
                                vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 1U;
                                vlSelf->riscv__DOT__WDSel = 2U;
                            }
                        }
                    }
                } else if ((4U & vlSelf->riscv__DOT__out_ins)) {
                    if ((2U & vlSelf->riscv__DOT__out_ins)) {
                        if ((1U & vlSelf->riscv__DOT__out_ins)) {
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 1U;
                            vlSelf->riscv__DOT__WDSel = 2U;
                        }
                    }
                } else if ((2U & vlSelf->riscv__DOT__out_ins)) {
                    if ((1U & vlSelf->riscv__DOT__out_ins)) {
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 0U;
                    }
                }
            }
        }
    } else {
        if ((0x20U & vlSelf->riscv__DOT__out_ins)) {
            if ((0x10U & vlSelf->riscv__DOT__out_ins)) {
                if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                              >> 3U)))) {
                    if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                                  >> 2U)))) {
                        if ((2U & vlSelf->riscv__DOT__out_ins)) {
                            if ((1U & vlSelf->riscv__DOT__out_ins)) {
                                vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 1U;
                                if ((1U & (~ ((((((
                                                   ((0U 
                                                     == 
                                                     ((0x3f8U 
                                                       & (vlSelf->riscv__DOT__out_ins 
                                                          >> 0x16U)) 
                                                      | (7U 
                                                         & (vlSelf->riscv__DOT__out_ins 
                                                            >> 0xcU)))) 
                                                    | (0x100U 
                                                       == 
                                                       ((0x3f8U 
                                                         & (vlSelf->riscv__DOT__out_ins 
                                                            >> 0x16U)) 
                                                        | (7U 
                                                           & (vlSelf->riscv__DOT__out_ins 
                                                              >> 0xcU))))) 
                                                   | (7U 
                                                      == 
                                                      ((0x3f8U 
                                                        & (vlSelf->riscv__DOT__out_ins 
                                                           >> 0x16U)) 
                                                       | (7U 
                                                          & (vlSelf->riscv__DOT__out_ins 
                                                             >> 0xcU))))) 
                                                  | (6U 
                                                     == 
                                                     ((0x3f8U 
                                                       & (vlSelf->riscv__DOT__out_ins 
                                                          >> 0x16U)) 
                                                      | (7U 
                                                         & (vlSelf->riscv__DOT__out_ins 
                                                            >> 0xcU))))) 
                                                 | (4U 
                                                    == 
                                                    ((0x3f8U 
                                                      & (vlSelf->riscv__DOT__out_ins 
                                                         >> 0x16U)) 
                                                     | (7U 
                                                        & (vlSelf->riscv__DOT__out_ins 
                                                           >> 0xcU))))) 
                                                | (1U 
                                                   == 
                                                   ((0x3f8U 
                                                     & (vlSelf->riscv__DOT__out_ins 
                                                        >> 0x16U)) 
                                                    | (7U 
                                                       & (vlSelf->riscv__DOT__out_ins 
                                                          >> 0xcU))))) 
                                               | (5U 
                                                  == 
                                                  ((0x3f8U 
                                                    & (vlSelf->riscv__DOT__out_ins 
                                                       >> 0x16U)) 
                                                   | (7U 
                                                      & (vlSelf->riscv__DOT__out_ins 
                                                         >> 0xcU))))) 
                                              | (0x105U 
                                                 == 
                                                 ((0x3f8U 
                                                   & (vlSelf->riscv__DOT__out_ins 
                                                      >> 0x16U)) 
                                                  | (7U 
                                                     & (vlSelf->riscv__DOT__out_ins 
                                                        >> 0xcU)))))))) {
                                    vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 0U;
                                }
                            }
                        }
                    }
                }
            } else if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                                 >> 3U)))) {
                if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                              >> 2U)))) {
                    if ((2U & vlSelf->riscv__DOT__out_ins)) {
                        if ((1U & vlSelf->riscv__DOT__out_ins)) {
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 0U;
                        }
                    }
                }
            }
        } else if ((0x10U & vlSelf->riscv__DOT__out_ins)) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 3U)))) {
                if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                              >> 2U)))) {
                    if ((2U & vlSelf->riscv__DOT__out_ins)) {
                        if ((1U & vlSelf->riscv__DOT__out_ins)) {
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 1U;
                            if ((0U != (7U & (vlSelf->riscv__DOT__out_ins 
                                              >> 0xcU)))) {
                                if ((6U != (7U & (vlSelf->riscv__DOT__out_ins 
                                                  >> 0xcU)))) {
                                    vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 0U;
                                }
                            }
                        }
                    }
                }
            }
        } else if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                             >> 3U)))) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 2U)))) {
                if ((2U & vlSelf->riscv__DOT__out_ins)) {
                    if ((1U & vlSelf->riscv__DOT__out_ins)) {
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 1U;
                    }
                }
            }
        }
        if ((1U & (~ (vlSelf->riscv__DOT__out_ins >> 5U)))) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 4U)))) {
                if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                              >> 3U)))) {
                    if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                                  >> 2U)))) {
                        if ((2U & vlSelf->riscv__DOT__out_ins)) {
                            if ((1U & vlSelf->riscv__DOT__out_ins)) {
                                vlSelf->riscv__DOT__WDSel = 1U;
                            }
                        }
                    }
                }
            }
        }
    }
    vlSelf->riscv__DOT__WD = ((2U & (IData)(vlSelf->riscv__DOT__WDSel))
                               ? ((1U & (IData)(vlSelf->riscv__DOT__WDSel))
                                   ? 0U : ((IData)(4U) 
                                           + vlSelf->riscv__DOT__PC))
                               : ((1U & (IData)(vlSelf->riscv__DOT__WDSel))
                                   ? vlSelf->riscv__DOT__RD
                                   : vlSelf->riscv__DOT__ALU_result_r));
    if ((0x40U & vlSelf->riscv__DOT__out_ins)) {
        if ((0x20U & vlSelf->riscv__DOT__out_ins)) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 4U)))) {
                if ((8U & vlSelf->riscv__DOT__out_ins)) {
                    if ((4U & vlSelf->riscv__DOT__out_ins)) {
                        if ((2U & vlSelf->riscv__DOT__out_ins)) {
                            if ((1U & vlSelf->riscv__DOT__out_ins)) {
                                vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 0U;
                                vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 0U;
                                vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 0U;
                                vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 1U;
                            }
                        }
                    }
                } else if ((4U & vlSelf->riscv__DOT__out_ins)) {
                    if ((2U & vlSelf->riscv__DOT__out_ins)) {
                        if ((1U & vlSelf->riscv__DOT__out_ins)) {
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 0U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 1U;
                        }
                    }
                } else if ((2U & vlSelf->riscv__DOT__out_ins)) {
                    if ((1U & vlSelf->riscv__DOT__out_ins)) {
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 0U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 0U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 0U;
                    }
                }
            }
        }
    } else if ((0x20U & vlSelf->riscv__DOT__out_ins)) {
        if ((0x10U & vlSelf->riscv__DOT__out_ins)) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 3U)))) {
                if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                              >> 2U)))) {
                    if ((2U & vlSelf->riscv__DOT__out_ins)) {
                        if ((1U & vlSelf->riscv__DOT__out_ins)) {
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 0U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 1U;
                        }
                    }
                }
            }
        } else if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                             >> 3U)))) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 2U)))) {
                if ((2U & vlSelf->riscv__DOT__out_ins)) {
                    if ((1U & vlSelf->riscv__DOT__out_ins)) {
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 1U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 0U;
                    }
                }
            }
        }
    } else if ((0x10U & vlSelf->riscv__DOT__out_ins)) {
        if ((1U & (~ (vlSelf->riscv__DOT__out_ins >> 3U)))) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 2U)))) {
                if ((2U & vlSelf->riscv__DOT__out_ins)) {
                    if ((1U & vlSelf->riscv__DOT__out_ins)) {
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 0U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 1U;
                    }
                }
            }
        }
    } else if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                         >> 3U)))) {
        if ((1U & (~ (vlSelf->riscv__DOT__out_ins >> 2U)))) {
            if ((2U & vlSelf->riscv__DOT__out_ins)) {
                if ((1U & vlSelf->riscv__DOT__out_ins)) {
                    vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
                    vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
                    vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 1U;
                    vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 1U;
                }
            }
        }
    }
    __Vtableidx1 = (((IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__EX) 
                     << 6U) | (((IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__AR) 
                                << 5U) | (((IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM) 
                                           << 4U) | 
                                          (((IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__WB) 
                                            << 3U) 
                                           | (IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__State)))));
    vlSelf->riscv__DOT__U_ControlUnit__DOT__NxtState 
        = Vriscv__ConstPool__TABLE_h3ef576a5_0[__Vtableidx1];
    if ((0x40U & vlSelf->riscv__DOT__out_ins)) {
        if ((0x20U & vlSelf->riscv__DOT__out_ins)) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 4U)))) {
                if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                              >> 3U)))) {
                    if ((4U & vlSelf->riscv__DOT__out_ins)) {
                        if ((2U & vlSelf->riscv__DOT__out_ins)) {
                            if ((1U & vlSelf->riscv__DOT__out_ins)) {
                                vlSelf->riscv__DOT__ALUOp = 0U;
                                vlSelf->riscv__DOT__ALUSrcB = 1U;
                                vlSelf->riscv__DOT__ExtSel = 1U;
                            }
                        }
                    } else if ((2U & vlSelf->riscv__DOT__out_ins)) {
                        if ((1U & vlSelf->riscv__DOT__out_ins)) {
                            vlSelf->riscv__DOT__ALUOp = 1U;
                            vlSelf->riscv__DOT__ALUSrcB = 0U;
                        }
                    }
                }
            }
        }
    } else if ((0x20U & vlSelf->riscv__DOT__out_ins)) {
        if ((0x10U & vlSelf->riscv__DOT__out_ins)) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 3U)))) {
                if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                              >> 2U)))) {
                    if ((2U & vlSelf->riscv__DOT__out_ins)) {
                        if ((1U & vlSelf->riscv__DOT__out_ins)) {
                            vlSelf->riscv__DOT__ALUOp 
                                = (((((((((0U == ((0x3f8U 
                                                   & (vlSelf->riscv__DOT__out_ins 
                                                      >> 0x16U)) 
                                                  | (7U 
                                                     & (vlSelf->riscv__DOT__out_ins 
                                                        >> 0xcU)))) 
                                          | (0x100U 
                                             == ((0x3f8U 
                                                  & (vlSelf->riscv__DOT__out_ins 
                                                     >> 0x16U)) 
                                                 | (7U 
                                                    & (vlSelf->riscv__DOT__out_ins 
                                                       >> 0xcU))))) 
                                         | (7U == (
                                                   (0x3f8U 
                                                    & (vlSelf->riscv__DOT__out_ins 
                                                       >> 0x16U)) 
                                                   | (7U 
                                                      & (vlSelf->riscv__DOT__out_ins 
                                                         >> 0xcU))))) 
                                        | (6U == ((0x3f8U 
                                                   & (vlSelf->riscv__DOT__out_ins 
                                                      >> 0x16U)) 
                                                  | (7U 
                                                     & (vlSelf->riscv__DOT__out_ins 
                                                        >> 0xcU))))) 
                                       | (4U == ((0x3f8U 
                                                  & (vlSelf->riscv__DOT__out_ins 
                                                     >> 0x16U)) 
                                                 | (7U 
                                                    & (vlSelf->riscv__DOT__out_ins 
                                                       >> 0xcU))))) 
                                      | (1U == ((0x3f8U 
                                                 & (vlSelf->riscv__DOT__out_ins 
                                                    >> 0x16U)) 
                                                | (7U 
                                                   & (vlSelf->riscv__DOT__out_ins 
                                                      >> 0xcU))))) 
                                     | (5U == ((0x3f8U 
                                                & (vlSelf->riscv__DOT__out_ins 
                                                   >> 0x16U)) 
                                               | (7U 
                                                  & (vlSelf->riscv__DOT__out_ins 
                                                     >> 0xcU))))) 
                                    | (0x105U == ((0x3f8U 
                                                   & (vlSelf->riscv__DOT__out_ins 
                                                      >> 0x16U)) 
                                                  | (7U 
                                                     & (vlSelf->riscv__DOT__out_ins 
                                                        >> 0xcU)))))
                                    ? ((0U == ((0x3f8U 
                                                & (vlSelf->riscv__DOT__out_ins 
                                                   >> 0x16U)) 
                                               | (7U 
                                                  & (vlSelf->riscv__DOT__out_ins 
                                                     >> 0xcU))))
                                        ? 0U : ((0x100U 
                                                 == 
                                                 ((0x3f8U 
                                                   & (vlSelf->riscv__DOT__out_ins 
                                                      >> 0x16U)) 
                                                  | (7U 
                                                     & (vlSelf->riscv__DOT__out_ins 
                                                        >> 0xcU))))
                                                 ? 1U
                                                 : 
                                                ((7U 
                                                  == 
                                                  ((0x3f8U 
                                                    & (vlSelf->riscv__DOT__out_ins 
                                                       >> 0x16U)) 
                                                   | (7U 
                                                      & (vlSelf->riscv__DOT__out_ins 
                                                         >> 0xcU))))
                                                  ? 2U
                                                  : 
                                                 ((6U 
                                                   == 
                                                   ((0x3f8U 
                                                     & (vlSelf->riscv__DOT__out_ins 
                                                        >> 0x16U)) 
                                                    | (7U 
                                                       & (vlSelf->riscv__DOT__out_ins 
                                                          >> 0xcU))))
                                                   ? 3U
                                                   : 
                                                  ((4U 
                                                    == 
                                                    ((0x3f8U 
                                                      & (vlSelf->riscv__DOT__out_ins 
                                                         >> 0x16U)) 
                                                     | (7U 
                                                        & (vlSelf->riscv__DOT__out_ins 
                                                           >> 0xcU))))
                                                    ? 4U
                                                    : 
                                                   ((1U 
                                                     == 
                                                     ((0x3f8U 
                                                       & (vlSelf->riscv__DOT__out_ins 
                                                          >> 0x16U)) 
                                                      | (7U 
                                                         & (vlSelf->riscv__DOT__out_ins 
                                                            >> 0xcU))))
                                                     ? 8U
                                                     : 
                                                    ((5U 
                                                      == 
                                                      ((0x3f8U 
                                                        & (vlSelf->riscv__DOT__out_ins 
                                                           >> 0x16U)) 
                                                       | (7U 
                                                          & (vlSelf->riscv__DOT__out_ins 
                                                             >> 0xcU))))
                                                      ? 9U
                                                      : 5U)))))))
                                    : 0U);
                        }
                    }
                }
            }
        } else if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                             >> 3U)))) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 2U)))) {
                if ((2U & vlSelf->riscv__DOT__out_ins)) {
                    if ((1U & vlSelf->riscv__DOT__out_ins)) {
                        vlSelf->riscv__DOT__ALUOp = 0U;
                    }
                }
            }
        }
        if ((1U & (~ (vlSelf->riscv__DOT__out_ins >> 4U)))) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 3U)))) {
                if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                              >> 2U)))) {
                    if ((2U & vlSelf->riscv__DOT__out_ins)) {
                        if ((1U & vlSelf->riscv__DOT__out_ins)) {
                            vlSelf->riscv__DOT__ALUSrcB = 2U;
                            vlSelf->riscv__DOT__ExtSel = 1U;
                        }
                    }
                }
            }
        }
    } else if ((0x10U & vlSelf->riscv__DOT__out_ins)) {
        if ((1U & (~ (vlSelf->riscv__DOT__out_ins >> 3U)))) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 2U)))) {
                if ((2U & vlSelf->riscv__DOT__out_ins)) {
                    if ((1U & vlSelf->riscv__DOT__out_ins)) {
                        if ((0U == (7U & (vlSelf->riscv__DOT__out_ins 
                                          >> 0xcU)))) {
                            vlSelf->riscv__DOT__ALUOp = 0U;
                            vlSelf->riscv__DOT__ExtSel = 1U;
                        } else if ((6U == (7U & (vlSelf->riscv__DOT__out_ins 
                                                 >> 0xcU)))) {
                            vlSelf->riscv__DOT__ALUOp = 3U;
                            vlSelf->riscv__DOT__ExtSel = 0U;
                        }
                        vlSelf->riscv__DOT__ALUSrcB = 1U;
                    }
                }
            }
        }
    } else if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                         >> 3U)))) {
        if ((1U & (~ (vlSelf->riscv__DOT__out_ins >> 2U)))) {
            if ((2U & vlSelf->riscv__DOT__out_ins)) {
                if ((1U & vlSelf->riscv__DOT__out_ins)) {
                    vlSelf->riscv__DOT__ALUOp = 0U;
                    vlSelf->riscv__DOT__ALUSrcB = 2U;
                    vlSelf->riscv__DOT__ExtSel = 1U;
                }
            }
        }
    }
    vlSelf->riscv__DOT__Imm32 = ((IData)(vlSelf->riscv__DOT__ExtSel)
                                  ? ((IData)(vlSelf->riscv__DOT__ExtSel)
                                      ? ((((vlSelf->riscv__DOT__out_ins 
                                            >> 0x1fU)
                                            ? 0xfffffU
                                            : 0U) << 0xcU) 
                                         | (vlSelf->riscv__DOT__out_ins 
                                            >> 0x14U))
                                      : 0U) : (vlSelf->riscv__DOT__out_ins 
                                               >> 0x14U));
    vlSelf->riscv__DOT__B = ((2U & (IData)(vlSelf->riscv__DOT__ALUSrcB))
                              ? ((1U & (IData)(vlSelf->riscv__DOT__ALUSrcB))
                                  ? vlSelf->riscv__DOT__RD2_r
                                  : (((- (IData)((1U 
                                                  & ((IData)(vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z) 
                                                     >> 0xbU)))) 
                                      << 0xcU) | (IData)(vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z)))
                              : ((1U & (IData)(vlSelf->riscv__DOT__ALUSrcB))
                                  ? vlSelf->riscv__DOT__Imm32
                                  : vlSelf->riscv__DOT__RD2_r));
    vlSelf->riscv__DOT__ALU_result = ((8U & (IData)(vlSelf->riscv__DOT__ALUOp))
                                       ? ((4U & (IData)(vlSelf->riscv__DOT__ALUOp))
                                           ? 0U : (
                                                   (2U 
                                                    & (IData)(vlSelf->riscv__DOT__ALUOp))
                                                    ? 
                                                   ((1U 
                                                     & (IData)(vlSelf->riscv__DOT__ALUOp))
                                                     ? 0U
                                                     : 
                                                    (vlSelf->riscv__DOT__RD1_r 
                                                     - vlSelf->riscv__DOT__B))
                                                    : 
                                                   ((1U 
                                                     & (IData)(vlSelf->riscv__DOT__ALUOp))
                                                     ? 
                                                    (vlSelf->riscv__DOT__RD1_r 
                                                     >> 
                                                     (0x1fU 
                                                      & vlSelf->riscv__DOT__B))
                                                     : 
                                                    (vlSelf->riscv__DOT__RD1_r 
                                                     << 
                                                     (0x1fU 
                                                      & vlSelf->riscv__DOT__B)))))
                                       : ((4U & (IData)(vlSelf->riscv__DOT__ALUOp))
                                           ? ((2U & (IData)(vlSelf->riscv__DOT__ALUOp))
                                               ? 0U
                                               : ((1U 
                                                   & (IData)(vlSelf->riscv__DOT__ALUOp))
                                                   ? 
                                                  VL_SHIFTRS_III(32,32,5, vlSelf->riscv__DOT__RD1_r, 
                                                                 (0x1fU 
                                                                  & vlSelf->riscv__DOT__B))
                                                   : 
                                                  (vlSelf->riscv__DOT__RD1_r 
                                                   ^ vlSelf->riscv__DOT__B)))
                                           : ((2U & (IData)(vlSelf->riscv__DOT__ALUOp))
                                               ? ((1U 
                                                   & (IData)(vlSelf->riscv__DOT__ALUOp))
                                                   ? 
                                                  (vlSelf->riscv__DOT__RD1_r 
                                                   | vlSelf->riscv__DOT__B)
                                                   : 
                                                  (vlSelf->riscv__DOT__RD1_r 
                                                   & vlSelf->riscv__DOT__B))
                                               : ((1U 
                                                   & (IData)(vlSelf->riscv__DOT__ALUOp))
                                                   ? 
                                                  (vlSelf->riscv__DOT__RD1_r 
                                                   - vlSelf->riscv__DOT__B)
                                                   : 
                                                  (vlSelf->riscv__DOT__RD1_r 
                                                   + vlSelf->riscv__DOT__B)))));
    vlSelf->riscv__DOT__NPCOp = 0U;
    if ((0x40U & vlSelf->riscv__DOT__out_ins)) {
        if ((0x20U & vlSelf->riscv__DOT__out_ins)) {
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 4U)))) {
                if ((8U & vlSelf->riscv__DOT__out_ins)) {
                    if ((4U & vlSelf->riscv__DOT__out_ins)) {
                        if ((2U & vlSelf->riscv__DOT__out_ins)) {
                            if ((1U & vlSelf->riscv__DOT__out_ins)) {
                                vlSelf->riscv__DOT__NPCOp = 3U;
                            }
                        }
                    }
                } else if ((4U & vlSelf->riscv__DOT__out_ins)) {
                    if ((2U & vlSelf->riscv__DOT__out_ins)) {
                        if ((1U & vlSelf->riscv__DOT__out_ins)) {
                            vlSelf->riscv__DOT__NPCOp = 2U;
                        }
                    }
                } else if ((2U & vlSelf->riscv__DOT__out_ins)) {
                    if ((1U & vlSelf->riscv__DOT__out_ins)) {
                        vlSelf->riscv__DOT__NPCOp = 
                            ((0U == (7U & (vlSelf->riscv__DOT__out_ins 
                                           >> 0xcU)))
                              ? ((0U == vlSelf->riscv__DOT__ALU_result)
                                  ? 1U : 0U) : ((1U 
                                                 == 
                                                 (7U 
                                                  & (vlSelf->riscv__DOT__out_ins 
                                                     >> 0xcU)))
                                                 ? 
                                                ((0U 
                                                  == vlSelf->riscv__DOT__ALU_result)
                                                  ? 0U
                                                  : 1U)
                                                 : 0U));
                    }
                }
            }
        }
    }
    vlSelf->riscv__DOT__NPC = ((2U & (IData)(vlSelf->riscv__DOT__NPCOp))
                                ? ((1U & (IData)(vlSelf->riscv__DOT__NPCOp))
                                    ? (vlSelf->riscv__DOT__PC 
                                       + (((- (IData)(
                                                      (vlSelf->riscv__DOT__out_ins 
                                                       >> 0x1fU))) 
                                           << 0x15U) 
                                          | ((0x100000U 
                                              & (vlSelf->riscv__DOT__out_ins 
                                                 >> 0xbU)) 
                                             | ((0xff000U 
                                                 & vlSelf->riscv__DOT__out_ins) 
                                                | ((0x800U 
                                                    & (vlSelf->riscv__DOT__out_ins 
                                                       >> 9U)) 
                                                   | (0x7feU 
                                                      & (vlSelf->riscv__DOT__out_ins 
                                                         >> 0x14U)))))))
                                    : (0xfffffffcU 
                                       & vlSelf->riscv__DOT__RD1))
                                : ((1U & (IData)(vlSelf->riscv__DOT__NPCOp))
                                    ? (vlSelf->riscv__DOT__PC 
                                       + (((- (IData)(
                                                      (1U 
                                                       & ((IData)(vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z) 
                                                          >> 0xbU)))) 
                                           << 0xdU) 
                                          | ((IData)(vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z) 
                                             << 1U)))
                                    : ((IData)(4U) 
                                       + vlSelf->riscv__DOT__PC)));
    if ((2U == (IData)(vlSelf->riscv__DOT__NPCOp))) {
        vlSelf->riscv__DOT__NPC = (0xfffffffeU & (VL_SHIFTL_III(32,32,32, 
                                                                (0xfffffffcU 
                                                                 & vlSelf->riscv__DOT__RD1), 2U) 
                                                  + 
                                                  (((- (IData)(
                                                               (1U 
                                                                & ((IData)(vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z) 
                                                                   >> 0xbU)))) 
                                                    << 0xcU) 
                                                   | (IData)(vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z))));
    }
}

VL_ATTR_COLD void Vriscv___024root___eval_stl(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_stl\n"); );
    // Body
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        Vriscv___024root___stl_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[3U] = 1U;
        vlSelf->__Vm_traceActivity[2U] = 1U;
        vlSelf->__Vm_traceActivity[1U] = 1U;
        vlSelf->__Vm_traceActivity[0U] = 1U;
    }
}

VL_ATTR_COLD void Vriscv___024root___eval_triggers__stl(Vriscv___024root* vlSelf);

VL_ATTR_COLD bool Vriscv___024root___eval_phase__stl(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_phase__stl\n"); );
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vriscv___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelf->__VstlTriggered.any();
    if (__VstlExecute) {
        Vriscv___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vriscv___024root___dump_triggers__act(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VactTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clk or posedge rst)\n");
    }
    if ((2ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @([changed] riscv.InsMemRW or [changed] riscv.__Vcellinp__U_IM__addr)\n");
    }
    if ((4ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 2 is active: @(posedge clk)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vriscv___024root___dump_triggers__nba(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clk or posedge rst)\n");
    }
    if ((2ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @([changed] riscv.InsMemRW or [changed] riscv.__Vcellinp__U_IM__addr)\n");
    }
    if ((4ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 2 is active: @(posedge clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vriscv___024root___ctor_var_reset(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clk = VL_RAND_RESET_I(1);
    vlSelf->rst = VL_RAND_RESET_I(1);
    vlSelf->done = VL_RAND_RESET_I(1);
    vlSelf->riscv__DOT__DMCtrl = VL_RAND_RESET_I(1);
    vlSelf->riscv__DOT__PCWrite = VL_RAND_RESET_I(1);
    vlSelf->riscv__DOT__InsMemRW = VL_RAND_RESET_I(1);
    vlSelf->riscv__DOT__ExtSel = VL_RAND_RESET_I(1);
    vlSelf->riscv__DOT__ALUSrcB = VL_RAND_RESET_I(2);
    vlSelf->riscv__DOT__NPCOp = VL_RAND_RESET_I(2);
    vlSelf->riscv__DOT__WDSel = VL_RAND_RESET_I(2);
    vlSelf->riscv__DOT__ALUOp = VL_RAND_RESET_I(4);
    vlSelf->riscv__DOT__PC = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__NPC = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__in_ins = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__out_ins = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__RD = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__Imm32 = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__WD = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__RD1 = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__RD1_r = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__RD2_r = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__B = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__ALU_result = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT__ALU_result_r = VL_RAND_RESET_I(32);
    vlSelf->riscv__DOT____Vcellinp__U_IM__addr = VL_RAND_RESET_I(10);
    vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z = VL_RAND_RESET_I(12);
    vlSelf->riscv__DOT__U_ControlUnit__DOT__State = VL_RAND_RESET_I(3);
    vlSelf->riscv__DOT__U_ControlUnit__DOT__NxtState = VL_RAND_RESET_I(3);
    vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = VL_RAND_RESET_I(1);
    vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = VL_RAND_RESET_I(1);
    vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = VL_RAND_RESET_I(1);
    vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = VL_RAND_RESET_I(1);
    vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 32; ++__Vi0) {
        vlSelf->riscv__DOT__U_RF__DOT__register[__Vi0] = VL_RAND_RESET_I(32);
    }
    for (int __Vi0 = 0; __Vi0 < 1024; ++__Vi0) {
        vlSelf->riscv__DOT__U_DM__DOT__memory[__Vi0] = VL_RAND_RESET_I(32);
    }
    vlSelf->__Vdlyvdim0__riscv__DOT__U_RF__DOT__register__v0 = 0;
    vlSelf->__Vdlyvval__riscv__DOT__U_RF__DOT__register__v0 = VL_RAND_RESET_I(32);
    vlSelf->__Vdlyvset__riscv__DOT__U_RF__DOT__register__v0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__clk__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__rst__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__riscv__DOT__InsMemRW__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__riscv__DOT____Vcellinp__U_IM__addr__0 = VL_RAND_RESET_I(10);
    vlSelf->__VactDidInit = 0;
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
