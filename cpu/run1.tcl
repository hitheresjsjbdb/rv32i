#------------------------------------------------------------------------------
# DC synthesis script for rv32 pipeline core
# Focus: timing closure and critical-path optimization
#------------------------------------------------------------------------------

#============================== User Config ====================================
set TOP            riscv
set CLK_PORT       clk
set RST_PORT       rst
set CLK_PERIOD_NS  4.0
set ALU_HOT_PATH_MARGIN    0.86
set BRANCH_HOT_PATH_MARGIN 0.92
set BRANCH_PC_HOT_PATH_MARGIN 0.88
set OFFSET_HOT_PATH_MARGIN 0.90
set HOT_ALU_WEIGHT         60
set HOT_BRANCH_WEIGHT      35
set HOT_BRANCH_PC_WEIGHT   45
set HOT_OFFSET_WEIGHT      40
set HOT_ALU_CRANGE_NS      0.30
set HOT_BRANCH_CRANGE_NS   0.04
set HOT_BRANCH_PC_CRANGE_NS 0.02
set HOT_OFFSET_CRANGE_NS   0.04
set ENABLE_HOTPATH_STEERING 1
set ENABLE_HOTSPOT_FLATTEN 1
set RELEASE_HOTPATH_DONT_TOUCH 1
set HOTPATH_EXTRA_INCREMENTAL_PASSES 2
set ENABLE_ADAPTIVE_RETIMING 1

# Library naming follows your existing setup.
set LIB_NAME       tcbn65lpwc
set OP_COND        WCCOM
set WIRELOAD_NAME  TSMC32K_Lowk_Conservative

set REPORT_DIR     reports
set OUT_DIR        out
file mkdir $REPORT_DIR
file mkdir $OUT_DIR

#============================= Basic Setup =====================================
if {[string length [info script]] > 0} {
  set SCRIPT_DIR [file dirname [file normalize [info script]]]
  cd $SCRIPT_DIR
}

