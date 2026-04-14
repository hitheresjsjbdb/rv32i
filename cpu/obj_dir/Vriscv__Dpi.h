// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Prototypes for DPI import and export functions.
//
// Verilator includes this file in all generated .cpp files that use DPI functions.
// Manually include this file where DPI .c import functions are declared to ensure
// the C functions match the expectations of the DPI imports.

#ifndef VERILATED_VRISCV__DPI_H_
#define VERILATED_VRISCV__DPI_H_  // guard

#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif


    // DPI EXPORTS
    // DPI export at /home/pan/rv32-jichaung/cpu/rtl/rtl/NPC.v:39:14
    extern int DPI_getPC();
    // DPI export at /home/pan/rv32-jichaung/cpu/rtl/rtl/RF.v:37:14
    extern int DPI_getReg(int idx);

    // DPI IMPORTS
    // DPI import at /home/pan/rv32-jichaung/cpu/rtl/rtl/IM.v:9:33
    extern int instFetch(int addr);

#ifdef __cplusplus
}
#endif

#endif  // guard
