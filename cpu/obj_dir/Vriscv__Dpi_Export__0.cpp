// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Implementation of DPI export functions.
//
#include "Vriscv.h"
#include "Vriscv__Syms.h"
#include "verilated_dpi.h"


int Vriscv::DPI_getPC() {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root::DPI_getPC\n"); );
    // Init
    IData/*31:0*/ DPI_getPC__Vfuncrtn__Vcvt;
    DPI_getPC__Vfuncrtn__Vcvt = 0;
    // Body
    static int __Vfuncnum = -1;
    if (VL_UNLIKELY(__Vfuncnum == -1)) __Vfuncnum = Verilated::exportFuncNum("DPI_getPC");
    const VerilatedScope* __Vscopep = Verilated::dpiScope();
    Vriscv__Vcb_DPI_getPC_t __Vcb = (Vriscv__Vcb_DPI_getPC_t)(VerilatedScope::exportFind(__Vscopep, __Vfuncnum));
    (*__Vcb)((Vriscv__Syms*)(__Vscopep->symsp()), DPI_getPC__Vfuncrtn__Vcvt);
    int DPI_getPC__Vfuncrtn;
    for (size_t DPI_getPC__Vfuncrtn__Vidx = 0; DPI_getPC__Vfuncrtn__Vidx < 1; ++DPI_getPC__Vfuncrtn__Vidx) DPI_getPC__Vfuncrtn = DPI_getPC__Vfuncrtn__Vcvt;
    return DPI_getPC__Vfuncrtn;
}

int Vriscv::DPI_getReg(int idx) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vriscv___024root::DPI_getReg\n"); );
    // Init
    IData/*31:0*/ idx__Vcvt;
    idx__Vcvt = 0;
    IData/*31:0*/ DPI_getReg__Vfuncrtn__Vcvt;
    DPI_getReg__Vfuncrtn__Vcvt = 0;
    // Body
    static int __Vfuncnum = -1;
    if (VL_UNLIKELY(__Vfuncnum == -1)) __Vfuncnum = Verilated::exportFuncNum("DPI_getReg");
    const VerilatedScope* __Vscopep = Verilated::dpiScope();
    Vriscv__Vcb_DPI_getReg_t __Vcb = (Vriscv__Vcb_DPI_getReg_t)(VerilatedScope::exportFind(__Vscopep, __Vfuncnum));
    idx__Vcvt = idx;
    (*__Vcb)((Vriscv__Syms*)(__Vscopep->symsp()), idx__Vcvt, DPI_getReg__Vfuncrtn__Vcvt);
    int DPI_getReg__Vfuncrtn;
    for (size_t DPI_getReg__Vfuncrtn__Vidx = 0; DPI_getReg__Vfuncrtn__Vidx < 1; ++DPI_getReg__Vfuncrtn__Vidx) DPI_getReg__Vfuncrtn = DPI_getReg__Vfuncrtn__Vcvt;
    return DPI_getReg__Vfuncrtn;
}
