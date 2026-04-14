// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vriscv__Syms.h"


void Vriscv___024root__trace_chg_0_sub_0(Vriscv___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vriscv___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root__trace_chg_0\n"); );
    // Init
    Vriscv___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vriscv___024root*>(voidSelf);
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vriscv___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vriscv___024root__trace_chg_0_sub_0(Vriscv___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    if (false && vlSelf) {}  // Prevent unused
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root__trace_chg_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[0U])) {
        bufp->chgBit(oldp+0,(vlSelf->riscv__DOT__InsMemRW));
    }
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[1U])) {
        bufp->chgBit(oldp+1,(vlSelf->riscv__DOT__PCWrite));
        bufp->chgIData(oldp+2,(vlSelf->riscv__DOT__PC),32);
        bufp->chgIData(oldp+3,(((IData)(4U) + vlSelf->riscv__DOT__PC)),32);
        bufp->chgIData(oldp+4,(vlSelf->riscv__DOT__RD1_r),32);
        bufp->chgIData(oldp+5,(vlSelf->riscv__DOT__RD2_r),32);
        bufp->chgIData(oldp+6,(vlSelf->riscv__DOT__ALU_result_r),32);
        bufp->chgCData(oldp+7,(vlSelf->riscv__DOT__U_ControlUnit__DOT__State),3);
        bufp->chgSData(oldp+8,((0x3ffU & (vlSelf->riscv__DOT__ALU_result_r 
                                          >> 2U))),10);
    }
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[2U])) {
        bufp->chgBit(oldp+9,(vlSelf->riscv__DOT__DMCtrl));
        bufp->chgBit(oldp+10,(vlSelf->riscv__DOT__ExtSel));
        bufp->chgCData(oldp+11,(vlSelf->riscv__DOT__ALUSrcB),2);
        bufp->chgCData(oldp+12,(vlSelf->riscv__DOT__WDSel),2);
        bufp->chgCData(oldp+13,(vlSelf->riscv__DOT__ALUOp),4);
        bufp->chgCData(oldp+14,((0x7fU & vlSelf->riscv__DOT__out_ins)),7);
        bufp->chgCData(oldp+15,((7U & (vlSelf->riscv__DOT__out_ins 
                                       >> 0xcU))),3);
        bufp->chgCData(oldp+16,((vlSelf->riscv__DOT__out_ins 
                                 >> 0x19U)),7);
        bufp->chgIData(oldp+17,(vlSelf->riscv__DOT__out_ins),32);
        bufp->chgCData(oldp+18,((0x1fU & (vlSelf->riscv__DOT__out_ins 
                                          >> 0xfU))),5);
        bufp->chgCData(oldp+19,((0x1fU & (vlSelf->riscv__DOT__out_ins 
                                          >> 0x14U))),5);
        bufp->chgCData(oldp+20,((0x1fU & (vlSelf->riscv__DOT__out_ins 
                                          >> 7U))),5);
        bufp->chgSData(oldp+21,((vlSelf->riscv__DOT__out_ins 
                                 >> 0x14U)),12);
        bufp->chgIData(oldp+22,(vlSelf->riscv__DOT__Imm32),32);
        bufp->chgIData(oldp+23,(((0x80000U & (vlSelf->riscv__DOT__out_ins 
                                              >> 0xcU)) 
                                 | ((0x7f800U & (vlSelf->riscv__DOT__out_ins 
                                                 >> 1U)) 
                                    | ((0x400U & (vlSelf->riscv__DOT__out_ins 
                                                  >> 0xaU)) 
                                       | (0x3ffU & 
                                          (vlSelf->riscv__DOT__out_ins 
                                           >> 0x15U)))))),20);
        bufp->chgSData(oldp+24,(vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z),12);
        bufp->chgIData(oldp+25,(vlSelf->riscv__DOT__RD1),32);
        bufp->chgIData(oldp+26,(vlSelf->riscv__DOT__U_RF__DOT__register
                                [(0x1fU & (vlSelf->riscv__DOT__out_ins 
                                           >> 0x14U))]),32);
        bufp->chgBit(oldp+27,(vlSelf->riscv__DOT__U_ControlUnit__DOT__AR));
        bufp->chgBit(oldp+28,(vlSelf->riscv__DOT__U_ControlUnit__DOT__MEM));
        bufp->chgBit(oldp+29,(vlSelf->riscv__DOT__U_ControlUnit__DOT__WB));
        bufp->chgBit(oldp+30,(vlSelf->riscv__DOT__U_ControlUnit__DOT__EX));
        bufp->chgBit(oldp+31,(vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp));
        bufp->chgIData(oldp+32,((0xfffffffcU & vlSelf->riscv__DOT__RD1)),32);
        bufp->chgSData(oldp+33,(((IData)(vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z) 
                                 << 1U)),13);
        bufp->chgIData(oldp+34,(((0x100000U & (vlSelf->riscv__DOT__out_ins 
                                               >> 0xbU)) 
                                 | ((0xff000U & vlSelf->riscv__DOT__out_ins) 
                                    | ((0x800U & (vlSelf->riscv__DOT__out_ins 
                                                  >> 9U)) 
                                       | (0x7feU & 
                                          (vlSelf->riscv__DOT__out_ins 
                                           >> 0x14U)))))),21);
        bufp->chgIData(oldp+35,((((- (IData)((1U & 
                                              ((IData)(vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z) 
                                               >> 0xbU)))) 
                                  << 0xcU) | (IData)(vlSelf->riscv__DOT____Vcellinp__U_MUX_3to1_B__Z))),32);
        bufp->chgIData(oldp+36,(VL_SHIFTL_III(32,32,32, 
                                              (0xfffffffcU 
                                               & vlSelf->riscv__DOT__RD1), 2U)),32);
        bufp->chgIData(oldp+37,(vlSelf->riscv__DOT__U_RF__DOT__register[0]),32);
        bufp->chgIData(oldp+38,(vlSelf->riscv__DOT__U_RF__DOT__register[1]),32);
        bufp->chgIData(oldp+39,(vlSelf->riscv__DOT__U_RF__DOT__register[2]),32);
        bufp->chgIData(oldp+40,(vlSelf->riscv__DOT__U_RF__DOT__register[3]),32);
        bufp->chgIData(oldp+41,(vlSelf->riscv__DOT__U_RF__DOT__register[4]),32);
        bufp->chgIData(oldp+42,(vlSelf->riscv__DOT__U_RF__DOT__register[5]),32);
        bufp->chgIData(oldp+43,(vlSelf->riscv__DOT__U_RF__DOT__register[6]),32);
        bufp->chgIData(oldp+44,(vlSelf->riscv__DOT__U_RF__DOT__register[7]),32);
        bufp->chgIData(oldp+45,(vlSelf->riscv__DOT__U_RF__DOT__register[8]),32);
        bufp->chgIData(oldp+46,(vlSelf->riscv__DOT__U_RF__DOT__register[9]),32);
        bufp->chgIData(oldp+47,(vlSelf->riscv__DOT__U_RF__DOT__register[10]),32);
        bufp->chgIData(oldp+48,(vlSelf->riscv__DOT__U_RF__DOT__register[11]),32);
        bufp->chgIData(oldp+49,(vlSelf->riscv__DOT__U_RF__DOT__register[12]),32);
        bufp->chgIData(oldp+50,(vlSelf->riscv__DOT__U_RF__DOT__register[13]),32);
        bufp->chgIData(oldp+51,(vlSelf->riscv__DOT__U_RF__DOT__register[14]),32);
        bufp->chgIData(oldp+52,(vlSelf->riscv__DOT__U_RF__DOT__register[15]),32);
        bufp->chgIData(oldp+53,(vlSelf->riscv__DOT__U_RF__DOT__register[16]),32);
        bufp->chgIData(oldp+54,(vlSelf->riscv__DOT__U_RF__DOT__register[17]),32);
        bufp->chgIData(oldp+55,(vlSelf->riscv__DOT__U_RF__DOT__register[18]),32);
        bufp->chgIData(oldp+56,(vlSelf->riscv__DOT__U_RF__DOT__register[19]),32);
        bufp->chgIData(oldp+57,(vlSelf->riscv__DOT__U_RF__DOT__register[20]),32);
        bufp->chgIData(oldp+58,(vlSelf->riscv__DOT__U_RF__DOT__register[21]),32);
        bufp->chgIData(oldp+59,(vlSelf->riscv__DOT__U_RF__DOT__register[22]),32);
        bufp->chgIData(oldp+60,(vlSelf->riscv__DOT__U_RF__DOT__register[23]),32);
        bufp->chgIData(oldp+61,(vlSelf->riscv__DOT__U_RF__DOT__register[24]),32);
        bufp->chgIData(oldp+62,(vlSelf->riscv__DOT__U_RF__DOT__register[25]),32);
        bufp->chgIData(oldp+63,(vlSelf->riscv__DOT__U_RF__DOT__register[26]),32);
        bufp->chgIData(oldp+64,(vlSelf->riscv__DOT__U_RF__DOT__register[27]),32);
        bufp->chgIData(oldp+65,(vlSelf->riscv__DOT__U_RF__DOT__register[28]),32);
        bufp->chgIData(oldp+66,(vlSelf->riscv__DOT__U_RF__DOT__register[29]),32);
        bufp->chgIData(oldp+67,(vlSelf->riscv__DOT__U_RF__DOT__register[30]),32);
        bufp->chgIData(oldp+68,(vlSelf->riscv__DOT__U_RF__DOT__register[31]),32);
    }
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[3U])) {
        bufp->chgBit(oldp+69,((0U == vlSelf->riscv__DOT__ALU_result)));
        bufp->chgCData(oldp+70,(vlSelf->riscv__DOT__NPCOp),2);
        bufp->chgIData(oldp+71,(vlSelf->riscv__DOT__NPC),32);
        bufp->chgIData(oldp+72,(vlSelf->riscv__DOT__WD),32);
        bufp->chgIData(oldp+73,(vlSelf->riscv__DOT__B),32);
        bufp->chgIData(oldp+74,(vlSelf->riscv__DOT__ALU_result),32);
        bufp->chgCData(oldp+75,(vlSelf->riscv__DOT__U_ControlUnit__DOT__NxtState),3);
    }
    bufp->chgBit(oldp+76,(vlSelf->clk));
    bufp->chgBit(oldp+77,(vlSelf->rst));
    bufp->chgBit(oldp+78,(vlSelf->done));
    bufp->chgBit(oldp+79,(((IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__RFWrite_tmp) 
                           & (5U == (IData)(vlSelf->riscv__DOT__U_ControlUnit__DOT__State)))));
    bufp->chgIData(oldp+80,(vlSelf->riscv__DOT__in_ins),32);
    bufp->chgIData(oldp+81,(vlSelf->riscv__DOT__RD),32);
    bufp->chgSData(oldp+82,(vlSelf->riscv__DOT____Vcellinp__U_IM__addr),10);
}

void Vriscv___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root__trace_cleanup\n"); );
    // Init
    Vriscv___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vriscv___024root*>(voidSelf);
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
}
