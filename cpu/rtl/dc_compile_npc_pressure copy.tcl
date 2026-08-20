# Design Compiler flow with pressure on the observed branch-target path:
#   U_ControlUnit/U_IDEX_Offset*/Q -> U_NPC -> U_PC/PC_reg*/D

set SCRIPT_DIR [file dirname [file normalize [info script]]]
cd $SCRIPT_DIR

set TOP        riscv
set CLK_NAME   clock
set CLK_PORT   clk
set CLK_PERIOD 5.0
set CLK_HALF   [expr {$CLK_PERIOD / 2.0}]
# Pre-CTS clock modeling.  The physical clock tree is built later by ICC, so
# keep it ideal here but reserve realistic slew/skew/jitter margins.
set CLK_TRANSITION        0.10
set CLK_SETUP_UNCERTAINTY 0.15
set CLK_HOLD_UNCERTAINTY  0.05

# The observed unpressured path arrives at about 4.78ns.  This tighter budget
# asks DC to spend effort specifically on the branch-target carry chain.
set NPC_OFFSET_TO_PC_BUDGET 4.55
# The current worst path is IF/ID.rs1 Q -> RF read decode -> ControlUnit /
# IRWrite -> IR -> IF/ID.Offset D, measured at about 4.95ns.
set IFID_RS1_TO_OFFSET_BUDGET 4.5
# Instruction SRAM clock-to-Q is fixed by the macro; this budget asks DC to
# optimize only the IM-output/IR/decode logic that follows it.
set IM_Q_TO_IFID_OFFSET_BUDGET 4.75

set REPORT_DIR ./reports_compile_npc_pressure
set RESULT_DIR ./results_compile_npc_pressure
set WORK_DIR   ./work_compile_npc_pressure

file mkdir $REPORT_DIR
file mkdir $RESULT_DIR
file mkdir $WORK_DIR

remove_design -all
define_design_lib WORK -path $WORK_DIR

set_app_var search_path [list . ./rtl ./rtl/includes]
if {[info exists synthetic_library]} {
    if {[lsearch -exact $synthetic_library dw_foundation.sldb] < 0} {
        set_app_var synthetic_library [concat $synthetic_library [list dw_foundation.sldb]]
    }
} else {
    set_app_var synthetic_library [list dw_foundation.sldb]
}

