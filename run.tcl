#------------------------------------------------------------------------------
# DC synthesis script for rv32 pipeline core
# Focus: timing closure and critical-path optimization
#------------------------------------------------------------------------------

#============================== User Config ====================================
set TOP            riscv
set CLK_PORT       clk
set RST_PORT       rst
set SCRIPT_TAG     "run.tcl hotspot debug 2026-05-04i"
set CLK_PERIOD_NS  5.0
set RTL_DEFINES    {SRAM}
set ALU_HOT_PATH_MARGIN    0.86
set BRANCH_HOT_PATH_MARGIN 0.92
set BRANCH_PC_HOT_PATH_MARGIN 0.88
set OFFSET_HOT_PATH_MARGIN 0.90
set ALUSB_TO_BRANCH_HOT_PATH_MARGIN 0.91
set ALUSB_TO_NPCOP_HOT_PATH_MARGIN  0.91
set IM_TO_IFID_OFFSET_HOT_PATH_MARGIN 0.89
set IM_FEEDBACK_HOT_PATH_MARGIN 0.84
set ALUSB_TO_BRANCH_GUARD_NS 0.45
set ALUSB_TO_NPCOP_GUARD_NS  0.45
set IM_TO_IFID_OFFSET_GUARD_NS 0.55
set IM_FEEDBACK_GUARD_NS 1.05
set HOT_ALU_WEIGHT         60
set HOT_BRANCH_WEIGHT      35
set HOT_BRANCH_PC_WEIGHT   45
set HOT_OFFSET_WEIGHT      40
set HOT_ALUSB_TO_BRANCH_WEIGHT 120
set HOT_ALUSB_TO_NPCOP_WEIGHT  110
set HOT_IM_TO_IFID_OFFSET_WEIGHT 55
set HOT_IM_FEEDBACK_WEIGHT 80
set HOT_ALU_CRANGE_NS      0.30
set HOT_BRANCH_CRANGE_NS   0.04
set HOT_BRANCH_PC_CRANGE_NS 0.02
set HOT_OFFSET_CRANGE_NS   0.04
set HOT_ALUSB_TO_BRANCH_CRANGE_NS 0.15
set HOT_ALUSB_TO_NPCOP_CRANGE_NS  0.15
set HOT_IM_TO_IFID_OFFSET_CRANGE_NS 0.08
set HOT_IM_FEEDBACK_CRANGE_NS 0.08
set ENABLE_HOTPATH_STEERING 1
set ENABLE_HOTSPOT_FLATTEN 1
set RELEASE_HOTPATH_DONT_TOUCH 1
set HOTPATH_EXTRA_INCREMENTAL_PASSES 4
set ENABLE_ADAPTIVE_RETIMING 0

if {[info exists ::env(CLK_PERIOD_NS)] && $::env(CLK_PERIOD_NS) ne ""} {
  set CLK_PERIOD_NS $::env(CLK_PERIOD_NS)
}

# Library naming follows your existing setup.
set LIB_NAME       tcbn65lpwc
set OP_COND        WCCOM
set WIRELOAD_NAME  TSMC32K_Lowk_Conservative

set REPORT_DIR     reports
set OUT_DIR        out
file mkdir $REPORT_DIR
file mkdir $OUT_DIR

proc log_stage {msg} {
  global REPORT_DIR
  set fp [open "${REPORT_DIR}/compile_stage.rpt" a]
  puts $fp $msg
  close $fp
}

proc run_compile_step {label cmd} {
  log_stage "BEGIN $label"
  if {[catch {uplevel 1 $cmd} STEP_ERR]} {
    log_stage "ERROR $label: $STEP_ERR"
    return 0
  }
  log_stage "END $label OK"
  return 1
}

proc write_report_header {path lines} {
  set fp [open $path w]
  foreach line $lines {
    puts $fp $line
  }
  close $fp
}

proc append_report_line {path line} {
  set fp [open $path a]
  puts $fp $line
  close $fp
}

proc run_report_step {label path body_lines report_cmd} {
  log_stage "BEGIN $label"
  write_report_header $path $body_lines
  if {[catch {
    uplevel 1 [list redirect -append $path $report_cmd]
  } STEP_ERR]} {
    append_report_line $path "REPORT_ERROR: $STEP_ERR"
    log_stage "ERROR $label: $STEP_ERR"
    return 0
  }
  log_stage "END $label exists=[file exists $path]"
  return 1
}

#============================= Basic Setup =====================================
if {[string length [info script]] > 0} {
  set SCRIPT_DIR [file dirname [file normalize [info script]]]
  cd $SCRIPT_DIR
}

set RTL_DIR ""
set INC_DIR ""
foreach {candidate_rtl candidate_inc} {
  ./rtl              ./rtl/includes
} {
  if {[file isdirectory $candidate_rtl] && [file isdirectory $candidate_inc]} {
    set RTL_DIR $candidate_rtl
    set INC_DIR $candidate_inc
    break
  }
}

if {$RTL_DIR eq "" || $INC_DIR eq ""} {
  echo "ERROR: could not locate RTL/include directories under ./, ./cpu/rtl, or ./rtl"
  quit
}

