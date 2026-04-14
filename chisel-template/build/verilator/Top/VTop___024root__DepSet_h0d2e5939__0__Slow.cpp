// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VTop.h for the primary calling header

#include "verilated.h"

#include "VTop___024root.h"

VL_ATTR_COLD void VTop___024root___eval_static(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___eval_static\n"); );
}

VL_ATTR_COLD void VTop___024root___eval_initial(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___eval_initial\n"); );
    // Body
    vlSelf->__Vtrigrprev__TOP__clock = vlSelf->clock;
}

VL_ATTR_COLD void VTop___024root___eval_final(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___eval_final\n"); );
}

VL_ATTR_COLD void VTop___024root___eval_triggers__stl(VTop___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void VTop___024root___dump_triggers__stl(VTop___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD void VTop___024root___eval_stl(VTop___024root* vlSelf);

VL_ATTR_COLD void VTop___024root___eval_settle(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___eval_settle\n"); );
    // Init
    CData/*0:0*/ __VstlContinue;
    // Body
    vlSelf->__VstlIterCount = 0U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        __VstlContinue = 0U;
        VTop___024root___eval_triggers__stl(vlSelf);
        if (vlSelf->__VstlTriggered.any()) {
            __VstlContinue = 1U;
            if (VL_UNLIKELY((0x64U < vlSelf->__VstlIterCount))) {
#ifdef VL_DEBUG
                VTop___024root___dump_triggers__stl(vlSelf);
#endif
                VL_FATAL_MT("/home/simly/Files/coachip/rv32i/chisel-template/generated/Top/Top.v", 971, "", "Settle region did not converge.");
            }
            vlSelf->__VstlIterCount = ((IData)(1U) 
                                       + vlSelf->__VstlIterCount);
            VTop___024root___eval_stl(vlSelf);
        }
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VTop___024root___dump_triggers__stl(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VstlTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VstlTriggered.at(0U)) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VTop___024root___stl_sequent__TOP__0(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___stl_sequent__TOP__0\n"); );
    // Init
    CData/*0:0*/ Top__DOT__decoder__DOT___GEN_14;
    Top__DOT__decoder__DOT___GEN_14 = 0;
    CData/*0:0*/ Top__DOT__decoder__DOT___GEN_22;
    Top__DOT__decoder__DOT___GEN_22 = 0;
    CData/*0:0*/ Top__DOT__decoder__DOT___GEN_23;
    Top__DOT__decoder__DOT___GEN_23 = 0;
    IData/*31:0*/ Top__DOT__registers__DOT___GEN_13;
    Top__DOT__registers__DOT___GEN_13 = 0;
    IData/*31:0*/ Top__DOT__registers__DOT___GEN_26;
    Top__DOT__registers__DOT___GEN_26 = 0;
    IData/*31:0*/ Top__DOT__registers__DOT___GEN_46;
    Top__DOT__registers__DOT___GEN_46 = 0;
    IData/*31:0*/ Top__DOT__registers__DOT___GEN_59;
    Top__DOT__registers__DOT___GEN_59 = 0;
    IData/*31:0*/ Top__DOT__alu__DOT___resultAlu_T_18;
    Top__DOT__alu__DOT___resultAlu_T_18 = 0;
    QData/*62:0*/ Top__DOT__alu__DOT___GEN_16;
    Top__DOT__alu__DOT___GEN_16 = 0;
    // Body
    vlSelf->io_addr = vlSelf->Top__DOT__pcReg__DOT__regPC;
    vlSelf->Top__DOT__pcReg__DOT___regPC_T_1 = ((IData)(4U) 
                                                + vlSelf->Top__DOT__pcReg__DOT__regPC);
    vlSelf->io_inst = vlSelf->Top__DOT__memInst__DOT__mem
        [(0x3ffU & (vlSelf->Top__DOT__pcReg__DOT__regPC 
                    >> 2U))];
    vlSelf->io_bundleCtrl_ctrlStore = ((0x33U != (0x7fU 
                                                  & vlSelf->io_inst)) 
                                       & ((0x13U != 
                                           (0x7fU & vlSelf->io_inst)) 
                                          & ((3U != 
                                              (0x7fU 
                                               & vlSelf->io_inst)) 
                                             & ((0x67U 
                                                 != 
                                                 (0x7fU 
                                                  & vlSelf->io_inst)) 
                                                & (0x23U 
                                                   == 
                                                   (0x7fU 
                                                    & vlSelf->io_inst))))));
    vlSelf->io_bundleCtrl_ctrlBranch = ((0x33U != (0x7fU 
                                                   & vlSelf->io_inst)) 
                                        & ((0x13U != 
                                            (0x7fU 
                                             & vlSelf->io_inst)) 
                                           & ((3U != 
                                               (0x7fU 
                                                & vlSelf->io_inst)) 
                                              & ((0x67U 
                                                  != 
                                                  (0x7fU 
                                                   & vlSelf->io_inst)) 
                                                 & ((0x23U 
                                                     != 
                                                     (0x7fU 
                                                      & vlSelf->io_inst)) 
                                                    & (0x63U 
                                                       == 
                                                       (0x7fU 
                                                        & vlSelf->io_inst)))))));
    vlSelf->io_bundleCtrl_ctrlLoad = ((0x33U != (0x7fU 
                                                 & vlSelf->io_inst)) 
                                      & ((0x13U != 
                                          (0x7fU & vlSelf->io_inst)) 
                                         & (3U == (0x7fU 
                                                   & vlSelf->io_inst))));
    if ((0x33U == (0x7fU & vlSelf->io_inst))) {
        vlSelf->io_bundleCtrl_ctrlOP = ((0U == (7U 
                                                & (vlSelf->io_inst 
                                                   >> 0xcU)))
                                         ? ((0x40000000U 
                                             & vlSelf->io_inst)
                                             ? 2U : 1U)
                                         : ((7U == 
                                             (7U & 
                                              (vlSelf->io_inst 
                                               >> 0xcU)))
                                             ? 4U : 
                                            ((6U == 
                                              (7U & 
                                               (vlSelf->io_inst 
                                                >> 0xcU)))
                                              ? 5U : 
                                             ((1U == 
                                               (7U 
                                                & (vlSelf->io_inst 
                                                   >> 0xcU)))
                                               ? 8U
                                               : ((5U 
                                                   == 
                                                   (7U 
                                                    & (vlSelf->io_inst 
                                                       >> 0xcU)))
                                                   ? 9U
                                                   : 1U)))));
        vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel = 0U;
    } else if ((0x13U == (0x7fU & vlSelf->io_inst))) {
        vlSelf->io_bundleCtrl_ctrlOP = ((0U == (7U 
                                                & (vlSelf->io_inst 
                                                   >> 0xcU)))
                                         ? 1U : ((6U 
                                                  == 
                                                  (7U 
                                                   & (vlSelf->io_inst 
                                                      >> 0xcU)))
                                                  ? 5U
                                                  : 1U));
        vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel = 1U;
    } else if ((3U == (0x7fU & vlSelf->io_inst))) {
        vlSelf->io_bundleCtrl_ctrlOP = 1U;
        vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel = 1U;
    } else if ((0x67U == (0x7fU & vlSelf->io_inst))) {
        vlSelf->io_bundleCtrl_ctrlOP = 1U;
        vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel = 1U;
    } else if ((0x23U == (0x7fU & vlSelf->io_inst))) {
        vlSelf->io_bundleCtrl_ctrlOP = 1U;
        vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel = 2U;
    } else if ((0x63U == (0x7fU & vlSelf->io_inst))) {
        vlSelf->io_bundleCtrl_ctrlOP = ((0U == (7U 
                                                & (vlSelf->io_inst 
                                                   >> 0xcU)))
                                         ? 0xcU : (
                                                   (1U 
                                                    == 
                                                    (7U 
                                                     & (vlSelf->io_inst 
                                                        >> 0xcU)))
                                                    ? 0xdU
                                                    : 1U));
        vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel = 3U;
    } else {
        vlSelf->io_bundleCtrl_ctrlOP = 1U;
        vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel 
            = ((0x6fU == (0x7fU & vlSelf->io_inst))
                ? 4U : 0U);
    }
    Top__DOT__registers__DOT___GEN_13 = ((0xdU == (0x1fU 
                                                   & (vlSelf->io_inst 
                                                      >> 0xfU)))
                                          ? vlSelf->Top__DOT__registers__DOT__regs_13
                                          : ((0xcU 
                                              == (0x1fU 
                                                  & (vlSelf->io_inst 
                                                     >> 0xfU)))
                                              ? vlSelf->Top__DOT__registers__DOT__regs_12
                                              : ((0xbU 
                                                  == 
                                                  (0x1fU 
                                                   & (vlSelf->io_inst 
                                                      >> 0xfU)))
                                                  ? vlSelf->Top__DOT__registers__DOT__regs_11
                                                  : 
                                                 ((0xaU 
                                                   == 
                                                   (0x1fU 
                                                    & (vlSelf->io_inst 
                                                       >> 0xfU)))
                                                   ? vlSelf->Top__DOT__registers__DOT__regs_10
                                                   : 
                                                  ((9U 
                                                    == 
                                                    (0x1fU 
                                                     & (vlSelf->io_inst 
                                                        >> 0xfU)))
                                                    ? vlSelf->Top__DOT__registers__DOT__regs_9
                                                    : 
                                                   ((8U 
                                                     == 
                                                     (0x1fU 
                                                      & (vlSelf->io_inst 
                                                         >> 0xfU)))
                                                     ? vlSelf->Top__DOT__registers__DOT__regs_8
                                                     : 
                                                    ((7U 
                                                      == 
                                                      (0x1fU 
                                                       & (vlSelf->io_inst 
                                                          >> 0xfU)))
                                                      ? vlSelf->Top__DOT__registers__DOT__regs_7
                                                      : 
                                                     ((6U 
                                                       == 
                                                       (0x1fU 
                                                        & (vlSelf->io_inst 
                                                           >> 0xfU)))
                                                       ? vlSelf->Top__DOT__registers__DOT__regs_6
                                                       : 
                                                      ((5U 
                                                        == 
                                                        (0x1fU 
                                                         & (vlSelf->io_inst 
                                                            >> 0xfU)))
                                                        ? vlSelf->Top__DOT__registers__DOT__regs_5
                                                        : 
                                                       ((4U 
                                                         == 
                                                         (0x1fU 
                                                          & (vlSelf->io_inst 
                                                             >> 0xfU)))
                                                         ? vlSelf->Top__DOT__registers__DOT__regs_4
                                                         : 
                                                        ((3U 
                                                          == 
                                                          (0x1fU 
                                                           & (vlSelf->io_inst 
                                                              >> 0xfU)))
                                                          ? vlSelf->Top__DOT__registers__DOT__regs_3
                                                          : 
                                                         ((2U 
                                                           == 
                                                           (0x1fU 
                                                            & (vlSelf->io_inst 
                                                               >> 0xfU)))
                                                           ? vlSelf->Top__DOT__registers__DOT__regs_2
                                                           : 
                                                          ((1U 
                                                            == 
                                                            (0x1fU 
                                                             & (vlSelf->io_inst 
                                                                >> 0xfU)))
                                                            ? vlSelf->Top__DOT__registers__DOT__regs_1
                                                            : vlSelf->Top__DOT__registers__DOT__regs_0)))))))))))));
    Top__DOT__registers__DOT___GEN_46 = ((0xdU == (0x1fU 
                                                   & (vlSelf->io_inst 
                                                      >> 0x14U)))
                                          ? vlSelf->Top__DOT__registers__DOT__regs_13
                                          : ((0xcU 
                                              == (0x1fU 
                                                  & (vlSelf->io_inst 
                                                     >> 0x14U)))
                                              ? vlSelf->Top__DOT__registers__DOT__regs_12
                                              : ((0xbU 
                                                  == 
                                                  (0x1fU 
                                                   & (vlSelf->io_inst 
                                                      >> 0x14U)))
                                                  ? vlSelf->Top__DOT__registers__DOT__regs_11
                                                  : 
                                                 ((0xaU 
                                                   == 
                                                   (0x1fU 
                                                    & (vlSelf->io_inst 
                                                       >> 0x14U)))
                                                   ? vlSelf->Top__DOT__registers__DOT__regs_10
                                                   : 
                                                  ((9U 
                                                    == 
                                                    (0x1fU 
                                                     & (vlSelf->io_inst 
                                                        >> 0x14U)))
                                                    ? vlSelf->Top__DOT__registers__DOT__regs_9
                                                    : 
                                                   ((8U 
                                                     == 
                                                     (0x1fU 
                                                      & (vlSelf->io_inst 
                                                         >> 0x14U)))
                                                     ? vlSelf->Top__DOT__registers__DOT__regs_8
                                                     : 
                                                    ((7U 
                                                      == 
                                                      (0x1fU 
                                                       & (vlSelf->io_inst 
                                                          >> 0x14U)))
                                                      ? vlSelf->Top__DOT__registers__DOT__regs_7
                                                      : 
                                                     ((6U 
                                                       == 
                                                       (0x1fU 
                                                        & (vlSelf->io_inst 
                                                           >> 0x14U)))
                                                       ? vlSelf->Top__DOT__registers__DOT__regs_6
                                                       : 
                                                      ((5U 
                                                        == 
                                                        (0x1fU 
                                                         & (vlSelf->io_inst 
                                                            >> 0x14U)))
                                                        ? vlSelf->Top__DOT__registers__DOT__regs_5
                                                        : 
                                                       ((4U 
                                                         == 
                                                         (0x1fU 
                                                          & (vlSelf->io_inst 
                                                             >> 0x14U)))
                                                         ? vlSelf->Top__DOT__registers__DOT__regs_4
                                                         : 
                                                        ((3U 
                                                          == 
                                                          (0x1fU 
                                                           & (vlSelf->io_inst 
                                                              >> 0x14U)))
                                                          ? vlSelf->Top__DOT__registers__DOT__regs_3
                                                          : 
                                                         ((2U 
                                                           == 
                                                           (0x1fU 
                                                            & (vlSelf->io_inst 
                                                               >> 0x14U)))
                                                           ? vlSelf->Top__DOT__registers__DOT__regs_2
                                                           : 
                                                          ((1U 
                                                            == 
                                                            (0x1fU 
                                                             & (vlSelf->io_inst 
                                                                >> 0x14U)))
                                                            ? vlSelf->Top__DOT__registers__DOT__regs_1
                                                            : vlSelf->Top__DOT__registers__DOT__regs_0)))))))))))));
    Top__DOT__decoder__DOT___GEN_14 = ((0x63U != (0x7fU 
                                                  & vlSelf->io_inst)) 
                                       & (0x6fU == 
                                          (0x7fU & vlSelf->io_inst)));
    vlSelf->io_ctrlBranchToPc = vlSelf->io_bundleCtrl_ctrlBranch;
    vlSelf->io_imm = ((1U == (IData)(vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel))
                       ? ((((vlSelf->io_inst >> 0x1fU)
                             ? 0xfffffU : 0U) << 0xcU) 
                          | (vlSelf->io_inst >> 0x14U))
                       : ((2U == (IData)(vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel))
                           ? ((((vlSelf->io_inst >> 0x1fU)
                                 ? 0xfffffU : 0U) << 0xcU) 
                              | ((0xfe0U & (vlSelf->io_inst 
                                            >> 0x14U)) 
                                 | (0x1fU & (vlSelf->io_inst 
                                             >> 7U))))
                           : ((3U == (IData)(vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel))
                               ? ((((vlSelf->io_inst 
                                     >> 0x1fU) ? 0x7ffffU
                                     : 0U) << 0xdU) 
                                  | ((0x1000U & (vlSelf->io_inst 
                                                 >> 0x13U)) 
                                     | ((0x800U & (vlSelf->io_inst 
                                                   << 4U)) 
                                        | ((0x7e0U 
                                            & (vlSelf->io_inst 
                                               >> 0x14U)) 
                                           | (0x1eU 
                                              & (vlSelf->io_inst 
                                                 >> 7U))))))
                               : ((4U == (IData)(vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel))
                                   ? ((((vlSelf->io_inst 
                                         >> 0x1fU) ? 0x7ffU
                                         : 0U) << 0x15U) 
                                      | ((0x100000U 
                                          & (vlSelf->io_inst 
                                             >> 0xbU)) 
                                         | ((0xff000U 
                                             & vlSelf->io_inst) 
                                            | ((0x800U 
                                                & (vlSelf->io_inst 
                                                   >> 9U)) 
                                               | (0x7feU 
                                                  & (vlSelf->io_inst 
                                                     >> 0x14U))))))
                                   : 0U))));
    Top__DOT__registers__DOT___GEN_26 = ((0x1aU == 
                                          (0x1fU & 
                                           (vlSelf->io_inst 
                                            >> 0xfU)))
                                          ? vlSelf->Top__DOT__registers__DOT__regs_26
                                          : ((0x19U 
                                              == (0x1fU 
                                                  & (vlSelf->io_inst 
                                                     >> 0xfU)))
                                              ? vlSelf->Top__DOT__registers__DOT__regs_25
                                              : ((0x18U 
                                                  == 
                                                  (0x1fU 
                                                   & (vlSelf->io_inst 
                                                      >> 0xfU)))
                                                  ? vlSelf->Top__DOT__registers__DOT__regs_24
                                                  : 
                                                 ((0x17U 
                                                   == 
                                                   (0x1fU 
                                                    & (vlSelf->io_inst 
                                                       >> 0xfU)))
                                                   ? vlSelf->Top__DOT__registers__DOT__regs_23
                                                   : 
                                                  ((0x16U 
                                                    == 
                                                    (0x1fU 
                                                     & (vlSelf->io_inst 
                                                        >> 0xfU)))
                                                    ? vlSelf->Top__DOT__registers__DOT__regs_22
                                                    : 
                                                   ((0x15U 
                                                     == 
                                                     (0x1fU 
                                                      & (vlSelf->io_inst 
                                                         >> 0xfU)))
                                                     ? vlSelf->Top__DOT__registers__DOT__regs_21
                                                     : 
                                                    ((0x14U 
                                                      == 
                                                      (0x1fU 
                                                       & (vlSelf->io_inst 
                                                          >> 0xfU)))
                                                      ? vlSelf->Top__DOT__registers__DOT__regs_20
                                                      : 
                                                     ((0x13U 
                                                       == 
                                                       (0x1fU 
                                                        & (vlSelf->io_inst 
                                                           >> 0xfU)))
                                                       ? vlSelf->Top__DOT__registers__DOT__regs_19
                                                       : 
                                                      ((0x12U 
                                                        == 
                                                        (0x1fU 
                                                         & (vlSelf->io_inst 
                                                            >> 0xfU)))
                                                        ? vlSelf->Top__DOT__registers__DOT__regs_18
                                                        : 
                                                       ((0x11U 
                                                         == 
                                                         (0x1fU 
                                                          & (vlSelf->io_inst 
                                                             >> 0xfU)))
                                                         ? vlSelf->Top__DOT__registers__DOT__regs_17
                                                         : 
                                                        ((0x10U 
                                                          == 
                                                          (0x1fU 
                                                           & (vlSelf->io_inst 
                                                              >> 0xfU)))
                                                          ? vlSelf->Top__DOT__registers__DOT__regs_16
                                                          : 
                                                         ((0xfU 
                                                           == 
                                                           (0x1fU 
                                                            & (vlSelf->io_inst 
                                                               >> 0xfU)))
                                                           ? vlSelf->Top__DOT__registers__DOT__regs_15
                                                           : 
                                                          ((0xeU 
                                                            == 
                                                            (0x1fU 
                                                             & (vlSelf->io_inst 
                                                                >> 0xfU)))
                                                            ? vlSelf->Top__DOT__registers__DOT__regs_14
                                                            : Top__DOT__registers__DOT___GEN_13)))))))))))));
    Top__DOT__registers__DOT___GEN_59 = ((0x1aU == 
                                          (0x1fU & 
                                           (vlSelf->io_inst 
                                            >> 0x14U)))
                                          ? vlSelf->Top__DOT__registers__DOT__regs_26
                                          : ((0x19U 
                                              == (0x1fU 
                                                  & (vlSelf->io_inst 
                                                     >> 0x14U)))
                                              ? vlSelf->Top__DOT__registers__DOT__regs_25
                                              : ((0x18U 
                                                  == 
                                                  (0x1fU 
                                                   & (vlSelf->io_inst 
                                                      >> 0x14U)))
                                                  ? vlSelf->Top__DOT__registers__DOT__regs_24
                                                  : 
                                                 ((0x17U 
                                                   == 
                                                   (0x1fU 
                                                    & (vlSelf->io_inst 
                                                       >> 0x14U)))
                                                   ? vlSelf->Top__DOT__registers__DOT__regs_23
                                                   : 
                                                  ((0x16U 
                                                    == 
                                                    (0x1fU 
                                                     & (vlSelf->io_inst 
                                                        >> 0x14U)))
                                                    ? vlSelf->Top__DOT__registers__DOT__regs_22
                                                    : 
                                                   ((0x15U 
                                                     == 
                                                     (0x1fU 
                                                      & (vlSelf->io_inst 
                                                         >> 0x14U)))
                                                     ? vlSelf->Top__DOT__registers__DOT__regs_21
                                                     : 
                                                    ((0x14U 
                                                      == 
                                                      (0x1fU 
                                                       & (vlSelf->io_inst 
                                                          >> 0x14U)))
                                                      ? vlSelf->Top__DOT__registers__DOT__regs_20
                                                      : 
                                                     ((0x13U 
                                                       == 
                                                       (0x1fU 
                                                        & (vlSelf->io_inst 
                                                           >> 0x14U)))
                                                       ? vlSelf->Top__DOT__registers__DOT__regs_19
                                                       : 
                                                      ((0x12U 
                                                        == 
                                                        (0x1fU 
                                                         & (vlSelf->io_inst 
                                                            >> 0x14U)))
                                                        ? vlSelf->Top__DOT__registers__DOT__regs_18
                                                        : 
                                                       ((0x11U 
                                                         == 
                                                         (0x1fU 
                                                          & (vlSelf->io_inst 
                                                             >> 0x14U)))
                                                         ? vlSelf->Top__DOT__registers__DOT__regs_17
                                                         : 
                                                        ((0x10U 
                                                          == 
                                                          (0x1fU 
                                                           & (vlSelf->io_inst 
                                                              >> 0x14U)))
                                                          ? vlSelf->Top__DOT__registers__DOT__regs_16
                                                          : 
                                                         ((0xfU 
                                                           == 
                                                           (0x1fU 
                                                            & (vlSelf->io_inst 
                                                               >> 0x14U)))
                                                           ? vlSelf->Top__DOT__registers__DOT__regs_15
                                                           : 
                                                          ((0xeU 
                                                            == 
                                                            (0x1fU 
                                                             & (vlSelf->io_inst 
                                                                >> 0x14U)))
                                                            ? vlSelf->Top__DOT__registers__DOT__regs_14
                                                            : Top__DOT__registers__DOT___GEN_46)))))))))))));
    vlSelf->io_bundleCtrl_ctrlALUSrc = ((0x33U != (0x7fU 
                                                   & vlSelf->io_inst)) 
                                        & ((0x13U == 
                                            (0x7fU 
                                             & vlSelf->io_inst)) 
                                           | ((3U == 
                                               (0x7fU 
                                                & vlSelf->io_inst)) 
                                              | ((0x67U 
                                                  == 
                                                  (0x7fU 
                                                   & vlSelf->io_inst)) 
                                                 | ((0x23U 
                                                     == 
                                                     (0x7fU 
                                                      & vlSelf->io_inst)) 
                                                    | (IData)(Top__DOT__decoder__DOT___GEN_14))))));
    Top__DOT__decoder__DOT___GEN_22 = ((0x23U != (0x7fU 
                                                  & vlSelf->io_inst)) 
                                       & (IData)(Top__DOT__decoder__DOT___GEN_14));
    Top__DOT__alu__DOT___resultAlu_T_18 = (vlSelf->io_imm 
                                           + vlSelf->Top__DOT__pcReg__DOT__regPC);
    vlSelf->io_rs1 = ((0U == (0x1fU & (vlSelf->io_inst 
                                       >> 0xfU))) ? 0U
                       : ((0x1fU == (0x1fU & (vlSelf->io_inst 
                                              >> 0xfU)))
                           ? vlSelf->Top__DOT__registers__DOT__regs_31
                           : ((0x1eU == (0x1fU & (vlSelf->io_inst 
                                                  >> 0xfU)))
                               ? vlSelf->Top__DOT__registers__DOT__regs_30
                               : ((0x1dU == (0x1fU 
                                             & (vlSelf->io_inst 
                                                >> 0xfU)))
                                   ? vlSelf->Top__DOT__registers__DOT__regs_29
                                   : ((0x1cU == (0x1fU 
                                                 & (vlSelf->io_inst 
                                                    >> 0xfU)))
                                       ? vlSelf->Top__DOT__registers__DOT__regs_28
                                       : ((0x1bU == 
                                           (0x1fU & 
                                            (vlSelf->io_inst 
                                             >> 0xfU)))
                                           ? vlSelf->Top__DOT__registers__DOT__regs_27
                                           : Top__DOT__registers__DOT___GEN_26))))));
    vlSelf->io_rs2 = ((0U == (0x1fU & (vlSelf->io_inst 
                                       >> 0x14U))) ? 0U
                       : ((0x1fU == (0x1fU & (vlSelf->io_inst 
                                              >> 0x14U)))
                           ? vlSelf->Top__DOT__registers__DOT__regs_31
                           : ((0x1eU == (0x1fU & (vlSelf->io_inst 
                                                  >> 0x14U)))
                               ? vlSelf->Top__DOT__registers__DOT__regs_30
                               : ((0x1dU == (0x1fU 
                                             & (vlSelf->io_inst 
                                                >> 0x14U)))
                                   ? vlSelf->Top__DOT__registers__DOT__regs_29
                                   : ((0x1cU == (0x1fU 
                                                 & (vlSelf->io_inst 
                                                    >> 0x14U)))
                                       ? vlSelf->Top__DOT__registers__DOT__regs_28
                                       : ((0x1bU == 
                                           (0x1fU & 
                                            (vlSelf->io_inst 
                                             >> 0x14U)))
                                           ? vlSelf->Top__DOT__registers__DOT__regs_27
                                           : Top__DOT__registers__DOT___GEN_59))))));
    Top__DOT__decoder__DOT___GEN_23 = ((0x67U == (0x7fU 
                                                  & vlSelf->io_inst)) 
                                       | (IData)(Top__DOT__decoder__DOT___GEN_22));
    vlSelf->io_bundleCtrl_ctrlJAL = ((0x33U != (0x7fU 
                                                & vlSelf->io_inst)) 
                                     & ((0x13U != (0x7fU 
                                                   & vlSelf->io_inst)) 
                                        & ((3U != (0x7fU 
                                                   & vlSelf->io_inst)) 
                                           & ((0x67U 
                                               != (0x7fU 
                                                   & vlSelf->io_inst)) 
                                              & (IData)(Top__DOT__decoder__DOT___GEN_22)))));
    vlSelf->Top__DOT__alu__DOT__operand2 = ((IData)(vlSelf->io_bundleCtrl_ctrlALUSrc)
                                             ? vlSelf->io_imm
                                             : vlSelf->io_rs2);
    vlSelf->io_bundleCtrl_ctrlRegWrite = ((0x33U == 
                                           (0x7fU & vlSelf->io_inst)) 
                                          | ((0x13U 
                                              == (0x7fU 
                                                  & vlSelf->io_inst)) 
                                             | ((3U 
                                                 == 
                                                 (0x7fU 
                                                  & vlSelf->io_inst)) 
                                                | (IData)(Top__DOT__decoder__DOT___GEN_23))));
    vlSelf->io_bundleCtrl_ctrlJump = ((0x33U != (0x7fU 
                                                 & vlSelf->io_inst)) 
                                      & ((0x13U != 
                                          (0x7fU & vlSelf->io_inst)) 
                                         & ((3U != 
                                             (0x7fU 
                                              & vlSelf->io_inst)) 
                                            & (IData)(Top__DOT__decoder__DOT___GEN_23))));
    vlSelf->Top__DOT__alu__DOT__operand1 = ((IData)(vlSelf->io_bundleCtrl_ctrlJAL)
                                             ? vlSelf->Top__DOT__pcReg__DOT__regPC
                                             : vlSelf->io_rs1);
    vlSelf->io_ctrlJumpToPc = vlSelf->io_bundleCtrl_ctrlJump;
    vlSelf->io_resultBranch = ((0U != (IData)(vlSelf->io_bundleCtrl_ctrlOP)) 
                               & ((1U != (IData)(vlSelf->io_bundleCtrl_ctrlOP)) 
                                  & ((2U != (IData)(vlSelf->io_bundleCtrl_ctrlOP)) 
                                     & ((4U != (IData)(vlSelf->io_bundleCtrl_ctrlOP)) 
                                        & ((5U != (IData)(vlSelf->io_bundleCtrl_ctrlOP)) 
                                           & ((8U != (IData)(vlSelf->io_bundleCtrl_ctrlOP)) 
                                              & ((9U 
                                                  != (IData)(vlSelf->io_bundleCtrl_ctrlOP)) 
                                                 & ((0xbU 
                                                     != (IData)(vlSelf->io_bundleCtrl_ctrlOP)) 
                                                    & ((0xcU 
                                                        == (IData)(vlSelf->io_bundleCtrl_ctrlOP))
                                                        ? 
                                                       (vlSelf->Top__DOT__alu__DOT__operand1 
                                                        == vlSelf->Top__DOT__alu__DOT__operand2)
                                                        : 
                                                       ((0xdU 
                                                         == (IData)(vlSelf->io_bundleCtrl_ctrlOP)) 
                                                        & (vlSelf->Top__DOT__alu__DOT__operand1 
                                                           != vlSelf->Top__DOT__alu__DOT__operand2)))))))))));
    vlSelf->Top__DOT__alu__DOT__addResult = (vlSelf->Top__DOT__alu__DOT__operand1 
                                             + vlSelf->Top__DOT__alu__DOT__operand2);
    Top__DOT__alu__DOT___GEN_16 = (0x7fffffffffffffffULL 
                                   & ((1U == (IData)(vlSelf->io_bundleCtrl_ctrlOP))
                                       ? (QData)((IData)(
                                                         (((~ (IData)(vlSelf->io_bundleCtrl_ctrlJAL)) 
                                                           & (IData)(vlSelf->io_bundleCtrl_ctrlJump))
                                                           ? 
                                                          (0xfffffffeU 
                                                           & vlSelf->Top__DOT__alu__DOT__addResult)
                                                           : vlSelf->Top__DOT__alu__DOT__addResult)))
                                       : ((2U == (IData)(vlSelf->io_bundleCtrl_ctrlOP))
                                           ? (QData)((IData)(
                                                             (vlSelf->Top__DOT__alu__DOT__operand1 
                                                              - vlSelf->Top__DOT__alu__DOT__operand2)))
                                           : ((4U == (IData)(vlSelf->io_bundleCtrl_ctrlOP))
                                               ? (QData)((IData)(
                                                                 (vlSelf->Top__DOT__alu__DOT__operand1 
                                                                  & vlSelf->Top__DOT__alu__DOT__operand2)))
                                               : ((5U 
                                                   == (IData)(vlSelf->io_bundleCtrl_ctrlOP))
                                                   ? (QData)((IData)(
                                                                     (vlSelf->Top__DOT__alu__DOT__operand1 
                                                                      | vlSelf->Top__DOT__alu__DOT__operand2)))
                                                   : 
                                                  ((8U 
                                                    == (IData)(vlSelf->io_bundleCtrl_ctrlOP))
                                                    ? 
                                                   ((QData)((IData)(vlSelf->Top__DOT__alu__DOT__operand1)) 
                                                    << 
                                                    (0x1fU 
                                                     & vlSelf->Top__DOT__alu__DOT__operand2))
                                                    : (QData)((IData)(
                                                                      ((9U 
                                                                        == (IData)(vlSelf->io_bundleCtrl_ctrlOP))
                                                                        ? 
                                                                       (vlSelf->Top__DOT__alu__DOT__operand1 
                                                                        >> 
                                                                        (0x1fU 
                                                                         & vlSelf->Top__DOT__alu__DOT__operand2))
                                                                        : 
                                                                       ((0xbU 
                                                                         == (IData)(vlSelf->io_bundleCtrl_ctrlOP))
                                                                         ? 
                                                                        VL_SHIFTRS_III(32,32,5, vlSelf->Top__DOT__alu__DOT__operand1, 
                                                                                (0x1fU 
                                                                                & vlSelf->Top__DOT__alu__DOT__operand2))
                                                                         : 
                                                                        ((0xcU 
                                                                          == (IData)(vlSelf->io_bundleCtrl_ctrlOP))
                                                                          ? Top__DOT__alu__DOT___resultAlu_T_18
                                                                          : 
                                                                         ((0xdU 
                                                                           == (IData)(vlSelf->io_bundleCtrl_ctrlOP))
                                                                           ? Top__DOT__alu__DOT___resultAlu_T_18
                                                                           : 0U))))))))))));
    if ((0U == (IData)(vlSelf->io_bundleCtrl_ctrlOP))) {
        vlSelf->io_resultALU = 0U;
        vlSelf->Top__DOT__memData__DOT__mem_dataLoad_MPORT_addr = 0U;
    } else {
        vlSelf->io_resultALU = (IData)(Top__DOT__alu__DOT___GEN_16);
        vlSelf->Top__DOT__memData__DOT__mem_dataLoad_MPORT_addr 
            = (0x3ffU & (IData)((Top__DOT__alu__DOT___GEN_16 
                                 >> 2U)));
    }
    vlSelf->io_result = ((IData)(vlSelf->io_bundleCtrl_ctrlLoad)
                          ? vlSelf->Top__DOT__memData__DOT__mem
                         [vlSelf->Top__DOT__memData__DOT__mem_dataLoad_MPORT_addr]
                          : vlSelf->io_resultALU);
}

VL_ATTR_COLD void VTop___024root___eval_stl(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___eval_stl\n"); );
    // Body
    if (vlSelf->__VstlTriggered.at(0U)) {
        VTop___024root___stl_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[1U] = 1U;
        vlSelf->__Vm_traceActivity[0U] = 1U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void VTop___024root___dump_triggers__act(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VactTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VactTriggered.at(0U)) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge clock)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void VTop___024root___dump_triggers__nba(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ (IData)(vlSelf->__VnbaTriggered.any())))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if (vlSelf->__VnbaTriggered.at(0U)) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge clock)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void VTop___024root___ctor_var_reset(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___ctor_var_reset\n"); );
    // Body
    vlSelf->clock = VL_RAND_RESET_I(1);
    vlSelf->reset = VL_RAND_RESET_I(1);
    vlSelf->io_addr = VL_RAND_RESET_I(32);
    vlSelf->io_inst = VL_RAND_RESET_I(32);
    vlSelf->io_bundleCtrl_ctrlJump = VL_RAND_RESET_I(1);
    vlSelf->io_bundleCtrl_ctrlJAL = VL_RAND_RESET_I(1);
    vlSelf->io_bundleCtrl_ctrlBranch = VL_RAND_RESET_I(1);
    vlSelf->io_bundleCtrl_ctrlRegWrite = VL_RAND_RESET_I(1);
    vlSelf->io_bundleCtrl_ctrlLoad = VL_RAND_RESET_I(1);
    vlSelf->io_bundleCtrl_ctrlStore = VL_RAND_RESET_I(1);
    vlSelf->io_bundleCtrl_ctrlALUSrc = VL_RAND_RESET_I(1);
    vlSelf->io_bundleCtrl_ctrlOP = VL_RAND_RESET_I(4);
    vlSelf->io_ctrlBranchToPc = VL_RAND_RESET_I(1);
    vlSelf->io_ctrlJumpToPc = VL_RAND_RESET_I(1);
    vlSelf->io_resultALU = VL_RAND_RESET_I(32);
    vlSelf->io_rs1 = VL_RAND_RESET_I(32);
    vlSelf->io_rs2 = VL_RAND_RESET_I(32);
    vlSelf->io_imm = VL_RAND_RESET_I(32);
    vlSelf->io_resultBranch = VL_RAND_RESET_I(1);
    vlSelf->io_result = VL_RAND_RESET_I(32);
    vlSelf->io_instWriteEn = VL_RAND_RESET_I(1);
    vlSelf->io_instWriteAddr = VL_RAND_RESET_I(32);
    vlSelf->io_instWriteData = VL_RAND_RESET_I(32);
    vlSelf->io_dataWriteEn = VL_RAND_RESET_I(1);
    vlSelf->io_dataWriteAddr = VL_RAND_RESET_I(32);
    vlSelf->io_dataWriteData = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__pcReg__DOT__regPC = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__pcReg__DOT___regPC_T_1 = VL_RAND_RESET_I(32);
    for (int __Vi0 = 0; __Vi0 < 1024; ++__Vi0) {
        vlSelf->Top__DOT__memInst__DOT__mem[__Vi0] = VL_RAND_RESET_I(32);
    }
    vlSelf->Top__DOT__decoder__DOT__immGen_io_immSel = VL_RAND_RESET_I(3);
    vlSelf->Top__DOT__registers__DOT__regs_0 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_1 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_2 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_3 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_4 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_5 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_6 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_7 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_8 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_9 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_10 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_11 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_12 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_13 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_14 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_15 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_16 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_17 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_18 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_19 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_20 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_21 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_22 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_23 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_24 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_25 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_26 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_27 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_28 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_29 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_30 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__registers__DOT__regs_31 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__alu__DOT__operand1 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__alu__DOT__operand2 = VL_RAND_RESET_I(32);
    vlSelf->Top__DOT__alu__DOT__addResult = VL_RAND_RESET_I(32);
    for (int __Vi0 = 0; __Vi0 < 1024; ++__Vi0) {
        vlSelf->Top__DOT__memData__DOT__mem[__Vi0] = VL_RAND_RESET_I(32);
    }
    vlSelf->Top__DOT__memData__DOT__mem_dataLoad_MPORT_addr = VL_RAND_RESET_I(10);
    vlSelf->__Vtrigrprev__TOP__clock = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 2; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