set_app_var search_path [list ./rtl/rtl ./rtl/includes .]
set rtl_files [glob -nocomplain ./rtl/rtl/*.v]
if {[llength $rtl_files] == 0} {
  echo "ERROR: no RTL files found under ./rtl/rtl/*.v"
  quit
}

analyze -format verilog $rtl_files
elaborate $TOP
current_design $TOP
link

check_design > ${REPORT_DIR}/check_design.pre.rpt

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
  global ALU_FROM ALU_TO BR_FROM OFFSET_FROM BR_TO_IFPCA4 BR_TO_PC CORE_REGS
  set CORE_REGS [all_registers -clock core_clk]

  set ALU_FROM [filter_collection $CORE_REGS "full_name =~ *U_ControlUnit/U_IDEX_ALUOp/out_reg* || full_name =~ *U_IDEX_ALUOp/out_reg* || full_name =~ *U_ControlUnit/U_IDEX_ALUOp/out_data_reg* || full_name =~ *U_IDEX_ALUOp/out_data_reg*"]
  set ALU_TO   [filter_collection $CORE_REGS "full_name =~ *U_ALUOut/out_data_reg* || full_name =~ *U_ALUOut/out_reg*"]

  set BR_FROM [filter_collection $CORE_REGS "full_name =~ *U_ControlUnit/U_branch/out_reg* || full_name =~ *U_branch/out_reg* || full_name =~ *U_ControlUnit/U_branch/out_data_reg* || full_name =~ *U_branch/out_data_reg*"]
  set OFFSET_FROM [filter_collection $CORE_REGS "full_name =~ *U_ControlUnit/U_IDEX_Offset/out_reg* || full_name =~ *U_IDEX_Offset/out_reg* || full_name =~ *U_ControlUnit/U_IDEX_Offset/out_data_reg* || full_name =~ *U_IDEX_Offset/out_data_reg*"]
  set BR_TO_IFPCA4 [filter_collection $CORE_REGS "full_name =~ *U_IF_PCA4/out_reg* || full_name =~ *U_IF_PCA4/out_data_reg*"]
  set BR_TO_PC [filter_collection $CORE_REGS "full_name =~ *U_PC/PC_reg* || full_name =~ *U_PC/out_reg*"]
}

if {$ENABLE_HOTPATH_STEERING} {
  refresh_hotpath_collections

  # If RTL/debug attributes propagated dont_touch into this cone,
  # clear them for this synthesis run so the optimizer can reshape logic.
  if {$RELEASE_HOTPATH_DONT_TOUCH} {
    set HOT_RELEASE_CELLS [get_cells -hier -quiet {U_ControlUnit U_IDEX_ALUOp U_ALU U_ALUOut}]
    if {[sizeof_collection $HOT_RELEASE_CELLS] > 0} {
      catch {remove_attribute $HOT_RELEASE_CELLS dont_touch}
    }
    if {[sizeof_collection $ALU_FROM] > 0} { catch {remove_attribute $ALU_FROM dont_touch} }
    if {[sizeof_collection $ALU_TO] > 0} { catch {remove_attribute $ALU_TO dont_touch} }
    if {[sizeof_collection $BR_FROM] > 0} { catch {remove_attribute $BR_FROM dont_touch} }
    if {[sizeof_collection $OFFSET_FROM] > 0} { catch {remove_attribute $OFFSET_FROM dont_touch} }
    if {[sizeof_collection $BR_TO_IFPCA4] > 0} { catch {remove_attribute $BR_TO_IFPCA4 dont_touch} }
    if {[sizeof_collection $BR_TO_PC] > 0} { catch {remove_attribute $BR_TO_PC dont_touch} }
  }

  redirect ${REPORT_DIR}/hotpath_match.rpt {
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
if {$ENABLE_HOTSPOT_FLATTEN} {
  set HOT_CELLS [get_cells -quiet {U_ALU U_NPC U_PC U_ControlUnit U_MUX_2to1_A U_MUX_3to1_B}]
  if {[sizeof_collection $HOT_CELLS] > 0} {
    set_ungroup $HOT_CELLS true
    set_boundary_optimization $HOT_CELLS true
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

# Pass-1: global mapping and timing-oriented optimization
if {$ENABLE_ADAPTIVE_RETIMING} {
  if {[catch {compile_ultra -retime -timing_high_effort_script} RETIME_ERR]} {
    echo "WARN: compile_ultra -retime unavailable, fallback to non-retime flow: $RETIME_ERR"
    compile_ultra -timing_high_effort_script
  } else {
    set RETIME_ACTIVE 1
  }
} else {
  compile_ultra -timing_high_effort_script
}

# Pass-2: incremental closure on critical paths
if {$RETIME_ACTIVE} {
  compile_ultra -incremental -retime -timing_high_effort_script
} else {
  compile_ultra -incremental -timing_high_effort_script
}

# Optional extra incremental passes for hot-path closure.
for {set i 0} {$i < $HOTPATH_EXTRA_INCREMENTAL_PASSES} {incr i} {
  if {$RETIME_ACTIVE} {
    compile_ultra -incremental -retime -timing_high_effort_script
  } else {
    compile_ultra -incremental -timing_high_effort_script
  }
}

#=============================== Reports ========================================
check_timing > ${REPORT_DIR}/check_timing.rpt
report_qor > ${REPORT_DIR}/qor.rpt
report_constraint -all_violators > ${REPORT_DIR}/constraint_violators.rpt
report_path_group > ${REPORT_DIR}/path_groups.rpt

report_timing -delay_type max -max_paths 20 -nworst 1 \
  -transition_time -capacitance -nets -attributes \
  > ${REPORT_DIR}/timing_setup_top20.rpt

report_timing -delay_type min -max_paths 20 -nworst 1 \
  -transition_time -capacitance -nets -attributes \
  > ${REPORT_DIR}/timing_hold_top20.rpt

if {$ENABLE_HOTPATH_STEERING} {
  refresh_hotpath_collections
  redirect ${REPORT_DIR}/hotpath_match.postcompile.rpt {
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
    report_timing -delay_type max -max_paths 10 -nworst 1 \
      -from $ALU_FROM -to $ALU_TO -transition_time -capacitance -nets \
      > ${REPORT_DIR}/timing_hot_alu.rpt
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