# Prefer the server's single, flattened RTL source.  It contains the riscv
# top module and all submodules; its `include directives resolve through the
# search paths above.  Keep a module-tree fallback for this local workspace.
set flat_rtl_file ./riscv.v
if {[file exists $flat_rtl_file]} {
    set rtl_files [list $flat_rtl_file]
    set rtl_source_mode "flat: $flat_rtl_file"
} else {
    # ALU_original.v is a comparison copy that declares module ALU, so it
    # cannot be analyzed with the production ALU.v in the same compilation.
    set rtl_files [lsort [glob -nocomplain ./rtl/*.v]]
    set rtl_files [lsearch -all -inline -not -exact $rtl_files ./rtl/ALU_original.v]
    set rtl_source_mode "module tree: ./rtl/*.v"
}
if {[llength $rtl_files] == 0} {
    puts "ERROR: neither ./riscv.v nor RTL source files under ./rtl were found"
    exit 1
}
puts "RTL source mode: $rtl_source_mode"

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

# Use an explicit, reproducible pre-layout interconnect estimate instead of
# inheriting the server's default wire-load selection.
set WIRE_LOAD_LIBRARY tcbn65lpwc
set WIRE_LOAD_MODEL   TSMC32K_Lowk_Conservative
set_wire_load_model -name $WIRE_LOAD_MODEL -library $WIRE_LOAD_LIBRARY
set_wire_load_mode top

create_clock -name $CLK_NAME -period $CLK_PERIOD \
    -waveform [list 0 $CLK_HALF] [get_ports $CLK_PORT]
set_clock_transition $CLK_TRANSITION [get_clocks $CLK_NAME]
set_clock_uncertainty -setup $CLK_SETUP_UNCERTAINTY [get_clocks $CLK_NAME]
set_clock_uncertainty -hold  $CLK_HOLD_UNCERTAINTY  [get_clocks $CLK_NAME]
# Do not let pre-CTS synthesis build or reshape a clock tree.  CTS/clock_opt
# will later create the physical clock network and account for real skew.
set_dont_touch_network [get_ports $CLK_PORT]
set_ideal_network [get_ports $CLK_PORT]

if {[sizeof_collection [get_ports -quiet rst]] > 0} {
    set_case_analysis 0 [get_ports rst]
    set_false_path -from [get_ports rst]
}

# Preserve the explicit prefix-adder topology.  Without this, DC may
# algebraically recognize the AND/OR/XOR network as '+' and remap it back to a
# ripple DesignWare adder.
set npc_prefix_adders [get_cells -quiet -hier U_NPC/U_NPC_*]
set jalr_prefix_adders [get_cells -quiet -hier U_NPC/U_JALR_*]
set alu_prefix_adders [get_cells -quiet -hier U_ALU/U_PREFIX_*]
if {[sizeof_collection $jalr_prefix_adders] > 0} {
    if {[sizeof_collection $npc_prefix_adders] > 0} {
        set npc_prefix_adders [add_to_collection $npc_prefix_adders $jalr_prefix_adders]
    } else {
        set npc_prefix_adders $jalr_prefix_adders
    }
}
if {[sizeof_collection $alu_prefix_adders] > 0} {
    if {[sizeof_collection $npc_prefix_adders] > 0} {
        set npc_prefix_adders [add_to_collection $npc_prefix_adders $alu_prefix_adders]
    } else {
        set npc_prefix_adders $alu_prefix_adders
    }
}
if {[sizeof_collection $npc_prefix_adders] > 0} {
    catch {set_dont_touch $npc_prefix_adders}
    catch {set_ungroup $npc_prefix_adders false}
}

# Create legal STA endpoints from elaborated register cells, then obtain their
# Q/D pins.  Hierarchical module ports are not valid set_max_delay endpoints.
set all_seq        [all_registers -clock [get_clocks $CLK_NAME]]
set offset12_regs [filter_collection $all_seq {full_name =~ *U_ControlUnit/U_IDEX_Offset/out_data_reg*}]
set offset20_regs [filter_collection $all_seq {full_name =~ *U_ControlUnit/U_IDEX_Offset20/out_data_reg*}]
set offset12_src  [filter_collection [get_pins -quiet -of_objects $offset12_regs] {full_name =~ */Q}]
set offset20_src  [filter_collection [get_pins -quiet -of_objects $offset20_regs] {full_name =~ */Q}]
set pc_regs        [filter_collection $all_seq {full_name =~ *U_PC/PC_reg*}]
# Obtain endpoint pins through register cells.  In this DC version, a direct
# hierarchical get_pins pattern can return an empty collection for D pins.
set pc_reg_cells [get_cells -quiet -hier U_PC/PC_reg*]
set pc_d_pins [filter_collection [get_pins -quiet -of_objects $pc_reg_cells] {full_name =~ */D}]
if {[sizeof_collection $pc_d_pins] == 0} {
    set pc_reg_cells [filter_collection [get_cells -quiet -hier *] {full_name =~ *U_PC/PC_reg*}]
    set pc_d_pins [filter_collection [get_pins -quiet -of_objects $pc_reg_cells] {full_name =~ */D}]
}
if {[sizeof_collection $pc_d_pins] == 0} {
    set pc_d_pins [filter_collection [get_pins -quiet -of_objects $pc_regs] {full_name =~ */D}]
}

# Legal endpoints for the observed RF/decode/IR control path.
set ifid_rs1_regs [filter_collection $all_seq {full_name =~ *U_ControlUnit/U_IFID_rs1/out_data_reg*}]
# Use the exact launch/capture bits from the observed worst-path report.  The
# braces keep Verilog bit-select brackets literal in Tcl/DC object lookup.
set ifid_rs1_q_pins [get_pins -quiet {U_ControlUnit/U_IFID_rs1/out_data_reg[0]/Q}]
if {[sizeof_collection $ifid_rs1_q_pins] == 0} {
    set ifid_rs1_q_pins [filter_collection [get_pins -quiet -of_objects $ifid_rs1_regs] {full_name =~ */Q}]
}
set ifid_offset_regs [filter_collection $all_seq {full_name =~ *U_ControlUnit/U_IFID_Offset/out_data_reg*}]
set ifid_offset_d_pins [get_pins -quiet {U_ControlUnit/U_IFID_Offset/out_data_reg[8]/D}]
if {[sizeof_collection $ifid_offset_d_pins] == 0} {
    # ControlUnit.v in some revisions uses the original misspelled instance
    # name U_IFID_Offet; accept both spellings when locating this endpoint.
    set ifid_offset_regs [filter_collection $all_seq {full_name =~ *U_ControlUnit/U_IFID_Offet/out_data_reg*}]
    set ifid_offset_d_pins [get_pins -quiet {U_ControlUnit/U_IFID_Offet/out_data_reg[8]/D}]
}
if {[sizeof_collection $ifid_offset_d_pins] == 0} {
    set ifid_offset_cells [get_cells -quiet -hier U_ControlUnit/U_IFID_Offset/out_data_reg*]
    set ifid_offset_d_pins [filter_collection [get_pins -quiet -of_objects $ifid_offset_cells] {full_name =~ */D}]
}
if {[sizeof_collection $ifid_offset_d_pins] == 0} {
    set ifid_offset_cells [get_cells -quiet -hier U_ControlUnit/U_IFID_Offet/out_data_reg*]
    set ifid_offset_d_pins [filter_collection [get_pins -quiet -of_objects $ifid_offset_cells] {full_name =~ */D}]
}
if {[sizeof_collection $ifid_offset_d_pins] == 0} {
    set ifid_offset_cells [filter_collection [get_cells -quiet -hier *] {full_name =~ *U_ControlUnit/U_IFID_Offset/out_data_reg*}]
    set ifid_offset_d_pins [filter_collection [get_pins -quiet -of_objects $ifid_offset_cells] {full_name =~ */D}]
}
if {[sizeof_collection $ifid_offset_d_pins] == 0} {
    set ifid_offset_cells [filter_collection [get_cells -quiet -hier *] {full_name =~ *U_ControlUnit/U_IFID_Offet/out_data_reg*}]
    set ifid_offset_d_pins [filter_collection [get_pins -quiet -of_objects $ifid_offset_cells] {full_name =~ */D}]
}
if {[sizeof_collection $ifid_offset_d_pins] == 0} {
    set ifid_offset_d_pins [filter_collection [get_pins -quiet -of_objects $ifid_offset_regs] {full_name =~ */D}]
}
set npc_sources   $offset12_src
if {[sizeof_collection $offset20_src] > 0} {
    if {[sizeof_collection $npc_sources] > 0} {
        set npc_sources [add_to_collection $npc_sources $offset20_src]
    } else {
        set npc_sources $offset20_src
    }
}
set npc_hierarchy [get_cells -quiet U_NPC]
set npc_pressure_applied 0
set npc_group_status 1
set npc_delay_status 1
set npc_group_msg "not attempted"
set npc_delay_msg "not attempted"
set ifid_pressure_applied 0
set ifid_group_status 1
set ifid_delay_status 1
set ifid_group_msg "not attempted"
set ifid_delay_msg "not attempted"

# The object report above must be non-empty before applying constraints.  Catch
# each command separately and record DC's response rather than silently
# skipping the pressure when an object or command form is unsupported.
if {[sizeof_collection $npc_sources] == 0 || \
    [sizeof_collection $pc_d_pins] == 0} {
    set npc_group_msg "not attempted: source or endpoint collection is empty"
    set npc_delay_msg "not attempted: source or endpoint collection is empty"
} else {
    set npc_group_status [catch {
        group_path -name NPC_OFFSET_TO_PC \
            -from $npc_sources -to $pc_d_pins \
            -weight 80 -critical_range 0.40
    } npc_group_msg]
    set npc_delay_status [catch {
        set_max_delay $NPC_OFFSET_TO_PC_BUDGET \
            -from $npc_sources -to $pc_d_pins
    } npc_delay_msg]

    if {$npc_group_status == 0 && $npc_delay_status == 0} {
        # Permit DC to simplify the branch-target cone across the NPC boundary.
        catch {set_boundary_optimization $npc_hierarchy true}
        set npc_pressure_applied 1
    }
}

# Derive the diagnostic flag directly from the command statuses so the report
# cannot disagree with successfully created constraints.
set npc_pressure_applied [expr {$npc_group_status == 0 && $npc_delay_status == 0}]

# Give the currently observed RF/decode/IR path an independent timing budget.
# This changes only synthesis constraints; RTL behavior and module interfaces
# remain untouched.
if {[sizeof_collection $ifid_rs1_q_pins] == 0 || \
    [sizeof_collection $ifid_offset_d_pins] == 0} {
    set ifid_group_msg "not attempted: source or endpoint collection is empty"
    set ifid_delay_msg "not attempted: source or endpoint collection is empty"
} else {
    set ifid_group_status [catch {
        group_path -name IFID_RS1_TO_OFFSET \
            -from $ifid_rs1_q_pins -to $ifid_offset_d_pins \
            -weight 100 -critical_range 0.40
    } ifid_group_msg]
    set ifid_delay_status [catch {
        set_max_delay $IFID_RS1_TO_OFFSET_BUDGET \
            -from $ifid_rs1_q_pins -to $ifid_offset_d_pins
    } ifid_delay_msg]
}
set ifid_pressure_applied [expr {$ifid_group_status == 0 && $ifid_delay_status == 0}]

redirect -file $REPORT_DIR/npc_pressure_objects.rpt {
    echo "NPC offset-to-PC pressure objects"
    echo "NPC pressure applied (1=yes):"
    echo $npc_pressure_applied
    echo "group_path status (0=success):"
    echo $npc_group_status
    echo "group_path response:"
    echo $npc_group_msg
    echo "set_max_delay status (0=success):"
    echo $npc_delay_status
    echo "set_max_delay response:"
    echo $npc_delay_msg
    echo "NPC source Q-pin count:"
    echo [sizeof_collection $npc_sources]
    query_objects $npc_sources
    echo "PC register D-pin count:"
    echo [sizeof_collection $pc_d_pins]
    query_objects $pc_d_pins
    echo ""
    echo "IF/ID rs1-to-Offset pressure objects"
    echo "IF/ID pressure applied (1=yes):"
    echo $ifid_pressure_applied
    echo "group_path status (0=success):"
    echo $ifid_group_status
    echo "group_path response:"
    echo $ifid_group_msg
    echo "set_max_delay status (0=success):"
    echo $ifid_delay_status
    echo "set_max_delay response:"
    echo $ifid_delay_msg
    echo "IF/ID rs1 source Q-pin count:"
    echo [sizeof_collection $ifid_rs1_q_pins]
    query_objects $ifid_rs1_q_pins
    echo "IF/ID Offset D-pin count:"
    echo [sizeof_collection $ifid_offset_d_pins]
    query_objects $ifid_offset_d_pins
}

compile -map_effort high

# Use the same legal Q/D endpoint construction for the post-compile report.
set post_regs         [all_registers -clock [get_clocks $CLK_NAME]]
set offset12_regs_post [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IDEX_Offset/out_data_reg*}]
set offset20_regs_post [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IDEX_Offset20/out_data_reg*}]
set npc_sources_post [filter_collection [get_pins -quiet -of_objects $offset12_regs_post] {full_name =~ */Q}]
set offset20_src_post [filter_collection [get_pins -quiet -of_objects $offset20_regs_post] {full_name =~ */Q}]
if {[sizeof_collection $offset20_src_post] > 0} {
    if {[sizeof_collection $npc_sources_post] > 0} {
        set npc_sources_post [add_to_collection $npc_sources_post $offset20_src_post]
    } else {
        set npc_sources_post $offset20_src_post
    }
}
set pc_regs_post [filter_collection $post_regs {full_name =~ *U_PC/PC_reg*}]
set pc_reg_cells_post [get_cells -quiet -hier U_PC/PC_reg*]
set pc_d_pins_post [filter_collection [get_pins -quiet -of_objects $pc_reg_cells_post] {full_name =~ */D}]
if {[sizeof_collection $pc_d_pins_post] == 0} {
    set pc_reg_cells_post [filter_collection [get_cells -quiet -hier *] {full_name =~ *U_PC/PC_reg*}]
    set pc_d_pins_post [filter_collection [get_pins -quiet -of_objects $pc_reg_cells_post] {full_name =~ */D}]
}
if {[sizeof_collection $pc_d_pins_post] == 0} {
    set pc_d_pins_post [filter_collection [get_pins -quiet -of_objects $pc_regs_post] {full_name =~ */D}]
}