set_app_var search_path [list $RTL_DIR $INC_DIR .]
set rtl_files [glob -nocomplain ${RTL_DIR}/*.v]
if {[llength $rtl_files] == 0} {
  echo "ERROR: no RTL files found under ${RTL_DIR}/*.v"
  quit
}

if {[llength $RTL_DEFINES] > 0} {
  analyze -define $RTL_DEFINES -format verilog $rtl_files
} else {
  analyze -format verilog $rtl_files
}
elaborate $TOP
current_design $TOP
link

check_design > ${REPORT_DIR}/check_design.pre.rpt
redirect ${REPORT_DIR}/script_signature.rpt {
  echo $SCRIPT_TAG
  echo "TOP=$TOP"
  echo "CLK_PERIOD_NS=$CLK_PERIOD_NS"
  echo "RTL_DIR=$RTL_DIR"
  echo "INC_DIR=$INC_DIR"
}
redirect ${REPORT_DIR}/compile_stage.rpt {
  echo $SCRIPT_TAG
  echo "START compile flow"
}

#=========================== Operating Condition ================================
set_operating_conditions -library $LIB_NAME $OP_COND
set_wire_load_mode top
set_wire_load_model -name $WIRELOAD_NAME -library $LIB_NAME

#============================= Clock & Timing ==================================
create_clock -name core_clk -period $CLK_PERIOD_NS -waveform [list 0 [expr {$CLK_PERIOD_NS/2.0}]] [get_ports $CLK_PORT]
set_dont_touch_network [get_clocks core_clk]

# Reasonable pre-layout margins for timing closure
set_clock_uncertainty -setup 0.12 [get_clocks core_clk]
set_clock_uncertainty -hold  0.05 [get_clocks core_clk]
set_clock_transition 0.10 [get_clocks core_clk]
set_clock_latency -source 0.05 [get_clocks core_clk]

# Async reset should not dominate data-path timing
if {[sizeof_collection [get_ports $RST_PORT]] > 0} {
  set_false_path -from [get_ports $RST_PORT] -to [all_registers]
}

#============================= Design Rules ====================================
set_max_transition 0.25 [current_design]
set_max_fanout 12 [current_design]
set_max_capacitance 0.15 [current_design]

# Use a simple IO electrical model for more realistic optimization.
# (No hard IO timing budget is forced here because top IO is minimal.)
set DATA_IN_PORTS [remove_from_collection [all_inputs] [get_ports [list $CLK_PORT $RST_PORT]]]
if {[sizeof_collection $DATA_IN_PORTS] > 0} {
  set_input_transition 0.08 $DATA_IN_PORTS
}
if {[sizeof_collection [all_outputs]] > 0} {
  set_load 0.05 [all_outputs]
}

#============================ Path Grouping ====================================
group_path -name REG2REG -weight 5 -from [all_registers -clock core_clk] -to [all_registers -clock core_clk]
if {[sizeof_collection $DATA_IN_PORTS] > 0} {
  group_path -name IN2REG -weight 2 -from $DATA_IN_PORTS -to [all_registers -clock core_clk]
}
group_path -name REG2OUT -weight 2 -from [all_registers -clock core_clk] -to [all_outputs]

set_critical_range [expr {$CLK_PERIOD_NS * 0.10}] [current_design]

#------------------------- Hotspot Path Steering -------------------------------
# Steer effort to currently observed critical cones (no RTL change).
# Target paths:
#   U_ControlUnit/U_branch/out_reg[0] -> U_IF_PCA4/out_reg[31|30]
#   U_ControlUnit/U_branch/out_reg[0] -> U_PC/PC_reg[31]
#   U_IDEX_ALUOp/out_reg[0]          -> U_ALUOut/out_data_reg[31]
#   U_IDEX_Offset/out_reg[*]          -> U_IF_PCA4/out_reg[*]
proc refresh_hotpath_collections {} {
  global ALU_FROM ALU_TO BR_FROM OFFSET_FROM BR_TO_IFPCA4 BR_TO_PC
  global ALUSB_FROM BR_CTRL_TO NPCOP_TO IFID_OFFSET_TO
  global ALUSB_Q_PINS BR_D_PINS NPCOP_D_PINS IFID_OFFSET_D_PINS
  global IM_MACRO_CELLS IM_MACRO_REGS IM_Q_PINS IM_A_PINS
  global ALUSB_TO_BRANCH_TARGET_NS ALUSB_TO_NPCOP_TARGET_NS
  global IM_TO_IFID_OFFSET_TARGET_NS IM_FEEDBACK_TARGET_NS CORE_REGS
  set CORE_REGS [all_registers -clock core_clk]

  set ALU_FROM [get_cells -hier -quiet *U_ControlUnit/U_IDEX_ALUOp/out_data_reg*]
  if {[sizeof_collection $ALU_FROM] == 0} {
    set ALU_FROM [get_cells -hier -quiet *U_IDEX_ALUOp/out_data_reg*]
  }
  set ALU_TO [get_cells -hier -quiet *U_ALUOut/out_data_reg*]
  if {[sizeof_collection $ALU_TO] == 0} {
    set ALU_TO [get_cells -hier -quiet *U_ALUOut/out_reg*]
  }

  set ALUSB_FROM [get_cells -hier -quiet *U_ControlUnit/U_IDEX_ALUSrcB/out_data_reg*]
  if {[sizeof_collection $ALUSB_FROM] == 0} {
    set ALUSB_FROM [get_cells -hier -quiet *U_IDEX_ALUSrcB/out_data_reg*]
  }
  set BR_FROM [get_cells -hier -quiet *U_ControlUnit/U_branch/out_data_reg*]
  if {[sizeof_collection $BR_FROM] == 0} {
    set BR_FROM [get_cells -hier -quiet *U_branch/out_data_reg*]
  }
  set BR_CTRL_TO $BR_FROM
  set NPCOP_TO [get_cells -hier -quiet *U_ControlUnit/U_NPCOp/out_data_reg*]
  if {[sizeof_collection $NPCOP_TO] == 0} {
    set NPCOP_TO [get_cells -hier -quiet *U_NPCOp/out_data_reg*]
  }
  set OFFSET_FROM [get_cells -hier -quiet *U_ControlUnit/U_IDEX_Offset/out_data_reg*]
  if {[sizeof_collection $OFFSET_FROM] == 0} {
    set OFFSET_FROM [get_cells -hier -quiet *U_IDEX_Offset/out_data_reg*]
  }
  set IFID_OFFSET_TO [get_cells -hier -quiet *U_ControlUnit/U_IFID_Offet/out_data_reg*]
  if {[sizeof_collection $IFID_OFFSET_TO] == 0} {
    set IFID_OFFSET_TO [get_cells -hier -quiet *U_IFID_Offet/out_data_reg*]
  }
  set BR_TO_IFPCA4 [get_cells -hier -quiet *U_ControlUnit/U_IF_PCA4/out_data_reg*]
  if {[sizeof_collection $BR_TO_IFPCA4] == 0} {
    set BR_TO_IFPCA4 [get_cells -hier -quiet *U_IF_PCA4/out_data_reg*]
  }
  set BR_TO_PC [get_cells -hier -quiet *U_PC/PC_reg*]
  if {[sizeof_collection $BR_TO_PC] == 0} {
    set BR_TO_PC [get_cells -hier -quiet *U_PC/out_data_reg*]
  }

  set EMPTY_PINS [get_pins -quiet __hotpath_no_such_pin__]
  set ALUSB_Q_PINS $EMPTY_PINS
  set BR_D_PINS $EMPTY_PINS
  set NPCOP_D_PINS $EMPTY_PINS
  set IFID_OFFSET_D_PINS $EMPTY_PINS

  if {[sizeof_collection $ALUSB_FROM] > 0} {
    set ALUSB_Q_PINS [filter_collection [get_pins -quiet -of_objects $ALUSB_FROM] "pin_name =~ Q || pin_name =~ QN"]
  }
  if {[sizeof_collection $BR_CTRL_TO] > 0} {
    set BR_D_PINS [filter_collection [get_pins -quiet -of_objects $BR_CTRL_TO] "pin_name == D"]
  }
  if {[sizeof_collection $NPCOP_TO] > 0} {
    set NPCOP_D_PINS [filter_collection [get_pins -quiet -of_objects $NPCOP_TO] "pin_name == D"]
  }
  if {[sizeof_collection $IFID_OFFSET_TO] > 0} {
    set IFID_OFFSET_D_PINS [filter_collection [get_pins -quiet -of_objects $IFID_OFFSET_TO] "pin_name == D"]
  }

  set IM_MACRO_CELLS [get_cells -hier -quiet *U_IM/memory*]
  set IM_MACRO_REGS [filter_collection $CORE_REGS "full_name =~ *U_IM/memory*"]
  set IM_Q_PINS [get_pins -hier -quiet *U_IM/memory/Q*]
  set IM_A_PINS [get_pins -hier -quiet *U_IM/memory/A*]
  set ALUSB_TO_BRANCH_TARGET_NS [expr {max(0.0, min($CLK_PERIOD_NS * $ALUSB_TO_BRANCH_HOT_PATH_MARGIN, $CLK_PERIOD_NS - $ALUSB_TO_BRANCH_GUARD_NS))}]
  set ALUSB_TO_NPCOP_TARGET_NS  [expr {max(0.0, min($CLK_PERIOD_NS * $ALUSB_TO_NPCOP_HOT_PATH_MARGIN,  $CLK_PERIOD_NS - $ALUSB_TO_NPCOP_GUARD_NS))}]
  set IM_TO_IFID_OFFSET_TARGET_NS [expr {max(0.0, min($CLK_PERIOD_NS * $IM_TO_IFID_OFFSET_HOT_PATH_MARGIN, $CLK_PERIOD_NS - $IM_TO_IFID_OFFSET_GUARD_NS))}]
  set IM_FEEDBACK_TARGET_NS [expr {max(0.0, min($CLK_PERIOD_NS * $IM_FEEDBACK_HOT_PATH_MARGIN, $CLK_PERIOD_NS - $IM_FEEDBACK_GUARD_NS))}]
}

if {$ENABLE_HOTPATH_STEERING} {
  refresh_hotpath_collections

  # If RTL/debug attributes propagated dont_touch into this cone,
  # clear them for this synthesis run so the optimizer can reshape logic.
  if {$RELEASE_HOTPATH_DONT_TOUCH} {
    set HOT_RELEASE_CELLS [get_cells -hier -quiet {U_ControlUnit U_IDEX_ALUOp U_IDEX_ALUSrcB U_branch U_NPCOp U_IFID_Offet U_ALU U_ALUOut U_IM U_IR U_PC U_NPC}]
    if {[sizeof_collection $HOT_RELEASE_CELLS] > 0} {
      catch {remove_attribute $HOT_RELEASE_CELLS dont_touch}
    }
    if {[sizeof_collection $IM_MACRO_CELLS] > 0} { catch {remove_attribute $IM_MACRO_CELLS dont_touch} }
    if {[sizeof_collection $ALU_FROM] > 0} { catch {remove_attribute $ALU_FROM dont_touch} }
    if {[sizeof_collection $ALU_TO] > 0} { catch {remove_attribute $ALU_TO dont_touch} }
    if {[sizeof_collection $ALUSB_FROM] > 0} { catch {remove_attribute $ALUSB_FROM dont_touch} }
    if {[sizeof_collection $BR_FROM] > 0} { catch {remove_attribute $BR_FROM dont_touch} }
    if {[sizeof_collection $BR_CTRL_TO] > 0} { catch {remove_attribute $BR_CTRL_TO dont_touch} }
    if {[sizeof_collection $NPCOP_TO] > 0} { catch {remove_attribute $NPCOP_TO dont_touch} }
    if {[sizeof_collection $OFFSET_FROM] > 0} { catch {remove_attribute $OFFSET_FROM dont_touch} }
    if {[sizeof_collection $IFID_OFFSET_TO] > 0} { catch {remove_attribute $IFID_OFFSET_TO dont_touch} }
    if {[sizeof_collection $BR_TO_IFPCA4] > 0} { catch {remove_attribute $BR_TO_IFPCA4 dont_touch} }
    if {[sizeof_collection $BR_TO_PC] > 0} { catch {remove_attribute $BR_TO_PC dont_touch} }
  }

  redirect ${REPORT_DIR}/hotpath_match.rpt {
    echo "SCRIPT_TAG           : $SCRIPT_TAG"
    echo "IM_MACRO_CELLS count : [sizeof_collection $IM_MACRO_CELLS]"
    if {[sizeof_collection $IM_MACRO_CELLS] > 0} { query_objects $IM_MACRO_CELLS }
    echo "IM_MACRO_REGS count  : [sizeof_collection $IM_MACRO_REGS]"
    if {[sizeof_collection $IM_MACRO_REGS] > 0} { query_objects $IM_MACRO_REGS }
    echo "IM_Q_PINS count      : [sizeof_collection $IM_Q_PINS]"
    if {[sizeof_collection $IM_Q_PINS] > 0} { query_objects $IM_Q_PINS }
    echo "IM_A_PINS count      : [sizeof_collection $IM_A_PINS]"
    if {[sizeof_collection $IM_A_PINS] > 0} { query_objects $IM_A_PINS }
    echo "ALUSB_FROM count     : [sizeof_collection $ALUSB_FROM]"
    if {[sizeof_collection $ALUSB_FROM] > 0} { query_objects $ALUSB_FROM }
    echo "ALUSB_Q_PINS count   : [sizeof_collection $ALUSB_Q_PINS]"
    if {[sizeof_collection $ALUSB_Q_PINS] > 0} { query_objects $ALUSB_Q_PINS }
    echo "BR_CTRL_TO count     : [sizeof_collection $BR_CTRL_TO]"
    if {[sizeof_collection $BR_CTRL_TO] > 0} { query_objects $BR_CTRL_TO }
    echo "BR_D_PINS count      : [sizeof_collection $BR_D_PINS]"
    if {[sizeof_collection $BR_D_PINS] > 0} { query_objects $BR_D_PINS }
    echo "NPCOP_TO count       : [sizeof_collection $NPCOP_TO]"
    if {[sizeof_collection $NPCOP_TO] > 0} { query_objects $NPCOP_TO }
    echo "NPCOP_D_PINS count   : [sizeof_collection $NPCOP_D_PINS]"
    if {[sizeof_collection $NPCOP_D_PINS] > 0} { query_objects $NPCOP_D_PINS }
    echo "IFID_OFFSET_TO count : [sizeof_collection $IFID_OFFSET_TO]"
    if {[sizeof_collection $IFID_OFFSET_TO] > 0} { query_objects $IFID_OFFSET_TO }
    echo "IFID_OFFSET_D_PINS count : [sizeof_collection $IFID_OFFSET_D_PINS]"
    if {[sizeof_collection $IFID_OFFSET_D_PINS] > 0} { query_objects $IFID_OFFSET_D_PINS }
    echo "ALUSB->branch ns     : $ALUSB_TO_BRANCH_TARGET_NS"
    echo "ALUSB->NPCOp ns      : $ALUSB_TO_NPCOP_TARGET_NS"
    echo "IM->IFID_Offset ns   : $IM_TO_IFID_OFFSET_TARGET_NS"
    echo "IM feedback target ns: $IM_FEEDBACK_TARGET_NS"
    echo "ALU_FROM count       : [sizeof_collection $ALU_FROM]"
    if {[sizeof_collection $ALU_FROM] > 0} { query_objects $ALU_FROM }
    echo "ALU_TO count         : [sizeof_collection $ALU_TO]"
    if {[sizeof_collection $ALU_TO] > 0} { query_objects $ALU_TO }
    echo "BR_FROM count        : [sizeof_collection $BR_FROM]"
    if {[sizeof_collection $BR_FROM] > 0} { query_objects $BR_FROM }
    echo "OFFSET_FROM count    : [sizeof_collection $OFFSET_FROM]"
    if {[sizeof_collection $OFFSET_FROM] > 0} { query_objects $OFFSET_FROM }
    echo "BR_TO_IFPCA4 count   : [sizeof_collection $BR_TO_IFPCA4]"
    if {[sizeof_collection $BR_TO_IFPCA4] > 0} { query_objects $BR_TO_IFPCA4 }
    echo "BR_TO_PC count       : [sizeof_collection $BR_TO_PC]"
    if {[sizeof_collection $BR_TO_PC] > 0} { query_objects $BR_TO_PC }
  }

  if {[sizeof_collection $ALU_FROM] > 0 && [sizeof_collection $ALU_TO] > 0} {
    group_path -name HOT_ALUOP_TO_ALUOUT -weight $HOT_ALU_WEIGHT \
      -critical_range $HOT_ALU_CRANGE_NS -from $ALU_FROM -to $ALU_TO
    set_max_delay [expr {$CLK_PERIOD_NS * $ALU_HOT_PATH_MARGIN}] \
      -datapath_only -from $ALU_FROM -to $ALU_TO
  }

  if {[sizeof_collection $ALUSB_FROM] > 0 && [sizeof_collection $BR_CTRL_TO] > 0} {
    group_path -name HOT_ALUSB_TO_BRANCH -weight $HOT_ALUSB_TO_BRANCH_WEIGHT \
      -critical_range $HOT_ALUSB_TO_BRANCH_CRANGE_NS -from $ALUSB_FROM -to $BR_CTRL_TO
    set_max_delay $ALUSB_TO_BRANCH_TARGET_NS \
      -datapath_only -from $ALUSB_FROM -to $BR_CTRL_TO
  }

  if {[sizeof_collection $ALUSB_FROM] > 0 && [sizeof_collection $NPCOP_TO] > 0} {
    group_path -name HOT_ALUSB_TO_NPCOP -weight $HOT_ALUSB_TO_NPCOP_WEIGHT \
      -critical_range $HOT_ALUSB_TO_NPCOP_CRANGE_NS -from $ALUSB_FROM -to $NPCOP_TO
    set_max_delay $ALUSB_TO_NPCOP_TARGET_NS \
      -datapath_only -from $ALUSB_FROM -to $NPCOP_TO
  }

  if {[sizeof_collection $IM_MACRO_REGS] > 0 && [sizeof_collection $IFID_OFFSET_D_PINS] > 0} {
    group_path -name HOT_IM_TO_IFID_OFFSET -weight $HOT_IM_TO_IFID_OFFSET_WEIGHT \
      -critical_range $HOT_IM_TO_IFID_OFFSET_CRANGE_NS -from $IM_Q_PINS -to $IFID_OFFSET_D_PINS
  }
  if {[sizeof_collection $IM_Q_PINS] > 0 && [sizeof_collection $IFID_OFFSET_D_PINS] > 0} {
    set_max_delay $IM_TO_IFID_OFFSET_TARGET_NS \
      -datapath_only -from $IM_Q_PINS -to $IFID_OFFSET_D_PINS
  }

  if {[sizeof_collection $IM_MACRO_REGS] > 0} {
    group_path -name HOT_IM_Q_TO_A -weight $HOT_IM_FEEDBACK_WEIGHT \
      -critical_range $HOT_IM_FEEDBACK_CRANGE_NS -from $IM_MACRO_REGS -to $IM_MACRO_REGS
  }
  if {[sizeof_collection $IM_Q_PINS] > 0 && [sizeof_collection $IM_A_PINS] > 0} {
    set_max_delay $IM_FEEDBACK_TARGET_NS \
      -datapath_only -from $IM_Q_PINS -to $IM_A_PINS
  }

  if {[sizeof_collection $BR_FROM] > 0 && [sizeof_collection $BR_TO_IFPCA4] > 0} {
    group_path -name HOT_BRANCH_TO_IFPCA4 -weight $HOT_BRANCH_WEIGHT \
      -critical_range $HOT_BRANCH_CRANGE_NS -from $BR_FROM -to $BR_TO_IFPCA4
    set_max_delay [expr {$CLK_PERIOD_NS * $BRANCH_HOT_PATH_MARGIN}] \
      -datapath_only -from $BR_FROM -to $BR_TO_IFPCA4
  }

  if {[sizeof_collection $OFFSET_FROM] > 0 && [sizeof_collection $BR_TO_IFPCA4] > 0} {
    group_path -name HOT_OFFSET_TO_IFPCA4 -weight $HOT_OFFSET_WEIGHT \
      -critical_range $HOT_OFFSET_CRANGE_NS -from $OFFSET_FROM -to $BR_TO_IFPCA4
    set_max_delay [expr {$CLK_PERIOD_NS * $OFFSET_HOT_PATH_MARGIN}] \
      -datapath_only -from $OFFSET_FROM -to $BR_TO_IFPCA4
  }

  if {[sizeof_collection $BR_FROM] > 0 && [sizeof_collection $BR_TO_PC] > 0} {
    group_path -name HOT_BRANCH_TO_PC -weight $HOT_BRANCH_PC_WEIGHT \
      -critical_range $HOT_BRANCH_PC_CRANGE_NS -from $BR_FROM -to $BR_TO_PC
    set_max_delay [expr {$CLK_PERIOD_NS * $BRANCH_PC_HOT_PATH_MARGIN}] \
      -datapath_only -from $BR_FROM -to $BR_TO_PC
  }
}

# Allow cross-boundary optimization around ALU/branch-related logic cones.
# Keep the ControlUnit hierarchy intact so hotspot endpoint names survive
# through compile/reporting; otherwise ALUSB/branch/NPCOp path matching can
# disappear after ungroup/retime.
if {$ENABLE_HOTSPOT_FLATTEN} {
  set HOT_UNGROUP_CELLS [get_cells -quiet {U_IR U_ALU U_NPC U_PC U_MUX_2to1_A U_MUX_3to1_B}]
  if {[sizeof_collection $HOT_UNGROUP_CELLS] > 0} {
    set_ungroup $HOT_UNGROUP_CELLS true
    set_boundary_optimization $HOT_UNGROUP_CELLS true
  }

  set HOT_KEEP_HIER_CELLS [get_cells -quiet {U_ControlUnit U_IM}]
  if {[sizeof_collection $HOT_KEEP_HIER_CELLS] > 0} {
    catch {set_ungroup $HOT_KEEP_HIER_CELLS false}
    set_boundary_optimization $HOT_KEEP_HIER_CELLS true
  }
}

#=========================== Compile Strategy ==================================
set_fix_multiple_port_nets -all -buffer_constants
set_cost_priority -delay

# Optional retiming setup for deep reg2reg combinational cones.
if {$ENABLE_ADAPTIVE_RETIMING} {
  catch {
    set_optimize_registers true -design $TOP -clock core_clk -delay_threshold $CLK_PERIOD_NS
  }
}

set RETIME_ACTIVE 0
set COMPILE_FLOW_OK 1

# Pass-1: global mapping and timing-oriented optimization
if {$ENABLE_ADAPTIVE_RETIMING} {
  if {![run_compile_step "compile_ultra_pass1_retime" {compile_ultra -retime -timing_high_effort_script}]} {
    log_stage "WARN compile_ultra_pass1_retime failed, fallback to non-retime flow"
    if {![run_compile_step "compile_ultra_pass1_fallback" {compile_ultra -timing_high_effort_script}]} {
      set COMPILE_FLOW_OK 0
    }
  } else {
    set RETIME_ACTIVE 1
  }
} else {
  if {![run_compile_step "compile_ultra_pass1" {compile_ultra -timing_high_effort_script}]} {
    set COMPILE_FLOW_OK 0
  }
}

# Pass-2: incremental closure on critical paths
if {$COMPILE_FLOW_OK} {
  if {$RETIME_ACTIVE} {
    if {![run_compile_step "compile_ultra_pass2_retime" {compile_ultra -incremental -retime -timing_high_effort_script}]} {
      set COMPILE_FLOW_OK 0
    }
  } else {
    if {![run_compile_step "compile_ultra_pass2" {compile_ultra -incremental -timing_high_effort_script}]} {
      set COMPILE_FLOW_OK 0
    }
  }
}

# Optional extra incremental passes for hot-path closure.
for {set i 0} {$COMPILE_FLOW_OK && $i < $HOTPATH_EXTRA_INCREMENTAL_PASSES} {incr i} {
  if {$RETIME_ACTIVE} {
    if {![run_compile_step "compile_ultra_extra_${i}_retime" {compile_ultra -incremental -retime -timing_high_effort_script}]} {
      set COMPILE_FLOW_OK 0
    }
  } else {
    if {![run_compile_step "compile_ultra_extra_${i}" {compile_ultra -incremental -timing_high_effort_script}]} {
      set COMPILE_FLOW_OK 0
    }
  }
}
if {!$COMPILE_FLOW_OK} {
  log_stage "COMPILE_FLOW_STATUS ERROR"
} else {
  log_stage "COMPILE_FLOW_STATUS OK"
}

#=============================== Reports ========================================
run_report_step "report check_timing" \
  "${REPORT_DIR}/check_timing.rpt" \
  [list $SCRIPT_TAG] \
  {check_timing}
run_report_step "report qor" \
  "${REPORT_DIR}/qor.rpt" \
  [list $SCRIPT_TAG] \
  {report_qor}
run_report_step "report constraint_violators" \
  "${REPORT_DIR}/constraint_violators.rpt" \
  [list $SCRIPT_TAG] \
  {report_constraint -all_violators}
run_report_step "report path_groups" \
  "${REPORT_DIR}/path_groups.rpt" \
  [list $SCRIPT_TAG] \
  {report_path_group}
run_report_step "report timing_setup_top20" \
  "${REPORT_DIR}/timing_setup_top20.rpt" \
  [list $SCRIPT_TAG] \
  {report_timing -delay_type max -max_paths 20 -nworst 1 -transition_time -capacitance -nets -attributes}
run_report_step "report timing_hold_top20" \
  "${REPORT_DIR}/timing_hold_top20.rpt" \
  [list $SCRIPT_TAG] \
  {report_timing -delay_type min -max_paths 20 -nworst 1 -transition_time -capacitance -nets -attributes}

if {$ENABLE_HOTPATH_STEERING} {
  log_stage "BEGIN refresh_hotpath_collections_postcompile"
  if {[catch {refresh_hotpath_collections} HOTPATH_ERR]} {
    log_stage "ERROR refresh_hotpath_collections_postcompile: $HOTPATH_ERR"
  } else {
    log_stage "END refresh_hotpath_collections_postcompile"
  }

  run_report_step "report hotpath_match_postcompile" \
    "${REPORT_DIR}/hotpath_match.postcompile.rpt" \
    [list $SCRIPT_TAG] \
    {
      echo "SCRIPT_TAG           : $SCRIPT_TAG"
      echo "IM_MACRO_CELLS count : [sizeof_collection $IM_MACRO_CELLS]"
      if {[sizeof_collection $IM_MACRO_CELLS] > 0} { query_objects $IM_MACRO_CELLS }
      echo "IM_MACRO_REGS count  : [sizeof_collection $IM_MACRO_REGS]"
      if {[sizeof_collection $IM_MACRO_REGS] > 0} { query_objects $IM_MACRO_REGS }
      echo "IM_Q_PINS count      : [sizeof_collection $IM_Q_PINS]"
      if {[sizeof_collection $IM_Q_PINS] > 0} { query_objects $IM_Q_PINS }
      echo "IM_A_PINS count      : [sizeof_collection $IM_A_PINS]"
      if {[sizeof_collection $IM_A_PINS] > 0} { query_objects $IM_A_PINS }
      echo "ALUSB_FROM count     : [sizeof_collection $ALUSB_FROM]"
      if {[sizeof_collection $ALUSB_FROM] > 0} { query_objects $ALUSB_FROM }
      echo "ALUSB_Q_PINS count   : [sizeof_collection $ALUSB_Q_PINS]"
      if {[sizeof_collection $ALUSB_Q_PINS] > 0} { query_objects $ALUSB_Q_PINS }
      echo "BR_CTRL_TO count     : [sizeof_collection $BR_CTRL_TO]"
      if {[sizeof_collection $BR_CTRL_TO] > 0} { query_objects $BR_CTRL_TO }
      echo "BR_D_PINS count      : [sizeof_collection $BR_D_PINS]"
      if {[sizeof_collection $BR_D_PINS] > 0} { query_objects $BR_D_PINS }
      echo "NPCOP_TO count       : [sizeof_collection $NPCOP_TO]"
      if {[sizeof_collection $NPCOP_TO] > 0} { query_objects $NPCOP_TO }
      echo "NPCOP_D_PINS count   : [sizeof_collection $NPCOP_D_PINS]"
      if {[sizeof_collection $NPCOP_D_PINS] > 0} { query_objects $NPCOP_D_PINS }
      echo "IFID_OFFSET_TO count : [sizeof_collection $IFID_OFFSET_TO]"
      if {[sizeof_collection $IFID_OFFSET_TO] > 0} { query_objects $IFID_OFFSET_TO }
      echo "IFID_OFFSET_D_PINS count : [sizeof_collection $IFID_OFFSET_D_PINS]"
      if {[sizeof_collection $IFID_OFFSET_D_PINS] > 0} { query_objects $IFID_OFFSET_D_PINS }
      echo "ALUSB->branch ns     : $ALUSB_TO_BRANCH_TARGET_NS"
      echo "ALUSB->NPCOp ns      : $ALUSB_TO_NPCOP_TARGET_NS"
      echo "IM->IFID_Offset ns   : $IM_TO_IFID_OFFSET_TARGET_NS"
      echo "IM feedback target ns: $IM_FEEDBACK_TARGET_NS"
      echo "ALU_FROM count       : [sizeof_collection $ALU_FROM]"
      if {[sizeof_collection $ALU_FROM] > 0} { query_objects $ALU_FROM }
      echo "ALU_TO count         : [sizeof_collection $ALU_TO]"
      if {[sizeof_collection $ALU_TO] > 0} { query_objects $ALU_TO }
      echo "BR_FROM count        : [sizeof_collection $BR_FROM]"
      if {[sizeof_collection $BR_FROM] > 0} { query_objects $BR_FROM }
      echo "OFFSET_FROM count    : [sizeof_collection $OFFSET_FROM]"
      if {[sizeof_collection $OFFSET_FROM] > 0} { query_objects $OFFSET_FROM }
      echo "BR_TO_IFPCA4 count   : [sizeof_collection $BR_TO_IFPCA4]"
      if {[sizeof_collection $BR_TO_IFPCA4] > 0} { query_objects $BR_TO_IFPCA4 }
      echo "BR_TO_PC count       : [sizeof_collection $BR_TO_PC]"
      if {[sizeof_collection $BR_TO_PC] > 0} { query_objects $BR_TO_PC }
    }

  set report_file "${REPORT_DIR}/timing_group_hot_alusb_branch.rpt"
  log_stage "BEGIN report timing_group_hot_alusb_branch"
  write_report_header $report_file [list \
    $SCRIPT_TAG \
    "ALUSB_Q_PINS count = [sizeof_collection $ALUSB_Q_PINS]" \
    "BR_D_PINS count    = [sizeof_collection $BR_D_PINS]"]
  if {[sizeof_collection $ALUSB_Q_PINS] > 0 && [sizeof_collection $BR_D_PINS] > 0} {
    if {[catch {
      redirect -append $report_file {
        report_timing -delay_type max -max_paths 10 -nworst 1 \
          -group HOT_ALUSB_TO_BRANCH -transition_time -capacitance -nets -attributes
      }
    } GROUP_ERR]} {
      append_report_line $report_file "REPORT_ERROR: $GROUP_ERR"
    }
  } else {
    append_report_line $report_file "SKIPPED: HOT_ALUSB_TO_BRANCH group not created because collections are empty"
  }
  log_stage "END report timing_group_hot_alusb_branch exists=[file exists $report_file]"

  set report_file "${REPORT_DIR}/timing_group_hot_alusb_npcop.rpt"
  log_stage "BEGIN report timing_group_hot_alusb_npcop"
  write_report_header $report_file [list \
    $SCRIPT_TAG \
    "ALUSB_Q_PINS count = [sizeof_collection $ALUSB_Q_PINS]" \
    "NPCOP_D_PINS count = [sizeof_collection $NPCOP_D_PINS]"]
  if {[sizeof_collection $ALUSB_Q_PINS] > 0 && [sizeof_collection $NPCOP_D_PINS] > 0} {
    if {[catch {
      redirect -append $report_file {
        report_timing -delay_type max -max_paths 10 -nworst 1 \
          -group HOT_ALUSB_TO_NPCOP -transition_time -capacitance -nets -attributes
      }
    } GROUP_ERR]} {
      append_report_line $report_file "REPORT_ERROR: $GROUP_ERR"
    }
  } else {
    append_report_line $report_file "SKIPPED: HOT_ALUSB_TO_NPCOP group not created because collections are empty"
  }
  log_stage "END report timing_group_hot_alusb_npcop exists=[file exists $report_file]"

  set report_file "${REPORT_DIR}/timing_group_hot_im_ifid_offset.rpt"
  log_stage "BEGIN report timing_group_hot_im_ifid_offset"
  write_report_header $report_file [list \
    $SCRIPT_TAG \
    "IM_Q_PINS count          = [sizeof_collection $IM_Q_PINS]" \
    "IFID_OFFSET_D_PINS count = [sizeof_collection $IFID_OFFSET_D_PINS]"]
  if {[catch {
    redirect -append $report_file {
      report_timing -delay_type max -max_paths 10 -nworst 1 \
        -group HOT_IM_TO_IFID_OFFSET -transition_time -capacitance -nets -attributes
    }
  } GROUP_ERR]} {
    append_report_line $report_file "REPORT_ERROR: $GROUP_ERR"
  }
  log_stage "END report timing_group_hot_im_ifid_offset exists=[file exists $report_file]"

  set report_file "${REPORT_DIR}/timing_group_hot_im_feedback.rpt"
  log_stage "BEGIN report timing_group_hot_im_feedback"
  write_report_header $report_file [list \
    $SCRIPT_TAG \
    "IM_MACRO_REGS count = [sizeof_collection $IM_MACRO_REGS]"]
  if {[catch {
    redirect -append $report_file {
      report_timing -delay_type max -max_paths 10 -nworst 1 \
        -group HOT_IM_Q_TO_A -transition_time -capacitance -nets -attributes
    }
  } GROUP_ERR]} {
    append_report_line $report_file "REPORT_ERROR: $GROUP_ERR"
  }
  log_stage "END report timing_group_hot_im_feedback exists=[file exists $report_file]"

  set report_file "${REPORT_DIR}/timing_hot_alusb_branch.rpt"
  log_stage "BEGIN report timing_hot_alusb_branch"
  write_report_header $report_file [list \
    $SCRIPT_TAG \
    "ALUSB_FROM count = [sizeof_collection $ALUSB_FROM]" \
    "BR_CTRL_TO count = [sizeof_collection $BR_CTRL_TO]" \
    "ALUSB_Q_PINS count = [sizeof_collection $ALUSB_Q_PINS]" \
    "BR_D_PINS count    = [sizeof_collection $BR_D_PINS]"]
  if {[sizeof_collection $ALUSB_FROM] > 0 && [sizeof_collection $BR_CTRL_TO] > 0} {
    if {[catch {
      redirect -append $report_file {
        report_timing -delay_type max -max_paths 10 -nworst 1 \
          -from $ALUSB_FROM -to $BR_CTRL_TO -transition_time -capacitance -nets -attributes
      }
    } GROUP_ERR]} {
      append_report_line $report_file "REPORT_ERROR: $GROUP_ERR"
    }
  } else {
    append_report_line $report_file "SKIPPED: timing_hot_alusb_branch collections empty"
  }
  log_stage "END report timing_hot_alusb_branch exists=[file exists $report_file]"

  set report_file "${REPORT_DIR}/timing_hot_alusb_npcop.rpt"
  log_stage "BEGIN report timing_hot_alusb_npcop"
  write_report_header $report_file [list \
    $SCRIPT_TAG \
    "ALUSB_FROM count = [sizeof_collection $ALUSB_FROM]" \
    "NPCOP_TO count   = [sizeof_collection $NPCOP_TO]" \
    "ALUSB_Q_PINS count = [sizeof_collection $ALUSB_Q_PINS]" \
    "NPCOP_D_PINS count = [sizeof_collection $NPCOP_D_PINS]"]
  if {[sizeof_collection $ALUSB_FROM] > 0 && [sizeof_collection $NPCOP_TO] > 0} {
    if {[catch {
      redirect -append $report_file {
        report_timing -delay_type max -max_paths 10 -nworst 1 \
          -from $ALUSB_FROM -to $NPCOP_TO -transition_time -capacitance -nets -attributes
      }
    } GROUP_ERR]} {
      append_report_line $report_file "REPORT_ERROR: $GROUP_ERR"
    }
  } else {
    append_report_line $report_file "SKIPPED: timing_hot_alusb_npcop collections empty"
  }
  log_stage "END report timing_hot_alusb_npcop exists=[file exists $report_file]"

  set report_file "${REPORT_DIR}/timing_hot_im_ifid_offset.rpt"
  log_stage "BEGIN report timing_hot_im_ifid_offset"
  write_report_header $report_file [list \
    $SCRIPT_TAG \
    "IM_Q_PINS count          = [sizeof_collection $IM_Q_PINS]" \
    "IFID_OFFSET_D_PINS count = [sizeof_collection $IFID_OFFSET_D_PINS]"]
  if {[sizeof_collection $IM_Q_PINS] > 0 && [sizeof_collection $IFID_OFFSET_D_PINS] > 0} {
    if {[catch {
      redirect -append $report_file {
        report_timing -delay_type max -max_paths 10 -nworst 1 \
          -from $IM_Q_PINS -to $IFID_OFFSET_D_PINS -transition_time -capacitance -nets -attributes
      }
    } GROUP_ERR]} {
      append_report_line $report_file "REPORT_ERROR: $GROUP_ERR"
    }
  } else {
    append_report_line $report_file "SKIPPED: timing_hot_im_ifid_offset collections empty"
  }
  log_stage "END report timing_hot_im_ifid_offset exists=[file exists $report_file]"
  if {[sizeof_collection $ALU_FROM] > 0 && [sizeof_collection $ALU_TO] > 0} {
    report_timing -delay_type max -max_paths 10 -nworst 1 \
      -from $ALU_FROM -to $ALU_TO -transition_time -capacitance -nets \
      > ${REPORT_DIR}/timing_hot_alu.rpt
  }
  if {[sizeof_collection $IM_Q_PINS] > 0 && [sizeof_collection $IM_A_PINS] > 0} {
    report_timing -delay_type max -max_paths 10 -nworst 1 \
      -from $IM_Q_PINS -to $IM_A_PINS -transition_time -capacitance -nets -attributes \
      > ${REPORT_DIR}/timing_hot_im_feedback.rpt
  }
  if {[sizeof_collection $BR_FROM] > 0 && [sizeof_collection $BR_TO_IFPCA4] > 0} {
    report_timing -delay_type max -max_paths 10 -nworst 1 \
      -from $BR_FROM -to $BR_TO_IFPCA4 -transition_time -capacitance -nets \
      > ${REPORT_DIR}/timing_hot_branch_ifpca4.rpt
  }
  if {[sizeof_collection $OFFSET_FROM] > 0 && [sizeof_collection $BR_TO_IFPCA4] > 0} {
    report_timing -delay_type max -max_paths 10 -nworst 1 \
      -from $OFFSET_FROM -to $BR_TO_IFPCA4 -transition_time -capacitance -nets \
      > ${REPORT_DIR}/timing_hot_offset_ifpca4.rpt
  }
  if {[sizeof_collection $BR_FROM] > 0 && [sizeof_collection $BR_TO_PC] > 0} {
    report_timing -delay_type max -max_paths 10 -nworst 1 \
      -from $BR_FROM -to $BR_TO_PC -transition_time -capacitance -nets \
      > ${REPORT_DIR}/timing_hot_branch_pc.rpt
  }
}

report_area -hierarchy > ${REPORT_DIR}/area_hier.rpt
report_power > ${REPORT_DIR}/power.rpt
report_net_fanout -high_fanout > ${REPORT_DIR}/high_fanout.rpt

#=============================== Outputs ========================================
write -hierarchy -format ddc     -output ${OUT_DIR}/${TOP}.ddc
write -hierarchy -format verilog -output ${OUT_DIR}/${TOP}_syn.v
write_sdc ${OUT_DIR}/${TOP}.sdc

quit
