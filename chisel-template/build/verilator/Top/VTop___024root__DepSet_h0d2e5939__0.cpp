// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See VTop.h for the primary calling header

#include "verilated.h"

#include "VTop___024root.h"

void VTop___024root___eval_act(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___eval_act\n"); );
}

VL_INLINE_OPT void VTop___024root___nba_sequent__TOP__0(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___nba_sequent__TOP__0\n"); );
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
    SData/*9:0*/ __Vdlyvdim0__Top__DOT__memInst__DOT__mem__v0;
    __Vdlyvdim0__Top__DOT__memInst__DOT__mem__v0 = 0;
    IData/*31:0*/ __Vdlyvval__Top__DOT__memInst__DOT__mem__v0;
    __Vdlyvval__Top__DOT__memInst__DOT__mem__v0 = 0;
    CData/*0:0*/ __Vdlyvset__Top__DOT__memInst__DOT__mem__v0;
    __Vdlyvset__Top__DOT__memInst__DOT__mem__v0 = 0;
    SData/*9:0*/ __Vdlyvdim0__Top__DOT__memData__DOT__mem__v0;
    __Vdlyvdim0__Top__DOT__memData__DOT__mem__v0 = 0;
    IData/*31:0*/ __Vdlyvval__Top__DOT__memData__DOT__mem__v0;
    __Vdlyvval__Top__DOT__memData__DOT__mem__v0 = 0;
    CData/*0:0*/ __Vdlyvset__Top__DOT__memData__DOT__mem__v0;
    __Vdlyvset__Top__DOT__memData__DOT__mem__v0 = 0;
    SData/*9:0*/ __Vdlyvdim0__Top__DOT__memData__DOT__mem__v1;
    __Vdlyvdim0__Top__DOT__memData__DOT__mem__v1 = 0;
    IData/*31:0*/ __Vdlyvval__Top__DOT__memData__DOT__mem__v1;
    __Vdlyvval__Top__DOT__memData__DOT__mem__v1 = 0;
    CData/*0:0*/ __Vdlyvset__Top__DOT__memData__DOT__mem__v1;
    __Vdlyvset__Top__DOT__memData__DOT__mem__v1 = 0;
    // Body
    __Vdlyvset__Top__DOT__memData__DOT__mem__v0 = 0U;
    __Vdlyvset__Top__DOT__memData__DOT__mem__v1 = 0U;
    __Vdlyvset__Top__DOT__memInst__DOT__mem__v0 = 0U;
    if (vlSelf->io_dataWriteEn) {
        __Vdlyvval__Top__DOT__memData__DOT__mem__v0 
            = vlSelf->io_dataWriteData;
        __Vdlyvset__Top__DOT__memData__DOT__mem__v0 = 1U;
        __Vdlyvdim0__Top__DOT__memData__DOT__mem__v0 
            = (0x3ffU & (vlSelf->io_dataWriteAddr >> 2U));
    }
    if (((~ (IData)(vlSelf->io_dataWriteEn)) & (IData)(vlSelf->io_bundleCtrl_ctrlStore))) {
        __Vdlyvval__Top__DOT__memData__DOT__mem__v1 
            = vlSelf->io_rs2;
        __Vdlyvset__Top__DOT__memData__DOT__mem__v1 = 1U;
        __Vdlyvdim0__Top__DOT__memData__DOT__mem__v1 
            = vlSelf->Top__DOT__memData__DOT__mem_dataLoad_MPORT_addr;
    }
    if (vlSelf->io_instWriteEn) {
        __Vdlyvval__Top__DOT__memInst__DOT__mem__v0 
            = vlSelf->io_instWriteData;
        __Vdlyvset__Top__DOT__memInst__DOT__mem__v0 = 1U;
        __Vdlyvdim0__Top__DOT__memInst__DOT__mem__v0 
            = (0x3ffU & (vlSelf->io_instWriteAddr >> 2U));
    }
    if (((IData)(vlSelf->io_bundleCtrl_ctrlRegWrite) 
         & (0U != (0x1fU & (vlSelf->io_inst >> 7U))))) {
        if (vlSelf->io_bundleCtrl_ctrlJump) {
            if ((0x1fU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_31 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x1eU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_30 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x1dU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_29 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x1cU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_28 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x1bU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_27 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x1aU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_26 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x19U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_25 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0xeU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_14 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0xfU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_15 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x10U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_16 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x11U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_17 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x12U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_18 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x13U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_19 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x14U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_20 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x15U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_21 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x16U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_22 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x17U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_23 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0x18U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_24 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((6U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_6 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((9U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_9 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((5U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_5 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_0 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((7U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_7 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((1U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_1 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((3U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_3 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((8U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_8 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0xaU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_10 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((2U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_2 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0xbU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_11 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((4U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_4 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0xcU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_12 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
            if ((0xdU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_13 
                    = ((IData)(4U) + vlSelf->Top__DOT__pcReg__DOT__regPC);
            }
        } else {
            if ((0x1fU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_31 
                    = vlSelf->io_result;
            }
            if ((0x1eU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_30 
                    = vlSelf->io_result;
            }
            if ((0x1dU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_29 
                    = vlSelf->io_result;
            }
            if ((0x1cU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_28 
                    = vlSelf->io_result;
            }
            if ((0x1bU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_27 
                    = vlSelf->io_result;
            }
            if ((0x1aU == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_26 
                    = vlSelf->io_result;
            }
            if ((0x19U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_25 
                    = vlSelf->io_result;
            }
            if ((0xeU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_14 
                    = vlSelf->io_result;
            }
            if ((0xfU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_15 
                    = vlSelf->io_result;
            }
            if ((0x10U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_16 
                    = vlSelf->io_result;
            }
            if ((0x11U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_17 
                    = vlSelf->io_result;
            }
            if ((0x12U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_18 
                    = vlSelf->io_result;
            }
            if ((0x13U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_19 
                    = vlSelf->io_result;
            }
            if ((0x14U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_20 
                    = vlSelf->io_result;
            }
            if ((0x15U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_21 
                    = vlSelf->io_result;
            }
            if ((0x16U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_22 
                    = vlSelf->io_result;
            }
            if ((0x17U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_23 
                    = vlSelf->io_result;
            }
            if ((0x18U == (0x1fU & (vlSelf->io_inst 
                                    >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_24 
                    = vlSelf->io_result;
            }
            if ((6U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_6 
                    = vlSelf->io_result;
            }
            if ((9U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_9 
                    = vlSelf->io_result;
            }
            if ((5U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_5 
                    = vlSelf->io_result;
            }
            if ((0U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_0 
                    = vlSelf->io_result;
            }
            if ((7U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_7 
                    = vlSelf->io_result;
            }
            if ((1U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_1 
                    = vlSelf->io_result;
            }
            if ((3U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_3 
                    = vlSelf->io_result;
            }
            if ((8U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_8 
                    = vlSelf->io_result;
            }
            if ((0xaU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_10 
                    = vlSelf->io_result;
            }
            if ((2U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_2 
                    = vlSelf->io_result;
            }
            if ((0xbU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_11 
                    = vlSelf->io_result;
            }
            if ((4U == (0x1fU & (vlSelf->io_inst >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_4 
                    = vlSelf->io_result;
            }
            if ((0xcU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_12 
                    = vlSelf->io_result;
            }
            if ((0xdU == (0x1fU & (vlSelf->io_inst 
                                   >> 7U)))) {
                vlSelf->Top__DOT__registers__DOT__regs_13 
                    = vlSelf->io_result;
            }
        }
    }
    if (__Vdlyvset__Top__DOT__memData__DOT__mem__v0) {
        vlSelf->Top__DOT__memData__DOT__mem[__Vdlyvdim0__Top__DOT__memData__DOT__mem__v0] 
            = __Vdlyvval__Top__DOT__memData__DOT__mem__v0;
    }
    if (__Vdlyvset__Top__DOT__memData__DOT__mem__v1) {
        vlSelf->Top__DOT__memData__DOT__mem[__Vdlyvdim0__Top__DOT__memData__DOT__mem__v1] 
            = __Vdlyvval__Top__DOT__memData__DOT__mem__v1;
    }
    if (__Vdlyvset__Top__DOT__memInst__DOT__mem__v0) {
        vlSelf->Top__DOT__memInst__DOT__mem[__Vdlyvdim0__Top__DOT__memInst__DOT__mem__v0] 
            = __Vdlyvval__Top__DOT__memInst__DOT__mem__v0;
    }
    vlSelf->Top__DOT__pcReg__DOT__regPC = ((IData)(vlSelf->reset)
                                            ? 0U : 
                                           (((IData)(vlSelf->io_bundleCtrl_ctrlJump) 
                                             | ((IData)(vlSelf->io_bundleCtrl_ctrlBranch) 
                                                & (IData)(vlSelf->io_resultBranch)))
                                             ? vlSelf->io_result
                                             : vlSelf->Top__DOT__pcReg__DOT___regPC_T_1));
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

void VTop___024root___eval_nba(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___eval_nba\n"); );
    // Body
    if (vlSelf->__VnbaTriggered.at(0U)) {
        VTop___024root___nba_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[1U] = 1U;
    }
}

void VTop___024root___eval_triggers__act(VTop___024root* vlSelf);
#ifdef VL_DEBUG
VL_ATTR_COLD void VTop___024root___dump_triggers__act(VTop___024root* vlSelf);
#endif  // VL_DEBUG
#ifdef VL_DEBUG
VL_ATTR_COLD void VTop___024root___dump_triggers__nba(VTop___024root* vlSelf);
#endif  // VL_DEBUG

void VTop___024root___eval(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___eval\n"); );
    // Init
    VlTriggerVec<1> __VpreTriggered;
    IData/*31:0*/ __VnbaIterCount;
    CData/*0:0*/ __VnbaContinue;
    // Body
    __VnbaIterCount = 0U;
    __VnbaContinue = 1U;
    while (__VnbaContinue) {
        __VnbaContinue = 0U;
        vlSelf->__VnbaTriggered.clear();
        vlSelf->__VactIterCount = 0U;
        vlSelf->__VactContinue = 1U;
        while (vlSelf->__VactContinue) {
            vlSelf->__VactContinue = 0U;
            VTop___024root___eval_triggers__act(vlSelf);
            if (vlSelf->__VactTriggered.any()) {
                vlSelf->__VactContinue = 1U;
                if (VL_UNLIKELY((0x64U < vlSelf->__VactIterCount))) {
#ifdef VL_DEBUG
                    VTop___024root___dump_triggers__act(vlSelf);
#endif
                    VL_FATAL_MT("/home/simly/Files/coachip/rv32i/chisel-template/generated/Top/Top.v", 971, "", "Active region did not converge.");
                }
                vlSelf->__VactIterCount = ((IData)(1U) 
                                           + vlSelf->__VactIterCount);
                __VpreTriggered.andNot(vlSelf->__VactTriggered, vlSelf->__VnbaTriggered);
                vlSelf->__VnbaTriggered.set(vlSelf->__VactTriggered);
                VTop___024root___eval_act(vlSelf);
            }
        }
        if (vlSelf->__VnbaTriggered.any()) {
            __VnbaContinue = 1U;
            if (VL_UNLIKELY((0x64U < __VnbaIterCount))) {
#ifdef VL_DEBUG
                VTop___024root___dump_triggers__nba(vlSelf);
#endif
                VL_FATAL_MT("/home/simly/Files/coachip/rv32i/chisel-template/generated/Top/Top.v", 971, "", "NBA region did not converge.");
            }
            __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
            VTop___024root___eval_nba(vlSelf);
        }
    }
}

#ifdef VL_DEBUG
void VTop___024root___eval_debug_assertions(VTop___024root* vlSelf) {
    if (false && vlSelf) {}  // Prevent unused
    VTop__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    VTop___024root___eval_debug_assertions\n"); );
    // Body
    if (VL_UNLIKELY((vlSelf->clock & 0xfeU))) {
        Verilated::overWidthError("clock");}
    if (VL_UNLIKELY((vlSelf->reset & 0xfeU))) {
        Verilated::overWidthError("reset");}
    if (VL_UNLIKELY((vlSelf->io_instWriteEn & 0xfeU))) {
        Verilated::overWidthError("io_instWriteEn");}
    if (VL_UNLIKELY((vlSelf->io_dataWriteEn & 0xfeU))) {
        Verilated::overWidthError("io_dataWriteEn");}
}
#endif  // VL_DEBUG