set ifid_rs1_regs_post [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IFID_rs1/out_data_reg*}]
set ifid_rs1_q_pins_post [get_pins -quiet {U_ControlUnit/U_IFID_rs1/out_data_reg[0]/Q}]
if {[sizeof_collection $ifid_rs1_q_pins_post] == 0} {
    set ifid_rs1_q_pins_post [filter_collection [get_pins -quiet -of_objects $ifid_rs1_regs_post] {full_name =~ */Q}]
}
set ifid_offset_regs_post [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IFID_Offset/out_data_reg*}]
set ifid_offset_d_pins_post [get_pins -quiet {U_ControlUnit/U_IFID_Offset/out_data_reg[8]/D}]
if {[sizeof_collection $ifid_offset_d_pins_post] == 0} {
    set ifid_offset_regs_post [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IFID_Offet/out_data_reg*}]
    set ifid_offset_d_pins_post [get_pins -quiet {U_ControlUnit/U_IFID_Offet/out_data_reg[8]/D}]
}
if {[sizeof_collection $ifid_offset_d_pins_post] == 0} {
    set ifid_offset_cells_post [get_cells -quiet -hier U_ControlUnit/U_IFID_Offset/out_data_reg*]
    set ifid_offset_d_pins_post [filter_collection [get_pins -quiet -of_objects $ifid_offset_cells_post] {full_name =~ */D}]
}
if {[sizeof_collection $ifid_offset_d_pins_post] == 0} {
    set ifid_offset_cells_post [get_cells -quiet -hier U_ControlUnit/U_IFID_Offet/out_data_reg*]
    set ifid_offset_d_pins_post [filter_collection [get_pins -quiet -of_objects $ifid_offset_cells_post] {full_name =~ */D}]
}
if {[sizeof_collection $ifid_offset_d_pins_post] == 0} {
    set ifid_offset_cells_post [filter_collection [get_cells -quiet -hier *] {full_name =~ *U_ControlUnit/U_IFID_Offset/out_data_reg*}]
    set ifid_offset_d_pins_post [filter_collection [get_pins -quiet -of_objects $ifid_offset_cells_post] {full_name =~ */D}]
}
if {[sizeof_collection $ifid_offset_d_pins_post] == 0} {
    set ifid_offset_cells_post [filter_collection [get_cells -quiet -hier *] {full_name =~ *U_ControlUnit/U_IFID_Offet/out_data_reg*}]
    set ifid_offset_d_pins_post [filter_collection [get_pins -quiet -of_objects $ifid_offset_cells_post] {full_name =~ */D}]
}
if {[sizeof_collection $ifid_offset_d_pins_post] == 0} {
    set ifid_offset_d_pins_post [filter_collection [get_pins -quiet -of_objects $ifid_offset_regs_post] {full_name =~ */D}]
}

