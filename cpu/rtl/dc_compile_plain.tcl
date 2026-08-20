# Basic Design Compiler synthesis flow.
#
# Run from cpu/rtl:
#   dc_shell -f dc_compile_plain.tcl
#
# This script intentionally has no path-specific optimization directives.

set SCRIPT_DIR [file dirname [file normalize [info script]]]
cd $SCRIPT_DIR

set TOP        riscv
set CLK_NAME   clock
set CLK_PORT   clk
set CLK_PERIOD 5.0
set CLK_HALF   [expr {$CLK_PERIOD / 2.0}]

set REPORT_DIR ./reports_compile_plain
set RESULT_DIR ./results_compile_plain
set WORK_DIR   ./work_compile_plain

file mkdir $REPORT_DIR
file mkdir $RESULT_DIR
file mkdir $WORK_DIR

remove_design -all
define_design_lib WORK -path $WORK_DIR

set_app_var search_path [list ./rtl ./rtl/includes]
if {[info exists synthetic_library]} {
    if {[lsearch -exact $synthetic_library dw_foundation.sldb] < 0} {
        set_app_var synthetic_library [concat $synthetic_library [list dw_foundation.sldb]]
    }
} else {
    set_app_var synthetic_library [list dw_foundation.sldb]
}

# ALU_original.v is a comparison copy that currently declares module ALU, so it
# must not be analyzed alongside the production ALU.v.
set rtl_files [lsort [glob -nocomplain ./rtl/*.v]]
set rtl_files [lsearch -all -inline -not -exact $rtl_files ./rtl/ALU_original.v]
if {[llength $rtl_files] == 0} {
    puts "ERROR: no RTL files were found under ./rtl"
    exit 1
}

analyze -format verilog -define {SRAM SYNTHESIS} $rtl_files

if {[catch {elaborate $TOP} elaborate_msg]} {
    puts "ERROR: elaborate failed for design $TOP."
    puts $elaborate_msg
    exit 1
}
current_design $TOP

if {[catch {link} link_msg]} {
    puts "ERROR: link failed."
    puts "Please make sure .synopsys_dc.setup loads the standard-cell DB and SRAM macro DB."
    puts $link_msg
    exit 1
}

check_design

create_clock -name $CLK_NAME -period $CLK_PERIOD \
    -waveform [list 0 $CLK_HALF] [get_ports $CLK_PORT]

if {[sizeof_collection [get_ports -quiet rst]] > 0} {
    set_case_analysis 0 [get_ports rst]
    set_false_path -from [get_ports rst]
}

compile

redirect -file $REPORT_DIR/check_design.rpt {check_design}
redirect -file $REPORT_DIR/check_timing.rpt {check_timing}
redirect -file $REPORT_DIR/qor.rpt {report_qor}
redirect -file $REPORT_DIR/area.rpt {report_area}
redirect -file $REPORT_DIR/reference.rpt {report_reference}
redirect -file $REPORT_DIR/constraint.rpt {report_constraint -all_violators}
redirect -file $REPORT_DIR/timing_max_20.rpt {
    report_timing -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time
}

write_file -format ddc     -hierarchy -output $RESULT_DIR/${TOP}_plain.ddc
write_file -format verilog -hierarchy -output $RESULT_DIR/${TOP}_plain.v
write_sdc $RESULT_DIR/${TOP}_plain.sdc

puts "Basic synthesis completed."
puts "Reports  : $REPORT_DIR"
puts "Results  : $RESULT_DIR"
