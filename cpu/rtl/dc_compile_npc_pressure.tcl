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

set TOP         riscv
set CLK_PORT    clk
set CLK_PERIOD  3.0

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
    $RTL_DIR/IM.v \
    $RTL_DIR/InstructionCache.v \
    $RTL_DIR/InstructionDecoder.v \
    $RTL_DIR/NPC.v \
    $RTL_DIR/PC.v \
    $RTL_DIR/PipelineRegisters.v \
    $RTL_DIR/RF.v \
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

if {[sizeof_collection [get_ports -quiet rst]] > 0} {
    set_false_path -from [get_ports rst]
}

# The SRAM macro has a CLK-to-Q longer than one core period. Both local
# Wishbone slaves functionally wait until the second edge before a consumer
# captures Q. The instruction SRAM is captured by the low refill register and
# by the slave's 64-bit line buffer; subsequent accesses use the line buffer,
# so the SRAM no longer drives the cache data array directly. Target these
# actual capture-register D pins explicitly so DC cannot silently check the
# SRAM paths as single-cycle paths.
set IM_Q_PINS [get_pins -quiet \
    U_InstructionMemorySlave/U_IM/memory/Q*]
set ICACHE_REFILL_REGS [get_cells -quiet -hierarchical -filter \
    {full_name =~ U_InstructionMemorySlave/buffered_line_data_reg* || \
     full_name =~ U_InstructionCache/refill_word_reg* || \
     full_name =~ U_ControlUnit/U_FetchDecodeRegisters/*_reg*}]
set ICACHE_REFILL_D_PINS [get_pins -quiet -of_objects \
    $ICACHE_REFILL_REGS -filter {name == D}]

if {[sizeof_collection $IM_Q_PINS] > 0 &&
    [sizeof_collection $ICACHE_REFILL_D_PINS] > 0} {
    set_multicycle_path 2 -setup -from $IM_Q_PINS \
        -to $ICACHE_REFILL_D_PINS
    set_multicycle_path 1 -hold -from $IM_Q_PINS \
        -to $ICACHE_REFILL_D_PINS
} else {
    puts "ERROR: instruction SRAM refill multicycle pins were not found."
    exit 1
}

set DM_Q_PINS [get_pins -quiet U_DataMemorySlave/U_DM/memory/Q*]
set DM_CAPTURE_REGS [get_cells -quiet -hierarchical -filter \
    {full_name =~ U_ControlUnit/U_MemoryWritebackRegisters/wb_data_reg*}]
set DM_CAPTURE_D_PINS [get_pins -quiet -of_objects $DM_CAPTURE_REGS \
    -filter {name == D}]

if {[sizeof_collection $DM_Q_PINS] > 0 &&
    [sizeof_collection $DM_CAPTURE_D_PINS] > 0} {
    set_multicycle_path 2 -setup -from $DM_Q_PINS \
        -to $DM_CAPTURE_D_PINS
    set_multicycle_path 1 -hold -from $DM_Q_PINS \
        -to $DM_CAPTURE_D_PINS
} else {
    puts "ERROR: data SRAM capture multicycle pins were not found."
    exit 1
}

# One baseline mapping pass. No compile_ultra, retiming, path groups,
# incremental recompilation, or path-specific constraints are used.
compile

redirect -file $REPORT_DIR/check_design.rpt {check_design}
redirect -file $REPORT_DIR/check_timing.rpt {check_timing}
redirect -file $REPORT_DIR/area.rpt {report_area}
redirect -file $REPORT_DIR/qor.rpt {report_qor}
redirect -file $REPORT_DIR/timing.rpt {
    report_timing -delay max -max_paths 10
}

write_file -format ddc -hierarchy \
    -output $RESULT_DIR/${TOP}_minimal.ddc
write_file -format verilog -hierarchy \
    -output $RESULT_DIR/${TOP}_minimal.v
write_sdc $RESULT_DIR/${TOP}_minimal.sdc

puts "Minimal synthesis completed."
puts "Reports: $REPORT_DIR"
puts "Results: $RESULT_DIR"
