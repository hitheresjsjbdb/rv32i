# Minimal Design Compiler synthesis flow.
#
# Expected server layout relative to this script:
#   ./rtl/*.v
#   ./rtl/includes/*.v
#
# Run with:
#   dc_shell -f dc_compile_npc_pressure.tcl | tee dc_compile_minimal.log
#
# The standard-cell and SRAM macro libraries must already be configured by
# .synopsys_dc.setup. This script deliberately adds no path-specific or
# high-effort optimization directives.

set SCRIPT_DIR [file dirname [file normalize [info script]]]
cd $SCRIPT_DIR

set TOP                riscv
set CLK_PORT           clk
set CLK_PERIOD         4.0
set TARGET_SETUP_SLACK 0.10
set HOLD_UNCERTAINTY   0.05
set CRITICAL_RANGE     0.20

set RTL_DIR     ./rtl
set INCLUDE_DIR ./rtl/includes
set WORK_DIR    ./work_compile_minimal
set REPORT_DIR  ./reports_compile_minimal
set RESULT_DIR  ./results_compile_minimal

file mkdir $WORK_DIR
file mkdir $REPORT_DIR
file mkdir $RESULT_DIR

remove_design -all
define_design_lib WORK -path $WORK_DIR
set_app_var search_path [concat $search_path [list $RTL_DIR $INCLUDE_DIR]]

# Use an explicit source list. Do not use "glob ./rtl/*.v": backup or
# comparison files can declare a production module for a second time.
set RTL_FILES [list \
    $RTL_DIR/ALU.v \
    $RTL_DIR/ControlUnit.v \
    $RTL_DIR/DM.v \
    $RTL_DIR/ExceptionUnit.v \
    $RTL_DIR/Flopr.v \
    $RTL_DIR/ForwardingUnit.v \
    $RTL_DIR/HazardUnit.v \
    $RTL_DIR/IDOperandSelector.v \
    $RTL_DIR/IDRedirectUnit.v \
    $RTL_DIR/IM.v \
    $RTL_DIR/InstructionFields.v \
    $RTL_DIR/InstructionDecoder.v \
    $RTL_DIR/NPC.v \
    $RTL_DIR/PC.v \
    $RTL_DIR/PipelineRegisters.v \
    $RTL_DIR/RF.v \
    $RTL_DIR/WishboneInstructionMaster.v \
    $RTL_DIR/WishboneLocalRouter.v \
    $RTL_DIR/WishboneMaster.v \
    $RTL_DIR/WishboneInstructionMemory.v \
    $RTL_DIR/WishboneDataMemory.v \
    $RTL_DIR/riscv.v \
]

foreach RTL_FILE $RTL_FILES {
    if {![file isfile $RTL_FILE]} {
        puts "ERROR: missing RTL source: $RTL_FILE"
        exit 1
    }
}

puts "Analyzing production RTL files:"
foreach RTL_FILE $RTL_FILES {
    puts "  $RTL_FILE"
}

if {[catch {
    analyze -format verilog -define {SRAM SYNTHESIS} $RTL_FILES
} ANALYZE_MESSAGE]} {
    puts "ERROR: RTL analysis failed."
    puts $ANALYZE_MESSAGE
    exit 1
}

if {[catch {elaborate $TOP} ELABORATE_MESSAGE]} {
    puts "ERROR: elaboration failed for $TOP."
    puts $ELABORATE_MESSAGE
    exit 1
}

current_design $TOP

if {[catch {link} LINK_MESSAGE]} {
    puts "ERROR: link failed."
    puts "Check target_library/link_library and the SRAM macro DB in .synopsys_dc.setup."
    puts $LINK_MESSAGE
    exit 1
}

check_design

create_clock -name core_clock -period $CLK_PERIOD [get_ports $CLK_PORT]
set_clock_uncertainty -setup $TARGET_SETUP_SLACK [get_clocks core_clock]
set_clock_uncertainty -hold $HOLD_UNCERTAINTY [get_clocks core_clock]
set_critical_range $CRITICAL_RANGE [current_design]
set_fix_hold [get_clocks core_clock]

if {[sizeof_collection [get_ports -quiet rst]] > 0} {
    set_false_path -from [get_ports rst]
}

# Reserve setup margin through clock uncertainty, prioritize delay around the
# critical cone, and let mapping insert cells where minimum-delay repair is
# required. No multicycle or path-specific exceptions are used.
set_cost_priority -delay
compile

redirect -file $REPORT_DIR/check_design.rpt {check_design}
redirect -file $REPORT_DIR/check_timing.rpt {check_timing}
redirect -file $REPORT_DIR/area.rpt {report_area}
redirect -file $REPORT_DIR/qor.rpt {report_qor}
redirect -file $REPORT_DIR/timing.rpt {
    report_timing -delay max -max_paths 20 -nworst 1 \
        -input_pins -nets -transition_time
}
redirect -file $REPORT_DIR/timing_setup.rpt {
    report_timing -delay max -max_paths 20 -nworst 1 \
        -input_pins -nets -transition_time
}
redirect -file $REPORT_DIR/timing_hold.rpt {
    report_timing -delay min -max_paths 20 -nworst 1 \
        -input_pins -nets -transition_time
}
redirect -file $REPORT_DIR/constraint_violators.rpt {
    report_constraint -all_violators
}

write_file -format ddc -hierarchy \
    -output $RESULT_DIR/${TOP}_minimal.ddc
write_file -format verilog -hierarchy \
    -output $RESULT_DIR/${TOP}_minimal.v
write_sdc $RESULT_DIR/${TOP}_minimal.sdc

puts "Minimal synthesis completed."
puts "Clock period: $CLK_PERIOD ns"
puts "Target setup margin: $TARGET_SETUP_SLACK ns"
puts "Hold uncertainty: $HOLD_UNCERTAINTY ns"
puts "Reports: $REPORT_DIR"
puts "Results: $RESULT_DIR"