# The mapped D pin of U_IFID_Offet is not visible before the first compile in
# this DC setup.  Apply this path pressure after that mapping pass, then run a
# second high-effort compile so it can optimize against the real endpoints.
set postmap_recompile_needed 0
set im_postmap_pressure_applied 0
set im_postmap_group_status 1
set im_postmap_delay_status 1
set im_postmap_group_msg "not attempted"
set im_postmap_delay_msg "not attempted"
# IM instruction bits are the lower 32 outputs of the 64-bit SRAM macro.
set im_q_pins_post [get_pins -quiet {__im_no_such_source__}]
for {set bit 0} {$bit < 32} {incr bit} {
    set source_pin [get_pins -quiet [format {U_IM/memory/Q[%d]} $bit]]
    if {[sizeof_collection $source_pin] > 0} {
        set im_q_pins_post [add_to_collection $im_q_pins_post $source_pin]
    }
}
set im_offset_d_pins_post [get_pins -quiet {__im_no_such_destination__}]
for {set bit 0} {$bit < 12} {incr bit} {
    set destination_pin [get_pins -quiet \
        [format {U_ControlUnit/U_IFID_Offet/out_data_reg[%d]/D} $bit]]
    if {[sizeof_collection $destination_pin] == 0} {
        set destination_pin [get_pins -quiet \
            [format {U_ControlUnit/U_IFID_Offset/out_data_reg[%d]/D} $bit]]
    }
    if {[sizeof_collection $destination_pin] > 0} {
        set im_offset_d_pins_post [add_to_collection $im_offset_d_pins_post $destination_pin]
    }
}
if {[sizeof_collection $im_q_pins_post] > 0 && \
    [sizeof_collection $im_offset_d_pins_post] > 0} {
    set im_postmap_group_status [catch {
        group_path -name IM_Q_TO_IFID_OFFSET_POSTMAP \
            -from $im_q_pins_post -to $im_offset_d_pins_post \
            -weight 100 -critical_range 0.40
    } im_postmap_group_msg]
    set im_postmap_delay_status [catch {
        set_max_delay $IM_Q_TO_IFID_OFFSET_BUDGET \
            -from $im_q_pins_post -to $im_offset_d_pins_post
    } im_postmap_delay_msg]
    set im_postmap_pressure_applied [expr {$im_postmap_group_status == 0 && $im_postmap_delay_status == 0}]
    if {$im_postmap_pressure_applied} {
        set postmap_recompile_needed 1
    }
} else {
    set im_postmap_group_msg "not attempted: post-map SRAM Q or IF/ID Offset D collection is empty"
    set im_postmap_delay_msg "not attempted: post-map SRAM Q or IF/ID Offset D collection is empty"
}

