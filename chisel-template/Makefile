TOP ?= Top
OUT_DIR ?= generated/$(TOP)
ALL_OUT_DIR ?= generated
LAYOUT ?= auto
SBT ?= sbt
VERILATOR ?= verilator
VERILATOR_MDIR ?= build/verilator/$(TOP)
RUNNER ?= TopFibRunner
VERILATOR_BIN ?= $(RUNNER)
WAVE_FILE ?= $(VERILATOR_MDIR)/top.vcd
REBUILD_VERILOG ?= 1
ROOT_DIR := $(abspath .)
TOP_VERILOG := $(ROOT_DIR)/generated/Top/Top.v
TOP_RUNNER_CPP := $(ROOT_DIR)/sim/$(RUNNER).cpp

.PHONY: all verilog all-verilog list-modules verilator-top run-verilator-top help

all: verilog

verilog:
	$(SBT) "runMain GenerateVerilog $(TOP) $(OUT_DIR) $(LAYOUT)"

all-verilog:
	$(SBT) "runMain GenerateVerilog all $(ALL_OUT_DIR) $(LAYOUT)"

list-modules:
	$(SBT) "runMain GenerateVerilog --list"

verilator-top:
	@if [ ! -f "$(TOP_VERILOG)" ]; then \
		echo "missing $(TOP_VERILOG), generating Verilog first"; \
		$(MAKE) verilog TOP=Top LAYOUT=single; \
	elif [ "$(REBUILD_VERILOG)" = "1" ]; then \
		echo "REBUILD_VERILOG=1, regenerating Verilog from Chisel"; \
		$(MAKE) verilog TOP=Top LAYOUT=single; \
	else \
		echo "REBUILD_VERILOG=0, reusing existing $(TOP_VERILOG)"; \
	fi
	$(VERILATOR) --trace --cc $(TOP_VERILOG) --top-module Top --exe $(TOP_RUNNER_CPP) --build --Mdir $(VERILATOR_MDIR) -CFLAGS "-std=c++17 -O2" -o $(VERILATOR_BIN)

run-verilator-top: verilator-top
	./$(VERILATOR_MDIR)/$(VERILATOR_BIN) $(WAVE_FILE)

help:
	@printf '%s\n' \
	  'make                  Generate Verilog for TOP (default: Top)' \
	  'make verilog TOP=Alu LAYOUT=single' \
	  'make verilog TOP=Top LAYOUT=split' \
	  'make verilator-top RUNNER=TopFibRunner' \
	  'make run-verilator-top RUNNER=TopFibRunner' \
	  'make run-verilator-top RUNNER=TopFibRunner REBUILD_VERILOG=0' \
	  'gtkwave build/verilator/Top/top.vcd' \
	  'make all-verilog LAYOUT=auto' \
	  'make list-modules'