// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vriscv.h for the primary calling header

#include "Vriscv__pch.h"
#include "Vriscv___024root.h"

void Vriscv___024root___eval_act(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_act\n"); );
}

VL_INLINE_OPT void Vriscv___024root___nba_sequent__TOP__0(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___nba_sequent__TOP__0\n"); );
    // Init
    SData/*9:0*/ __Vdlyvdim0__riscv__DOT__U_DM__DOT__memory__v0;
    __Vdlyvdim0__riscv__DOT__U_DM__DOT__memory__v0 = 0;
    IData/*31:0*/ __Vdlyvval__riscv__DOT__U_DM__DOT__memory__v0;
    __Vdlyvval__riscv__DOT__U_DM__DOT__memory__v0 = 0;
    CData/*0:0*/ __Vdlyvset__riscv__DOT__U_DM__DOT__memory__v0;
    __Vdlyvset__riscv__DOT__U_DM__DOT__memory__v0 = 0;
    // Body
    vlSelf->__Vdlyvset__riscv__DOT__U_RF__DOT__register__v0 = 0U;
    __Vdlyvset__riscv__DOT__U_DM__DOT__memory__v0 = 0U;
    if (((0U != (0x1fU & (vlSelf->riscv__DOT__out_ins 
                          >> 7U))) & ((IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp) 
                                      & (5U == (IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__State))))) {
        vlSelf->__Vdlyvval__riscv__DOT__U_RF__DOT__register__v0 
            = vlSelf->riscv__DOT__WD;
        vlSelf->__Vdlyvset__riscv__DOT__U_RF__DOT__register__v0 = 1U;
        vlSelf->__Vdlyvdim0__riscv__DOT__U_RF__DOT__register__v0 
            = (0x1fU & (vlSelf->riscv__DOT__out_ins 
                        >> 7U));
    }
    if (vlSelf->riscv__DOT__DMCtrl) {
        __Vdlyvval__riscv__DOT__U_DM__DOT__memory__v0 
            = vlSelf->riscv__DOT__RD2_r;
        __Vdlyvset__riscv__DOT__U_DM__DOT__memory__v0 = 1U;
        __Vdlyvdim0__riscv__DOT__U_DM__DOT__memory__v0 
            = (0x3ffU & (vlSelf->riscv__DOT__ALU_result_r 
                         >> 2U));
    }
    if ((1U & (~ (IData)(vlSelf->riscv__DOT__DMCtrl)))) {
        vlSelf->riscv__DOT__RD = vlSelf->riscv__DOT__U_DM__DOT__memory
            [(0x3ffU & (vlSelf->riscv__DOT__ALU_result_r 
                        >> 2U))];
    }
    if (__Vdlyvset__riscv__DOT__U_DM__DOT__memory__v0) {
        vlSelf->riscv__DOT__U_DM__DOT__memory[__Vdlyvdim0__riscv__DOT__U_DM__DOT__memory__v0] 
            = __Vdlyvval__riscv__DOT__U_DM__DOT__memory__v0;
    }
}

VL_INLINE_OPT void Vriscv___024root___nba_sequent__TOP__1(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___nba_sequent__TOP__1\n"); );
    // Body
    if (vlSelf->rst) {
        vlSelf->riscv__DOT__RD1_r = 0U;
        vlSelf->riscv__DOT__PC = 0U;
        vlSelf->riscv__DOT__U_ControlUnit__DOT__State = 0U;
        vlSelf->riscv__DOT__RD2_r = 0U;
        vlSelf->riscv__DOT__ALU_result_r = 0U;
    } else {
        vlSelf->riscv__DOT__RD1_r = vlSelf->riscv__DOT__RD1;
        if (vlSelf->riscv__DOT__PCWrite) {
            vlSelf->riscv__DOT__PC = vlSelf->riscv__DOT__NPC;
        }
        vlSelf->riscv__DOT__U_ControlUnit__DOT__State 
            = vlSelf->riscv__DOT__U_ControlUnit__DOT__NxtState;
        vlSelf->riscv__DOT__RD2_r = vlSelf->riscv__DOT__U_RF__DOT__register
            [(0x1fU & (vlSelf->riscv__DOT__out_ins 
                       >> 0x14U))];
        vlSelf->riscv__DOT__ALU_result_r = vlSelf->riscv__DOT__ALU_result;
    }
    vlSelf->riscv__DOT__PCWrite = ((~ (IData)(vlSelf->rst)) 
                                   & (0U == (IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__NxtState)));
    vlSelf->done = (0U == (IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__State));
}