set npc_postmap_pressure_applied 0
set npc_postmap_group_status 1
set npc_postmap_delay_status 1
set npc_postmap_group_msg "not attempted"
set npc_postmap_delay_msg "not attempted"
# Build the complete mapped NPC-input-Q to PC-D endpoint sets.  NPC can be
# driven by EX PC, Offset12, Offset20, or the JALR base; constraining only one
# source class lets the critical path migrate to another candidate.
set npc_critical_src_post [get_pins -quiet {__npc_no_such_source__}]
for {set bit 0} {$bit < 12} {incr bit} {
    set source_pin [get_pins -quiet \
        [format {U_ControlUnit/U_IDEX_Offset/out_data_reg[%d]/Q} $bit]]
    if {[sizeof_collection $source_pin] > 0} {
        set npc_critical_src_post [add_to_collection $npc_critical_src_post $source_pin]
    }
}
for {set bit 0} {$bit < 32} {incr bit} {
    set source_pin [get_pins -quiet \
        [format {U_ControlUnit/U_IDEX_PC/out_data_reg[%d]/Q} $bit]]
    if {[sizeof_collection $source_pin] > 0} {
        set npc_critical_src_post [add_to_collection $npc_critical_src_post $source_pin]
    }
}
for {set bit 0} {$bit < 20} {incr bit} {
    set source_pin [get_pins -quiet \
        [format {U_ControlUnit/U_IDEX_Offset20/out_data_reg[%d]/Q} $bit]]
    if {[sizeof_collection $source_pin] > 0} {
        set npc_critical_src_post [add_to_collection $npc_critical_src_post $source_pin]
    }
}
for {set bit 0} {$bit < 32} {incr bit} {
    set source_pin [get_pins -quiet \
        [format {U_A/out_data_reg[%d]/Q} $bit]]
    if {[sizeof_collection $source_pin] > 0} {
        set npc_critical_src_post [add_to_collection $npc_critical_src_post $source_pin]
    }
}
set npc_critical_dst_post [get_pins -quiet {__npc_no_such_destination__}]
for {set bit 0} {$bit < 32} {incr bit} {
    set destination_pin [get_pins -quiet \
        [format {U_PC/PC_reg[%d]/D} $bit]]
    if {[sizeof_collection $destination_pin] > 0} {
        set npc_critical_dst_post [add_to_collection $npc_critical_dst_post $destination_pin]
    }
}
if {$npc_pressure_applied == 0 && \
    [sizeof_collection $npc_critical_src_post] > 0 && \
    [sizeof_collection $npc_critical_dst_post] > 0} {
    set npc_postmap_group_status [catch {
        group_path -name NPC_INPUTS_TO_PC_POSTMAP \
            -from $npc_critical_src_post -to $npc_critical_dst_post \
            -weight 100 -critical_range 0.40
    } npc_postmap_group_msg]
    set npc_postmap_delay_status [catch {
        set_max_delay $NPC_OFFSET_TO_PC_BUDGET \
            -from $npc_critical_src_post -to $npc_critical_dst_post
    } npc_postmap_delay_msg]
    set npc_postmap_pressure_applied [expr {$npc_postmap_group_status == 0 && $npc_postmap_delay_status == 0}]
    if {$npc_postmap_pressure_applied} {
        set postmap_recompile_needed 1
    }
} elseif {$npc_pressure_applied != 0} {
    set npc_postmap_group_status 0
    set npc_postmap_delay_status 0
    set npc_postmap_group_msg "pre-map constraint already applied"
    set npc_postmap_delay_msg "pre-map constraint already applied"
    set npc_postmap_pressure_applied 1
} else {
    set npc_postmap_group_msg "not attempted: post-map source or endpoint collection is empty"
    set npc_postmap_delay_msg "not attempted: post-map source or endpoint collection is empty"
}

