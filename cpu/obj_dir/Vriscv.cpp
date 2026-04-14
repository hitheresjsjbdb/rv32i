// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vriscv__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vriscv::Vriscv(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vriscv__Syms(contextp(), _vcname__, this)}
    , clk{vlSymsp->TOP.clk}
    , rst{vlSymsp->TOP.rst}
    , done{vlSymsp->TOP.done}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
}

Vriscv::Vriscv(const char* _vcname__)
    : Vriscv(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vriscv::~Vriscv() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vriscv___024root___eval_debug_assertions(Vriscv___024root* vlSelf);
#endif  // VL_DEBUG
void Vriscv___024root___eval_static(Vriscv___024root* vlSelf);
void Vriscv___024root___eval_initial(Vriscv___024root* vlSelf);
void Vriscv___024root___eval_settle(Vriscv___024root* vlSelf);
void Vriscv___024root___eval(Vriscv___024root* vlSelf);

void Vriscv::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vriscv::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vriscv___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vriscv___024root___eval_static(&(vlSymsp->TOP));
        Vriscv___024root___eval_initial(&(vlSymsp->TOP));
        Vriscv___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vriscv___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vriscv::eventsPending() { return false; }

uint64_t Vriscv::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "%Error: No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vriscv::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vriscv___024root___eval_final(Vriscv___024root* vlSelf);

VL_ATTR_COLD void Vriscv::final() {
    Vriscv___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vriscv::hierName() const { return vlSymsp->name(); }
const char* Vriscv::modelName() const { return "Vriscv"; }
unsigned Vriscv::threads() const { return 1; }
void Vriscv::prepareClone() const { contextp()->prepareClone(); }
void Vriscv::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vriscv::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vriscv___024root__trace_decl_types(VerilatedVcd* tracep);

void Vriscv___024root__trace_init_top(Vriscv___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vriscv___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vriscv___024root*>(voidSelf);
    Vriscv__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(std::string{vlSymsp->name()}, VerilatedTracePrefixType::SCOPE_MODULE);
    Vriscv___024root__trace_decl_types(tracep);
    Vriscv___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vriscv___024root__trace_register(Vriscv___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vriscv::trace(VerilatedVcdC* tfp, int levels, int options) {
    if (tfp->isOpen()) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vriscv::trace()' shall not be called after 'VerilatedVcdC::open()'.");
    }
    if (false && levels && options) {}  // Prevent unused
    tfp->spTrace()->addModel(this);
    tfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vriscv___024root__trace_register(&(vlSymsp->TOP), tfp->spTrace());
}