VL_INLINE_OPT void Vriscv___024root___nba_sequent__TOP__2(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___nba_sequent__TOP__2\n"); );
    // Body
    if (vlSelf->__Vdlyvset__riscv__DOT__U_RF__DOT__register__v0) {
        vlSelf->riscv__DOT__U_RF__DOT__register[vlSelf->__Vdlyvdim0__riscv__DOT__U_RF__DOT__register__v0] 
            = vlSelf->__Vdlyvval__riscv__DOT__U_RF__DOT__register__v0;
    }
    vlSelf->riscv__DOT__out_ins = vlSelf->riscv__DOT__in_ins;
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
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 1U;
                            vlSelf->riscv__DOT__WDSel = 2U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 0U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 1U;
                        }
                    }
                } else if ((2U & vlSelf->riscv__DOT__out_ins)) {
                    if ((1U & vlSelf->riscv__DOT__out_ins)) {
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 0U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 0U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 0U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 0U;
                    }
                }
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
                                vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
                                vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
                                vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 0U;
                                vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 1U;
                                vlSelf->riscv__DOT__ALUOp 
                                    = (((((((((0U == 
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
                                            | (6U == 
                                               ((0x3f8U 
                                                 & (vlSelf->riscv__DOT__out_ins 
                                                    >> 0x16U)) 
                                                | (7U 
                                                   & (vlSelf->riscv__DOT__out_ins 
                                                      >> 0xcU))))) 
                                           | (4U == 
                                              ((0x3f8U 
                                                & (vlSelf->riscv__DOT__out_ins 
                                                   >> 0x16U)) 
                                               | (7U 
                                                  & (vlSelf->riscv__DOT__out_ins 
                                                     >> 0xcU))))) 
                                          | (1U == 
                                             ((0x3f8U 
                                               & (vlSelf->riscv__DOT__out_ins 
                                                  >> 0x16U)) 
                                              | (7U 
                                                 & (vlSelf->riscv__DOT__out_ins 
                                                    >> 0xcU))))) 
                                         | (5U == (
                                                   (0x3f8U 
                                                    & (vlSelf->riscv__DOT__out_ins 
                                                       >> 0x16U)) 
                                                   | (7U 
                                                      & (vlSelf->riscv__DOT__out_ins 
                                                         >> 0xcU))))) 
                                        | (0x105U == 
                                           ((0x3f8U 
                                             & (vlSelf->riscv__DOT__out_ins 
                                                >> 0x16U)) 
                                            | (7U & 
                                               (vlSelf->riscv__DOT__out_ins 
                                                >> 0xcU)))))
                                        ? ((0U == (
                                                   (0x3f8U 
                                                    & (vlSelf->riscv__DOT__out_ins 
                                                       >> 0x16U)) 
                                                   | (7U 
                                                      & (vlSelf->riscv__DOT__out_ins 
                                                         >> 0xcU))))
                                            ? 0U : 
                                           ((0x100U 
                                             == ((0x3f8U 
                                                  & (vlSelf->riscv__DOT__out_ins 
                                                     >> 0x16U)) 
                                                 | (7U 
                                                    & (vlSelf->riscv__DOT__out_ins 
                                                       >> 0xcU))))
                                             ? 1U : 
                                            ((7U == 
                                              ((0x3f8U 
                                                & (vlSelf->riscv__DOT__out_ins 
                                                   >> 0x16U)) 
                                               | (7U 
                                                  & (vlSelf->riscv__DOT__out_ins 
                                                     >> 0xcU))))
                                              ? 2U : 
                                             ((6U == 
                                               ((0x3f8U 
                                                 & (vlSelf->riscv__DOT__out_ins 
                                                    >> 0x16U)) 
                                                | (7U 
                                                   & (vlSelf->riscv__DOT__out_ins 
                                                      >> 0xcU))))
                                               ? 3U
                                               : ((4U 
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
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 0U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 1U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 0U;
                            vlSelf->riscv__DOT__ALUOp = 0U;
                        }
                    }
                }
            }
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 4U)))) {
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
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 0U;
                            vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 1U;
                            if ((0U == (7U & (vlSelf->riscv__DOT__out_ins 
                                              >> 0xcU)))) {
                                vlSelf->riscv__DOT__ALUOp = 0U;
                                vlSelf->riscv__DOT__ExtSel = 1U;
                            } else if ((6U == (7U & 
                                               (vlSelf->riscv__DOT__out_ins 
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
            if ((1U & (~ (vlSelf->riscv__DOT__out_ins 
                          >> 2U)))) {
                if ((2U & vlSelf->riscv__DOT__out_ins)) {
                    if ((1U & vlSelf->riscv__DOT__out_ins)) {
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp = 1U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__EX = 1U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__AR = 1U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM = 1U;
                        vlSelf->riscv__DOT__U_ControlUnit__DOT__WB = 1U;
                        vlSelf->riscv__DOT__ALUOp = 0U;
                        vlSelf->riscv__DOT__ALUSrcB = 2U;
                        vlSelf->riscv__DOT__ExtSel = 1U;
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
}

void Vriscv___024root____Vdpiimwrap_riscv__DOT__U_IM__DOT__instFetch_TOP(IData/*31:0*/ addr, IData/*31:0*/ &instFetch__Vfuncrtn);

VL_INLINE_OPT void Vriscv___024root___nba_sequent__TOP__3(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___nba_sequent__TOP__3\n"); );
    // Init
    IData/*31:0*/ __Vfunc_riscv__DOT__U_IM__DOT__instFetch__0__Vfuncout;
    __Vfunc_riscv__DOT__U_IM__DOT__instFetch__0__Vfuncout = 0;
    // Body
    if (vlSelf->riscv__DOT__InsMemRW) {
        Vriscv___024root____Vdpiimwrap_riscv__DOT__U_IM__DOT__instFetch_TOP(vlSelf->riscv__DOT____Vcellinp__U_IM__addr, __Vfunc_riscv__DOT__U_IM__DOT__instFetch__0__Vfuncout);
        vlSelf->riscv__DOT__in_ins = __Vfunc_riscv__DOT__U_IM__DOT__instFetch__0__Vfuncout;
    }
}

extern const VlUnpacked<CData/*2:0*/, 128> Vriscv__ConstPool__TABLE_h3ef576a5_0;

VL_INLINE_OPT void Vriscv___024root___nba_comb__TOP__0(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___nba_comb__TOP__0\n"); );
    // Init
    CData/*6:0*/ __Vtableidx1;
    __Vtableidx1 = 0;
    // Body
    vlSelf->riscv__DOT__WD = ((2U & (IData)(vlSelf->riscv__DOT__WDSel))
                               ? ((1U & (IData)(vlSelf->riscv__DOT__WDSel))
                                   ? 0U : ((IData)(4U) 
                                           + vlSelf->riscv__DOT__PC))
                               : ((1U & (IData)(vlSelf->riscv__DOT__WDSel))
                                   ? vlSelf->riscv__DOT__RD
                                   : vlSelf->riscv__DOT__ALU_result_r));
    __Vtableidx1 = (((IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__EX) 
                     << 6U) | (((IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__AR) 
                                << 5U) | (((IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM) 
                                           << 4U) | 
                                          (((IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__WB) 
                                            << 3U) 
                                           | (IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__State)))));
    vlSelf->riscv__DOT__U_ControlUnit__DOT__NxtState 
        = Vriscv__ConstPool__TABLE_h3ef576a5_0[__Vtableidx1];
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

VL_INLINE_OPT void Vriscv___024root___nba_sequent__TOP__4(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___nba_sequent__TOP__4\n"); );
    // Body
    vlSelf->riscv__DOT____Vcellinp__U_IM__addr = (0x3ffU 
                                                  & (vlSelf->riscv__DOT__PC 
                                                     >> 2U));
}

void Vriscv___024root___eval_nba(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_nba\n"); );
    // Body
    if ((4ULL & vlSelf->__VnbaTriggered.word(0U))) {
        Vriscv___024root___nba_sequent__TOP__0(vlSelf);
    }
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        Vriscv___024root___nba_sequent__TOP__1(vlSelf);
        vlSelf->__Vm_traceActivity[1U] = 1U;
    }
    if ((4ULL & vlSelf->__VnbaTriggered.word(0U))) {
        Vriscv___024root___nba_sequent__TOP__2(vlSelf);
        vlSelf->__Vm_traceActivity[2U] = 1U;
    }
    if ((2ULL & vlSelf->__VnbaTriggered.word(0U))) {
        Vriscv___024root___nba_sequent__TOP__3(vlSelf);
    }
    if ((5ULL & vlSelf->__VnbaTriggered.word(0U))) {
        Vriscv___024root___nba_comb__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[3U] = 1U;
    }
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        Vriscv___024root___nba_sequent__TOP__4(vlSelf);
    }
}

void Vriscv___024root___eval_triggers__act(Vriscv___024root* vlSelf);

bool Vriscv___024root___eval_phase__act(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_phase__act\n"); );
    // Init
    VlTriggerVec<3> __VpreTriggered;
    CData/*0:0*/ __VactExecute;
    // Body
    Vriscv___024root___eval_triggers__act(vlSelf);
    __VactExecute = vlSelf->__VactTriggered.any();
    if (__VactExecute) {
        __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
        vlSelf->__VnbaTriggered.thisOr(vlSelf->__VactTriggered);
        Vriscv___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

bool Vriscv___024root___eval_phase__nba(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_phase__nba\n"); );
    // Init
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = vlSelf->__VnbaTriggered.any();
    if (__VnbaExecute) {
        Vriscv___024root___eval_nba(vlSelf);
        vlSelf->__VnbaTriggered.clear();
    }
    return (__VnbaExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vriscv___024root___dump_triggers__nba(Vriscv___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void Vriscv___024root___dump_triggers__act(Vriscv___024root* vlSelf);
#endif  // VL_DEBUG

void Vriscv___024root___eval(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval\n"); );
    // Init
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
            Vriscv___024root___dump_triggers__nba(vlSelf);
#endif
            VL_FATAL_MT("/home/pan/rv32-jichaung/cpu/rtl/rtl/riscv.v", 22, "", "NBA region did not converge.");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        __VnbaContinue = 0U;
        vlSelf->__VactIterCount = 0U;
        vlSelf->__VactContinue = 1U;
        while (vlSelf->__VactContinue) {
            if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                Vriscv___024root___dump_triggers__act(vlSelf);
#endif
                VL_FATAL_MT("/home/pan/rv32-jichaung/cpu/rtl/rtl/riscv.v", 22, "", "Active region did not converge.");
            }
            vlSelf->__VactIterCount = ((IData)(1U) 
                                       + vlSelf->__VactIterCount);
            vlSelf->__VactContinue = 0U;
            if (Vriscv___024root___eval_phase__act(vlSelf)) {
                vlSelf->__VactContinue = 1U;
            }
        }
        if (Vriscv___024root___eval_phase__nba(vlSelf)) {
            __VnbaContinue = 1U;
        }
    }
}

#ifdef VL_DEBUG
void Vriscv___024root___eval_debug_assertions(Vriscv___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->clk & 0xfeU))) {
        Verilated::overWidthError("clk");}
    if (VL_UNLIKELY((vlSelf->rst & 0xfeU))) {
        Verilated::overWidthError("rst");}
}
#endif  // VL_DEBUG