set ifid_postmap_pressure_applied 0
set ifid_postmap_group_status 1
set ifid_postmap_delay_status 1
set ifid_postmap_group_msg "not attempted"
set ifid_postmap_delay_msg "not attempted"
if {$ifid_pressure_applied == 0 && \
    [sizeof_collection $ifid_rs1_q_pins_post] > 0 && \
    [sizeof_collection $ifid_offset_d_pins_post] > 0} {
    set ifid_postmap_group_status [catch {
        group_path -name IFID_RS1_TO_OFFSET_POSTMAP \
            -from $ifid_rs1_q_pins_post -to $ifid_offset_d_pins_post \
            -weight 100 -critical_range 0.40
    } ifid_postmap_group_msg]
    set ifid_postmap_delay_status [catch {
        set_max_delay $IFID_RS1_TO_OFFSET_BUDGET \
            -from $ifid_rs1_q_pins_post -to $ifid_offset_d_pins_post
    } ifid_postmap_delay_msg]
    set ifid_postmap_pressure_applied [expr {$ifid_postmap_group_status == 0 && $ifid_postmap_delay_status == 0}]
    if {$ifid_postmap_pressure_applied} {
        set postmap_recompile_needed 1
    }
} elseif {$ifid_pressure_applied != 0} {
    set ifid_postmap_group_status 0
    set ifid_postmap_delay_status 0
    set ifid_postmap_group_msg "pre-map constraint already applied"
    set ifid_postmap_delay_msg "pre-map constraint already applied"
    set ifid_postmap_pressure_applied 1
} else {
    set ifid_postmap_group_msg "not attempted: post-map source or endpoint collection is empty"
    set ifid_postmap_delay_msg "not attempted: post-map source or endpoint collection is empty"
}
if {$postmap_recompile_needed} {
    compile -map_effort high
}

# ALU slack analysis only: this does not add any ALU-specific timing pressure.
# The three source groups cover the registered A operand, B operand, and ALUOp
# control respectively; all are reported to the ALU-result register D pins.
set alu_a_regs_post [filter_collection $post_regs {full_name =~ *U_A/out_data_reg*}]
set alu_b_regs_post [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IDEX_ALU_B/out_data_reg*}]
set alu_op_regs_post [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IDEX_ALUOp/out_data_reg*}]
set alu_a_src_post [filter_collection [get_pins -quiet -of_objects $alu_a_regs_post] {full_name =~ */Q}]
set alu_b_src_post [filter_collection [get_pins -quiet -of_objects $alu_b_regs_post] {full_name =~ */Q}]
set alu_op_src_post [filter_collection [get_pins -quiet -of_objects $alu_op_regs_post] {full_name =~ */Q}]
set alu_sources_post $alu_a_src_post
if {[sizeof_collection $alu_b_src_post] > 0} {
    if {[sizeof_collection $alu_sources_post] > 0} {
        set alu_sources_post [add_to_collection $alu_sources_post $alu_b_src_post]
    } else {
        set alu_sources_post $alu_b_src_post
    }
}
if {[sizeof_collection $alu_op_src_post] > 0} {
    if {[sizeof_collection $alu_sources_post] > 0} {
        set alu_sources_post [add_to_collection $alu_sources_post $alu_op_src_post]
    } else {
        set alu_sources_post $alu_op_src_post
    }
}
set aluout_regs_post [filter_collection $post_regs {full_name =~ *U_ALUOut/out_data_reg*}]
set alu_d_pins_post [get_pins -quiet -hier *U_ALUOut/out_data_reg*/D]
if {[sizeof_collection $alu_d_pins_post] == 0} {
    set alu_d_pins_post [filter_collection [get_pins -quiet -of_objects $aluout_regs_post] {full_name =~ */D}]
}

redirect -file $REPORT_DIR/check_design.rpt {check_design}
redirect -file $REPORT_DIR/check_timing.rpt {check_timing}
redirect -file $REPORT_DIR/qor.rpt {report_qor}
redirect -file $REPORT_DIR/area.rpt {report_area}
# Power is an RTL/netlist estimate unless activity (for example SAIF/VCD) is
# supplied separately; still emit it with the timing/area reports for QoR use.
redirect -file $REPORT_DIR/power.rpt {report_power -hierarchy}
redirect -file $REPORT_DIR/constraint.rpt {report_constraint -all_violators}
# Explicitly keep setup and hold reports separate.  The hold report uses the
# min timing view when the DC environment provides a WC-to-BC set_min_library
# mapping; otherwise it is still emitted as a diagnostic of the loaded view.
redirect -file $REPORT_DIR/timing_setup.rpt {
    report_timing -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time
}
redirect -file $REPORT_DIR/timing_hold.rpt {
    report_timing -delay min -max_paths 20 -nworst 1 -input_pins -nets -transition_time
}
redirect -file $REPORT_DIR/timing_max_20.rpt {
    report_timing -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time
}

redirect -file $REPORT_DIR/alu_timing_objects.rpt {
    echo "ALU slack-analysis objects (reporting only; no ALU timing constraint added)"
    echo "A-operand source Q-pin count:"
    echo [sizeof_collection $alu_a_src_post]
    query_objects $alu_a_src_post
    echo "B-operand source Q-pin count:"
    echo [sizeof_collection $alu_b_src_post]
    query_objects $alu_b_src_post
    echo "ALUOp source Q-pin count:"
    echo [sizeof_collection $alu_op_src_post]
    query_objects $alu_op_src_post
    echo "ALU-result register D-pin count:"
    echo [sizeof_collection $alu_d_pins_post]
    query_objects $alu_d_pins_post
}

redirect -file $REPORT_DIR/ifid_rs1_to_offset_objects.rpt {
    echo "Post-compile IF/ID rs1-to-Offset timing objects"
    echo "IF/ID rs1 Q-pin count:"
    echo [sizeof_collection $ifid_rs1_q_pins_post]
    query_objects $ifid_rs1_q_pins_post
    echo "IF/ID Offset D-pin count:"
    echo [sizeof_collection $ifid_offset_d_pins_post]
    query_objects $ifid_offset_d_pins_post
}

redirect -file $REPORT_DIR/ifid_rs1_to_offset_pressure.rpt {
    echo "Post-map IF/ID rs1-to-Offset pressure status"
    echo "Pressure applied (1=yes):"
    echo $ifid_postmap_pressure_applied
    echo "group_path status (0=success):"
    echo $ifid_postmap_group_status
    echo "group_path response:"
    echo $ifid_postmap_group_msg
    echo "set_max_delay status (0=success):"
    echo $ifid_postmap_delay_status
    echo "set_max_delay response:"
    echo $ifid_postmap_delay_msg
}

redirect -file $REPORT_DIR/npc_postmap_pressure.rpt {
    echo "Post-map NPC input-allbits-to-PC-allbits pressure status"
    echo "NPC input source Q-pin count:"
    echo [sizeof_collection $npc_critical_src_post]
    echo "PC destination D-pin count:"
    echo [sizeof_collection $npc_critical_dst_post]
    echo "Pressure applied (1=yes):"
    echo $npc_postmap_pressure_applied
    echo "group_path status (0=success):"
    echo $npc_postmap_group_status
    echo "group_path response:"
    echo $npc_postmap_group_msg
    echo "set_max_delay status (0=success):"
    echo $npc_postmap_delay_status
    echo "set_max_delay response:"
    echo $npc_postmap_delay_msg
}

redirect -file $REPORT_DIR/im_q_to_ifid_offset_pressure.rpt {
    echo "Post-map IM-Q-to-IFID-Offset pressure status"
    echo "IM Q-pin count:"
    echo [sizeof_collection $im_q_pins_post]
    echo "IF/ID Offset D-pin count:"
    echo [sizeof_collection $im_offset_d_pins_post]
    echo "Pressure applied (1=yes):"
    echo $im_postmap_pressure_applied
    echo "group_path status (0=success):"
    echo $im_postmap_group_status
    echo "group_path response:"
    echo $im_postmap_group_msg
    echo "set_max_delay status (0=success):"
    echo $im_postmap_delay_status
    echo "set_max_delay response:"
    echo $im_postmap_delay_msg
}

if {[sizeof_collection $alu_sources_post] > 0 && \
    [sizeof_collection $alu_d_pins_post] > 0} {
    redirect -file $REPORT_DIR/alu_slack_timing.rpt \
        [list report_timing -from $alu_sources_post -to $alu_d_pins_post \
            -delay max -max_paths 20 -nworst 1 \
            -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/alu_slack_timing.rpt {
        echo "Skipped: ALU source or U_ALUOut D-pin collection is empty."
        echo "See alu_timing_objects.rpt for the resolved object collections."
    }
}

if {[sizeof_collection $npc_sources_post] > 0 && \
    [sizeof_collection $pc_d_pins_post] > 0} {
    redirect -file $REPORT_DIR/npc_offset_to_pc_timing.rpt \
        [list report_timing -from $npc_sources_post -to $pc_d_pins_post \
            -delay max -max_paths 20 -nworst 1 \
            -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/npc_offset_to_pc_timing.rpt {
        echo "Skipped: NPC offset source or PC register collection is empty."
    }
}

if {[sizeof_collection $ifid_rs1_q_pins_post] > 0 && \
    [sizeof_collection $ifid_offset_d_pins_post] > 0} {
    redirect -file $REPORT_DIR/ifid_rs1_to_offset_timing.rpt \
        [list report_timing -from $ifid_rs1_q_pins_post -to $ifid_offset_d_pins_post \
            -delay max -max_paths 20 -nworst 1 \
            -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/ifid_rs1_to_offset_timing.rpt {
        echo "Skipped: IF/ID rs1 source or IF/ID Offset endpoint collection is empty."
    }
}

write_file -format ddc     -hierarchy -output $RESULT_DIR/${TOP}_npc_pressure.ddc
write_file -format verilog -hierarchy -output $RESULT_DIR/${TOP}_npc_pressure.v
write_sdc $RESULT_DIR/${TOP}_npc_pressure.sdc

puts "NPC offset-to-PC pressure synthesis completed."
puts "Reports  : $REPORT_DIR"
puts "Results  : $RESULT_DIR"
