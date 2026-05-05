# DC synthesis script: compile-based flow with targeted pressure on the
# current hot decode path.
#
# Run this script from cpu/rtl so these server-side paths stay unchanged:
#   ./rtl
#   ./rtl/includes

set SCRIPT_DIR [file dirname [file normalize [info script]]]
cd $SCRIPT_DIR
puts "Running dc_compile_path_pressure.tcl from: $SCRIPT_DIR"

set TOP        riscv
set CLK_NAME   clock
set CLK_PORT   clk
set CLK_PERIOD 5.0
set CLK_HALF   [expr {$CLK_PERIOD / 2.0}]

# Keep a realistic margin so the reported slack is not just "barely meets
# the ideal clock" slack.
set CLK_SETUP_UNCERTAINTY 0.15
set CLK_HOLD_UNCERTAINTY  0.05

# Datapath-only budgets for the current 5ns hot paths.
set BUDGET_IM_TO_IFID_RFWRITE  4.52
set BUDGET_IM_TO_IFID_ALUOP    4.54
set BUDGET_IM_TO_IFID_WDSEL    4.56
set BUDGET_IM_TO_IFID_DMCTRL   4.56
set BUDGET_IM_TO_IFID_IMM12    4.56
set BUDGET_IM_TO_IFID_OFFSET   4.54
set BUDGET_BRANCH_TO_PC        4.50
set BUDGET_OFFSET12_TO_PC      4.48
set BUDGET_OFFSET20_TO_PC      4.50
set BUDGET_ALUSRCA_TO_ALUOUT   4.50
set BUDGET_ALUSRCB_TO_ALUOUT   4.50
set BUDGET_NPCOP_TO_IFPCA4     4.52
set BUDGET_IDEXB_TO_ALUOUT     4.56
set BUDGET_NPC_ADD48_TO_PC     4.40
set BUDGET_ALUSUB_TO_ALUOUT    4.40

set REPORT_DIR ./reports_compile_pressure
set RESULT_DIR ./results_compile_pressure
set WORK_DIR   ./work_compile_pressure

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

set rtl_files [lsort [glob -nocomplain ./rtl/*.v]]
puts "RTL files:"
foreach f $rtl_files {
    puts "  $f"
}
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

uniquify
check_design

set_operating_conditions -library tcbn65lpwc WCCOM
set_wire_load_model -name TSMC32K_Lowk_Conservative -library tcbn65lpwc
set_wire_load_mode top

create_clock -name $CLK_NAME -period $CLK_PERIOD -waveform [list 0 $CLK_HALF] [get_ports $CLK_PORT]
set_clock_transition 0.10 [get_clocks $CLK_NAME]
set_clock_uncertainty -setup $CLK_SETUP_UNCERTAINTY [get_clocks $CLK_NAME]
set_clock_uncertainty -hold  $CLK_HOLD_UNCERTAINTY  [get_clocks $CLK_NAME]
set_dont_touch_network [get_ports $CLK_PORT]
set_ideal_network [get_ports $CLK_PORT]

if {[sizeof_collection [get_ports -quiet rst]] > 0} {
    set_case_analysis 0 [get_ports rst]
    set_false_path -from [get_ports rst]
    set_ideal_network [get_ports rst]
}

set_max_fanout 10 [current_design]
set_max_transition 0.20 [current_design]
set_cost_priority -delay

# Keep architecturally meaningful sequential state from being dropped just
# because the current top-level observable interface is small.
catch {set_app_var compile_delete_unloaded_sequential_cells false}

# Add pressure where the current 5ns timing report shows the work is happening:
# 1) decode: IM -> IR -> ControlUnit -> IF/ID control flops
# 2) branch/offset -> NPC -> PC
# 3) ALUSrcA -> MUX_2to1_A -> ALU -> ALUOut
foreach dsn {IR IM} {
    set dsn_obj [get_designs -quiet $dsn]
    if {[sizeof_collection $dsn_obj] > 0} {
        catch {set_max_fanout 4 $dsn_obj}
        catch {set_max_transition 0.12 $dsn_obj}
    }
}

foreach dsn {ControlUnit NPC PC} {
    set dsn_obj [get_designs -quiet $dsn]
    if {[sizeof_collection $dsn_obj] > 0} {
        catch {set_max_fanout 4 $dsn_obj}
        catch {set_max_transition 0.10 $dsn_obj}
    }
}

foreach dsn {ALU MUX_2to1_A} {
    set dsn_obj [get_designs -quiet $dsn]
    if {[sizeof_collection $dsn_obj] > 0} {
        catch {set_max_fanout 3 $dsn_obj}
        catch {set_max_transition 0.08 $dsn_obj}
    }
}

set alu_dsn [get_designs -quiet ALU]
if {[sizeof_collection $alu_dsn] > 0} {
    catch {set_max_fanout 3 $alu_dsn}
    catch {set_max_transition 0.08 $alu_dsn}
}

# Avoid mapping the hot arithmetic back into FA/HA ripple structures. The
# broader wildcard coverage is intentional here: the timing reports are still
# showing FA1D* cells on the longest chains, so constrain the full weak/full-
# adder family rather than only a couple of drive variants.
foreach pat {
    HA1D* FA1D*
    */HA1D* */FA1D*
    tcbn65lpwc/HA1D* tcbn65lpwc/FA1D*
} {
    set lib_cells [get_lib_cells -quiet $pat]
    if {[sizeof_collection $lib_cells] > 0} {
        catch {set_dont_use $lib_cells true}
    }
}

# Keep most of the hot datapath hierarchy intact so lower-level structure stays
# readable, but allow ALU/NPC to optimize across their boundaries later.
foreach inst {U_ALU U_NPC U_PC U_MUX_2to1_A U_MUX_3to1_B U_ALUOut} {
    set cell_obj [get_cells -quiet $inst]
    if {[sizeof_collection $cell_obj] > 0} {
        catch {set_boundary_optimization $cell_obj false}
        catch {set_ungroup $cell_obj false}
    }
}

set im_q_pins              [get_pins -quiet -hier U_IM/memory/Q*]
set im_a_pins              [get_pins -quiet -hier U_IM/memory/A*]
set alua_q_pins            [get_pins -quiet -hier U_A/out_data*]
set ir_in_pins             [get_pins -quiet -hier U_IR/in_ins*]
set ctrl_opcode_pins       [get_pins -quiet -hier U_ControlUnit/opcode*]
set ctrl_funct3_pins       [get_pins -quiet -hier U_ControlUnit/Funct3*]
set ctrl_funct7_pins       [get_pins -quiet -hier U_ControlUnit/Funct7*]
set ifid_rfwrite_d_pins    [get_pins -quiet -hier U_ControlUnit/U_IFID_RFWrite/in_data*]
set ifid_aluop_d_pins      [get_pins -quiet -hier U_ControlUnit/U_IFID_ALUOp/in_data*]
set ifid_wdsel_d_pins      [get_pins -quiet -hier U_ControlUnit/U_IFID_WDSel/in_data*]
set ifid_dmctrl_d_pins     [get_pins -quiet -hier U_ControlUnit/U_IFID_DMCtrl/in_data*]
set ifid_imm12_d_pins      [get_pins -quiet -hier U_ControlUnit/U_IFID_Imm12/in_data*]
set ifid_offset_d_pins     [get_pins -quiet -hier U_ControlUnit/U_IFID_Offet/in_data*]
set ifpca4_d_pins          [get_pins -quiet -hier U_ControlUnit/U_IF_PCA4/in_data*]
set npcop_q_pins           [get_pins -quiet -hier U_ControlUnit/U_NPCOp/out_data*]
set branch_q_pins          [get_pins -quiet -hier U_ControlUnit/U_branch/out_data*]
set idex_pc_q_pins         [get_pins -quiet -hier U_ControlUnit/U_IDEX_PC/out_data*]
set idex_aluop_q_pins      [get_pins -quiet -hier U_ControlUnit/U_IDEX_ALUOp/out_data*]
set idex_offset_q_pins     [get_pins -quiet -hier U_ControlUnit/U_IDEX_Offset/out_data*]
set idex_offset20_q_pins   [get_pins -quiet -hier U_ControlUnit/U_IDEX_Offset20/out_data*]
set idex_alusrca_q_pins    [get_pins -quiet -hier U_ControlUnit/U_IDEX_ALUSrcA/out_data*]
set idex_alusrcb_q_pins    [get_pins -quiet -hier U_ControlUnit/U_IDEX_ALUSrcB/out_data*]
set idex_b_q_pins          [get_pins -quiet -hier U_ControlUnit/U_IDEX_ALU_B/out_data*]
set aluout_d_pins          [get_pins -quiet -hier U_ALUOut/in_data*]
set clock_regs             [all_registers -clock [get_clocks $CLK_NAME]]
set pc_regs                [all_registers -of_objects [get_cells -quiet U_PC]]
set aluout_regs            [all_registers -of_objects [get_cells -quiet U_ALUOut]]
set ifpca4_regs            [all_registers -of_objects [get_cells -quiet U_ControlUnit/U_IF_PCA4]]
set a_regs                 [all_registers -of_objects [get_cells -quiet U_A]]
set idex_pc_regs           [get_cells -quiet -hier U_ControlUnit/U_IDEX_PC/out_data_reg*]
set idex_aluop_regs        [get_cells -quiet -hier U_ControlUnit/U_IDEX_ALUOp/out_data_reg*]
set idex_offset_regs       [get_cells -quiet -hier U_ControlUnit/U_IDEX_Offset/out_data_reg*]
set idex_offset20_regs     [get_cells -quiet -hier U_ControlUnit/U_IDEX_Offset20/out_data_reg*]
set idex_b_regs            [get_cells -quiet -hier U_ControlUnit/U_IDEX_ALU_B/out_data_reg*]
set branch_regs            [get_cells -quiet -hier U_ControlUnit/U_branch/out_data_reg*]
set npcop_regs             [get_cells -quiet -hier U_ControlUnit/U_NPCOp/out_data_reg*]
set npc_add48_cell         [get_cells -quiet -hier U_NPC/add_48]
set alu_sub_cell           [get_cells -quiet -hier U_ALU/U_DW_ALU_SUB]
set alu_add_cell           [get_cells -quiet -hier U_ALU/U_DW_ALU_ADD]
set weak_arith_libcells    [get_lib_cells -quiet */FA1D* */HA1D*]

set ctrl_decode_in_pins $ctrl_opcode_pins
if {[sizeof_collection $ctrl_funct3_pins] > 0} {
    if {[sizeof_collection $ctrl_decode_in_pins] > 0} {
        set ctrl_decode_in_pins [add_to_collection $ctrl_decode_in_pins $ctrl_funct3_pins]
    } else {
        set ctrl_decode_in_pins $ctrl_funct3_pins
    }
}

set imaddr_src_q_pins $idex_pc_q_pins
foreach extra_src [list $idex_offset_q_pins $idex_offset20_q_pins $branch_q_pins $npcop_q_pins] {
    if {[sizeof_collection $extra_src] > 0} {
        if {[sizeof_collection $imaddr_src_q_pins] > 0} {
            set imaddr_src_q_pins [add_to_collection $imaddr_src_q_pins $extra_src]
        } else {
            set imaddr_src_q_pins $extra_src
        }
    }
}

set npc_add48_src_q_pins $idex_pc_q_pins
foreach extra_src [list $idex_offset_q_pins $branch_q_pins] {
    if {[sizeof_collection $extra_src] > 0} {
        if {[sizeof_collection $npc_add48_src_q_pins] > 0} {
            set npc_add48_src_q_pins [add_to_collection $npc_add48_src_q_pins $extra_src]
        } else {
            set npc_add48_src_q_pins $extra_src
        }
    }
}
if {[sizeof_collection $ctrl_funct7_pins] > 0} {
    if {[sizeof_collection $ctrl_decode_in_pins] > 0} {
        set ctrl_decode_in_pins [add_to_collection $ctrl_decode_in_pins $ctrl_funct7_pins]
    } else {
        set ctrl_decode_in_pins $ctrl_funct7_pins
    }
}

# Try to steer the hottest DesignWare adders toward faster implementations when
# the local DC/DW setup supports instance-level implementation binding. Kept in
# catch blocks so older tool setups fall back cleanly.
foreach impl {DW01_add/cla DW01_add/csla DW01_add/pparch} {
    if {[sizeof_collection $npc_add48_cell] > 0} {
        catch {set_implementation $impl $npc_add48_cell}
    }
    if {[sizeof_collection $alu_sub_cell] > 0} {
        catch {set_implementation $impl $alu_sub_cell}
    }
    if {[sizeof_collection $alu_add_cell] > 0} {
        catch {set_implementation $impl $alu_add_cell}
    }
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $clock_regs] > 0} {
    group_path -name IM_TO_PIPE -from $im_q_pins -to $clock_regs -weight 10 -critical_range 0.20
}

if {[sizeof_collection $ir_in_pins] > 0 && [sizeof_collection $clock_regs] > 0} {
    group_path -name IR_TO_PIPE -from $ir_in_pins -to $clock_regs -weight 12 -critical_range 0.20
}

if {[sizeof_collection $ctrl_decode_in_pins] > 0 && [sizeof_collection $clock_regs] > 0} {
    group_path -name CTRL_DECODE -from $ctrl_decode_in_pins -to $clock_regs -weight 14 -critical_range 0.20
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $ifid_rfwrite_d_pins] > 0} {
    group_path -name IM_TO_IFID_RFWRITE -from $im_q_pins -to $ifid_rfwrite_d_pins -weight 40 -critical_range 0.30
    set_max_delay $BUDGET_IM_TO_IFID_RFWRITE -from $im_q_pins -to $ifid_rfwrite_d_pins -datapath_only
}

if {[sizeof_collection $ctrl_decode_in_pins] > 0 && [sizeof_collection $ifid_rfwrite_d_pins] > 0} {
    group_path -name CTRL_TO_IFID_RFWRITE -from $ctrl_decode_in_pins -to $ifid_rfwrite_d_pins -weight 24 -critical_range 0.20
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $ifid_aluop_d_pins] > 0} {
    group_path -name IM_TO_IFID_ALUOP -from $im_q_pins -to $ifid_aluop_d_pins -weight 28 -critical_range 0.25
    set_max_delay $BUDGET_IM_TO_IFID_ALUOP -from $im_q_pins -to $ifid_aluop_d_pins -datapath_only
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $ifid_wdsel_d_pins] > 0} {
    group_path -name IM_TO_IFID_WDSEL -from $im_q_pins -to $ifid_wdsel_d_pins -weight 18 -critical_range 0.20
    set_max_delay $BUDGET_IM_TO_IFID_WDSEL -from $im_q_pins -to $ifid_wdsel_d_pins -datapath_only
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $ifid_dmctrl_d_pins] > 0} {
    group_path -name IM_TO_IFID_DMCTRL -from $im_q_pins -to $ifid_dmctrl_d_pins -weight 18 -critical_range 0.20
    set_max_delay $BUDGET_IM_TO_IFID_DMCTRL -from $im_q_pins -to $ifid_dmctrl_d_pins -datapath_only
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $ifid_imm12_d_pins] > 0} {
    group_path -name IM_TO_IFID_IMM12 -from $im_q_pins -to $ifid_imm12_d_pins -weight 20 -critical_range 0.22
    set_max_delay $BUDGET_IM_TO_IFID_IMM12 -from $im_q_pins -to $ifid_imm12_d_pins -datapath_only
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $ifid_offset_d_pins] > 0} {
    group_path -name IM_TO_IFID_OFFSET -from $im_q_pins -to $ifid_offset_d_pins -weight 24 -critical_range 0.24
    set_max_delay $BUDGET_IM_TO_IFID_OFFSET -from $im_q_pins -to $ifid_offset_d_pins -datapath_only
}

if {[sizeof_collection $idex_aluop_q_pins] > 0 && [sizeof_collection $aluout_regs] > 0} {
    group_path -name ALUOP_TO_ALUOUT -from $idex_aluop_q_pins -to $aluout_regs -weight 38 -critical_range 0.30
    set_max_delay 4.46 -from $idex_aluop_q_pins -to $aluout_regs -datapath_only
}

if {[sizeof_collection $npcop_q_pins] > 0 && [sizeof_collection $ifpca4_d_pins] > 0} {
    group_path -name NPCOP_TO_IFPCA4 -from $npcop_q_pins -to $ifpca4_d_pins -weight 16 -critical_range 0.20
    set_max_delay $BUDGET_NPCOP_TO_IFPCA4 -from $npcop_q_pins -to $ifpca4_d_pins -datapath_only
}

if {[sizeof_collection $idex_pc_q_pins] > 0 && [sizeof_collection $pc_regs] > 0} {
    group_path -name IDEXPC_TO_PC -from $idex_pc_q_pins -to $pc_regs -weight 40 -critical_range 0.32
    set_max_delay 4.44 -from $idex_pc_q_pins -to $pc_regs -datapath_only
}

if {[sizeof_collection $im_a_pins] > 0 && [sizeof_collection $imaddr_src_q_pins] > 0} {
    group_path -name EXCTRL_TO_IMADDR -from $imaddr_src_q_pins -to $im_a_pins -weight 44 -critical_range 0.34
    set_max_delay 4.42 -from $imaddr_src_q_pins -to $im_a_pins -datapath_only
}

if {[sizeof_collection $idex_pc_q_pins] > 0 && [sizeof_collection $ifpca4_regs] > 0} {
    group_path -name IDEXPC_TO_IFPCA4 -from $idex_pc_q_pins -to $ifpca4_regs -weight 30 -critical_range 0.26
    set_max_delay 4.46 -from $idex_pc_q_pins -to $ifpca4_regs -datapath_only
}

if {[sizeof_collection $branch_q_pins] > 0 && [sizeof_collection $pc_regs] > 0} {
    group_path -name BRANCH_TO_PC -from $branch_q_pins -to $pc_regs -weight 24 -critical_range 0.22
    set_max_delay $BUDGET_BRANCH_TO_PC -from $branch_q_pins -to $pc_regs -datapath_only
}

if {[sizeof_collection $idex_offset_q_pins] > 0 && [sizeof_collection $pc_regs] > 0} {
    group_path -name OFFSET12_TO_PC -from $idex_offset_q_pins -to $pc_regs -weight 34 -critical_range 0.28
    set_max_delay $BUDGET_OFFSET12_TO_PC -from $idex_offset_q_pins -to $pc_regs -datapath_only
}

if {[sizeof_collection $idex_offset20_q_pins] > 0 && [sizeof_collection $pc_regs] > 0} {
    group_path -name OFFSET20_TO_PC -from $idex_offset20_q_pins -to $pc_regs -weight 22 -critical_range 0.22
    set_max_delay $BUDGET_OFFSET20_TO_PC -from $idex_offset20_q_pins -to $pc_regs -datapath_only
}

if {[sizeof_collection $idex_alusrca_q_pins] > 0 && [sizeof_collection $aluout_regs] > 0} {
    group_path -name ALUSRCA_TO_ALUOUT -from $idex_alusrca_q_pins -to $aluout_regs -weight 34 -critical_range 0.28
    set_max_delay $BUDGET_ALUSRCA_TO_ALUOUT -from $idex_alusrca_q_pins -to $aluout_regs -datapath_only
}

if {[sizeof_collection $idex_alusrcb_q_pins] > 0 && [sizeof_collection $aluout_regs] > 0} {
    group_path -name ALUSRCB_TO_ALUOUT -from $idex_alusrcb_q_pins -to $aluout_regs -weight 28 -critical_range 0.24
    set_max_delay $BUDGET_ALUSRCB_TO_ALUOUT -from $idex_alusrcb_q_pins -to $aluout_regs -datapath_only
}

if {[sizeof_collection $idex_b_q_pins] > 0 && [sizeof_collection $aluout_d_pins] > 0} {
    group_path -name IDEXB_TO_ALUOUT -from $idex_b_q_pins -to $aluout_d_pins -weight 14 -critical_range 0.20
    set_max_delay $BUDGET_IDEXB_TO_ALUOUT -from $idex_b_q_pins -to $aluout_d_pins -datapath_only
}

if {[sizeof_collection $npc_add48_cell] > 0 && [sizeof_collection $npc_add48_src_q_pins] > 0 && [sizeof_collection $pc_regs] > 0} {
    catch {group_path -name NPC_ADD48_TO_PC -from $npc_add48_src_q_pins -through $npc_add48_cell -to $pc_regs -weight 80 -critical_range 0.40}
    catch {set_max_delay $BUDGET_NPC_ADD48_TO_PC -from $npc_add48_src_q_pins -through $npc_add48_cell -to $pc_regs -datapath_only}
    catch {set_max_transition 0.06 $npc_add48_cell}
    catch {set_boundary_optimization $npc_add48_cell true}
    catch {set_ungroup $npc_add48_cell true}
}

if {[sizeof_collection $alu_sub_cell] > 0 && [sizeof_collection $alua_q_pins] > 0 && [sizeof_collection $aluout_regs] > 0} {
    catch {group_path -name ALUSUBA_TO_ALUOUT -from $alua_q_pins -through $alu_sub_cell -to $aluout_regs -weight 80 -critical_range 0.40}
    catch {set_max_delay $BUDGET_ALUSUB_TO_ALUOUT -from $alua_q_pins -through $alu_sub_cell -to $aluout_regs -datapath_only}
    catch {set_max_transition 0.06 $alu_sub_cell}
    catch {set_boundary_optimization $alu_sub_cell true}
    catch {set_ungroup $alu_sub_cell true}
}

if {[sizeof_collection $alu_sub_cell] > 0 && [sizeof_collection $idex_b_q_pins] > 0 && [sizeof_collection $aluout_d_pins] > 0} {
    catch {group_path -name ALUSUBB_TO_ALUOUT -from $idex_b_q_pins -through $alu_sub_cell -to $aluout_d_pins -weight 72 -critical_range 0.34}
    catch {set_max_delay $BUDGET_ALUSUB_TO_ALUOUT -from $idex_b_q_pins -through $alu_sub_cell -to $aluout_d_pins -datapath_only}
}

if {[sizeof_collection $alu_add_cell] > 0} {
    catch {set_boundary_optimization $alu_add_cell true}
    catch {set_ungroup $alu_add_cell true}
}

# Tighten only the current critical source flops so DC spends effort buffering /
# cloning them instead of globally flattening more logic.
foreach reg_group [list $a_regs $idex_aluop_regs $idex_pc_regs $idex_offset_regs $idex_offset20_regs $idex_b_regs $branch_regs $npcop_regs] {
    if {[sizeof_collection $reg_group] > 0} {
        catch {set_max_fanout 2 $reg_group}
        catch {set_max_transition 0.06 $reg_group}
    }
}

# Allow decode/control logic to optimize across boundaries, and reopen only the
# ALU/NPC module boundaries so the adder cones can still be restructured
# without flattening the rest of the datapath.
foreach inst {U_IR U_ControlUnit U_ALU U_NPC} {
    set cell_obj [get_cells -quiet $inst]
    if {[sizeof_collection $cell_obj] > 0} {
        catch {set_boundary_optimization $cell_obj true}
    }
}

redirect -file $REPORT_DIR/precompile_check_design.rpt {check_design}
redirect -file $REPORT_DIR/precompile_check_timing.rpt {check_timing}
redirect -file $REPORT_DIR/precompile_arith_debug.rpt {
    echo "Arithmetic steering debug"
    echo "npc_add48_cell:"
    sizeof_collection $npc_add48_cell
    query_objects $npc_add48_cell
    echo "alu_sub_cell:"
    sizeof_collection $alu_sub_cell
    query_objects $alu_sub_cell
    echo "alu_add_cell:"
    sizeof_collection $alu_add_cell
    query_objects $alu_add_cell
    echo "weak_arith_libcells:"
    sizeof_collection $weak_arith_libcells
    query_objects $weak_arith_libcells
}

# Baseline-first flow: keep structure closer to a plain compile result,
# then push timing incrementally on the already-built netlist.
compile -map_effort high
compile -incremental_mapping -map_effort high
catch {set_fix_hold [get_clocks $CLK_NAME]}
compile -incremental_mapping -map_effort high

change_names -rules verilog -hierarchy

set im_q_post            [get_pins -quiet -hier U_IM/memory/Q*]
set im_a_post            [get_pins -quiet -hier U_IM/memory/A*]
set post_regs            [all_registers -clock [get_clocks $CLK_NAME]]
set branch_post_regs     [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_branch/out_data_reg_*}]
set idex_pc_post_regs    [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IDEX_PC/out_data_reg_*}]
set idex_aluop_post_regs [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IDEX_ALUOp/out_data_reg_*}]
set idex_offset_post_regs [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IDEX_Offset/out_data_reg_*}]
set idex_offset20_post_regs [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IDEX_Offset20/out_data_reg_*}]
set idex_alusrca_post_regs [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IDEX_ALUSrcA/out_data_reg_*}]
set ifid_rfwrite_post_regs [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IFID_RFWrite/out_data_reg_*}]
set ifid_aluop_post_regs [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IFID_ALUOp/out_data_reg_*}]
set ifid_wdsel_post_regs [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IFID_WDSel/out_data_reg_*}]
set ifid_dmctrl_post_regs [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IFID_DMCtrl/out_data_reg_*}]
set ifid_imm12_post_regs [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IFID_Imm12/out_data_reg_*}]
set ifid_offset_post_regs [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IFID_Offet/out_data_reg_*}]
set ifpca4_post_regs     [filter_collection $post_regs {full_name =~ *U_ControlUnit/U_IF_PCA4/out_data_reg_*}]
set aluout_post_regs     [filter_collection $post_regs {full_name =~ *U_ALUOut/out_data_reg_*}]
set pc_post_regs         [filter_collection $post_regs {full_name =~ *U_PC/PC_reg_*}]
set branch_post_q        [filter_collection [get_pins -quiet -of_objects $branch_post_regs] {full_name =~ */Q}]
set idex_pc_post_q       [filter_collection [get_pins -quiet -of_objects $idex_pc_post_regs] {full_name =~ */Q}]
set idex_aluop_post_q    [filter_collection [get_pins -quiet -of_objects $idex_aluop_post_regs] {full_name =~ */Q}]
set idex_offset_post_q   [filter_collection [get_pins -quiet -of_objects $idex_offset_post_regs] {full_name =~ */Q}]
set idex_offset20_post_q [filter_collection [get_pins -quiet -of_objects $idex_offset20_post_regs] {full_name =~ */Q}]
set idex_alusrca_post_q  [filter_collection [get_pins -quiet -of_objects $idex_alusrca_post_regs] {full_name =~ */Q}]
set ifid_rfwrite_post_d  [filter_collection [get_pins -quiet -of_objects $ifid_rfwrite_post_regs] {full_name =~ */D}]
set ifid_aluop_post_d    [filter_collection [get_pins -quiet -of_objects $ifid_aluop_post_regs] {full_name =~ */D}]
set ifid_wdsel_post_d    [filter_collection [get_pins -quiet -of_objects $ifid_wdsel_post_regs] {full_name =~ */D}]
set ifid_dmctrl_post_d   [filter_collection [get_pins -quiet -of_objects $ifid_dmctrl_post_regs] {full_name =~ */D}]
set ifid_imm12_post_d    [filter_collection [get_pins -quiet -of_objects $ifid_imm12_post_regs] {full_name =~ */D}]
set ifid_offset_post_d   [filter_collection [get_pins -quiet -of_objects $ifid_offset_post_regs] {full_name =~ */D}]
set ifpca4_post_d        [filter_collection [get_pins -quiet -of_objects $ifpca4_post_regs] {full_name =~ */D}]
set aluout_post_d        [filter_collection [get_pins -quiet -of_objects $aluout_post_regs] {full_name =~ */D}]
set pc_post_d            [filter_collection [get_pins -quiet -of_objects $pc_post_regs] {full_name =~ */D}]
set rf_post              [get_cells -quiet -hier *U_RF*]
set ctrl_post            [get_cells -quiet -hier *U_ControlUnit*]

redirect -file $REPORT_DIR/preservation_summary.rpt {
    echo "Preservation summary"
    echo "U_RF cell count:"
    sizeof_collection $rf_post
    query_objects $rf_post
    echo "U_ControlUnit cell count:"
    sizeof_collection $ctrl_post
    query_objects $ctrl_post
}

redirect -file $REPORT_DIR/post_timing_collection_debug.rpt {
    echo "Post-compile timing collection debug"
    echo "REPORT_DIR:"
    echo $REPORT_DIR
    echo "im_q_post count:"
    sizeof_collection $im_q_post
    query_objects $im_q_post
    echo "im_a_post count:"
    sizeof_collection $im_a_post
    query_objects $im_a_post
    echo "post_regs count:"
    sizeof_collection $post_regs
    echo "branch_post_regs count:"
    sizeof_collection $branch_post_regs
    query_objects $branch_post_regs
    echo "idex_pc_post_regs count:"
    sizeof_collection $idex_pc_post_regs
    query_objects $idex_pc_post_regs
    echo "idex_aluop_post_regs count:"
    sizeof_collection $idex_aluop_post_regs
    query_objects $idex_aluop_post_regs
    echo "idex_aluop_post_q count:"
    sizeof_collection $idex_aluop_post_q
    query_objects $idex_aluop_post_q
    echo "ifpca4_post_regs count:"
    sizeof_collection $ifpca4_post_regs
    query_objects $ifpca4_post_regs
    echo "ifpca4_post_d count:"
    sizeof_collection $ifpca4_post_d
    query_objects $ifpca4_post_d
    echo "aluout_post_regs count:"
    sizeof_collection $aluout_post_regs
    query_objects $aluout_post_regs
    echo "aluout_post_d count:"
    sizeof_collection $aluout_post_d
    query_objects $aluout_post_d
    echo "pc_post_regs count:"
    sizeof_collection $pc_post_regs
    query_objects $pc_post_regs
    echo "pc_post_d count:"
    sizeof_collection $pc_post_d
    query_objects $pc_post_d
}

redirect -file $REPORT_DIR/qor.rpt           {report_qor}
redirect -file $REPORT_DIR/area.rpt          {report_area}
redirect -file $REPORT_DIR/reference.rpt     {report_reference}
redirect -file $REPORT_DIR/resources.rpt     {report_resources}
redirect -file $REPORT_DIR/resources_hier.rpt {report_resources -hierarchy}
redirect -file $REPORT_DIR/constraint.rpt    {report_constraint -all_violators}
redirect -file $REPORT_DIR/timing_max_20.rpt {report_timing -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time}

if {[sizeof_collection $im_q_post] > 0 && [sizeof_collection $ifid_rfwrite_post_d] > 0} {
    redirect -file $REPORT_DIR/im_to_ifid_rfwrite_timing.rpt [list report_timing -from $im_q_post -to $ifid_rfwrite_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/im_to_ifid_rfwrite_timing.rpt {echo "Skipped: im_q_post or ifid_rfwrite_post_d collection is empty. See post_timing_collection_debug.rpt"}
}
if {[sizeof_collection $im_a_post] > 0} {
    redirect -file $REPORT_DIR/im_addr_timing.rpt [list report_timing -to $im_a_post -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/im_addr_timing.rpt {echo "Skipped: im_a_post collection is empty. See post_timing_collection_debug.rpt"}
}
if {[sizeof_collection $im_q_post] > 0 && [sizeof_collection $ifid_aluop_post_d] > 0} {
    redirect -file $REPORT_DIR/im_to_ifid_aluop_timing.rpt [list report_timing -from $im_q_post -to $ifid_aluop_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/im_to_ifid_aluop_timing.rpt {echo "Skipped: im_q_post or ifid_aluop_post_d collection is empty. See post_timing_collection_debug.rpt"}
}
if {[sizeof_collection $idex_aluop_post_q] > 0 && [sizeof_collection $aluout_post_d] > 0} {
    redirect -file $REPORT_DIR/aluop_to_aluout_timing.rpt [list report_timing -from $idex_aluop_post_q -to $aluout_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/aluop_to_aluout_timing.rpt {echo "Skipped: idex_aluop_post_q or aluout_post_d collection is empty. See post_timing_collection_debug.rpt"}
}
if {[sizeof_collection $im_q_post] > 0 && [sizeof_collection $ifid_wdsel_post_d] > 0} {
    redirect -file $REPORT_DIR/im_to_ifid_wdsel_timing.rpt [list report_timing -from $im_q_post -to $ifid_wdsel_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}
if {[sizeof_collection $im_q_post] > 0 && [sizeof_collection $ifid_dmctrl_post_d] > 0} {
    redirect -file $REPORT_DIR/im_to_ifid_dmctrl_timing.rpt [list report_timing -from $im_q_post -to $ifid_dmctrl_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}
if {[sizeof_collection $im_q_post] > 0 && [sizeof_collection $ifid_imm12_post_d] > 0} {
    redirect -file $REPORT_DIR/im_to_ifid_imm12_timing.rpt [list report_timing -from $im_q_post -to $ifid_imm12_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}
if {[sizeof_collection $im_q_post] > 0 && [sizeof_collection $ifid_offset_post_d] > 0} {
    redirect -file $REPORT_DIR/im_to_ifid_offset_timing.rpt [list report_timing -from $im_q_post -to $ifid_offset_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}
if {[sizeof_collection $ifpca4_post_d] > 0} {
    redirect -file $REPORT_DIR/npc_to_ifpca4_timing.rpt [list report_timing -to $ifpca4_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/npc_to_ifpca4_timing.rpt {echo "Skipped: ifpca4_post_d collection is empty. See post_timing_collection_debug.rpt"}
}
if {[sizeof_collection $aluout_post_d] > 0} {
    redirect -file $REPORT_DIR/aluout_timing.rpt [list report_timing -to $aluout_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/aluout_timing.rpt {echo "Skipped: aluout_post_d collection is empty. See post_timing_collection_debug.rpt"}
}
if {[sizeof_collection $branch_post_q] > 0 && [sizeof_collection $pc_post_d] > 0} {
    redirect -file $REPORT_DIR/branch_to_pc_timing.rpt [list report_timing -from $branch_post_q -to $pc_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/branch_to_pc_timing.rpt {echo "Skipped: branch_post_q or pc_post_d collection is empty. See post_timing_collection_debug.rpt"}
}
if {[sizeof_collection $idex_pc_post_q] > 0 && [sizeof_collection $pc_post_d] > 0} {
    redirect -file $REPORT_DIR/idexpc_to_pc_timing.rpt [list report_timing -from $idex_pc_post_q -to $pc_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/idexpc_to_pc_timing.rpt {echo "Skipped: idex_pc_post_q or pc_post_d collection is empty. See post_timing_collection_debug.rpt"}
}
if {[sizeof_collection $idex_pc_post_q] > 0 && [sizeof_collection $ifpca4_post_d] > 0} {
    redirect -file $REPORT_DIR/idexpc_to_ifpca4_timing.rpt [list report_timing -from $idex_pc_post_q -to $ifpca4_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
} else {
    redirect -file $REPORT_DIR/idexpc_to_ifpca4_timing.rpt {echo "Skipped: idex_pc_post_q or ifpca4_post_d collection is empty. See post_timing_collection_debug.rpt"}
}
if {[sizeof_collection $idex_offset_post_q] > 0 && [sizeof_collection $pc_post_d] > 0} {
    redirect -file $REPORT_DIR/offset12_to_pc_timing.rpt [list report_timing -from $idex_offset_post_q -to $pc_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}
if {[sizeof_collection $idex_offset20_post_q] > 0 && [sizeof_collection $pc_post_d] > 0} {
    redirect -file $REPORT_DIR/offset20_to_pc_timing.rpt [list report_timing -from $idex_offset20_post_q -to $pc_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}
if {[sizeof_collection $idex_alusrca_post_q] > 0 && [sizeof_collection $aluout_post_d] > 0} {
    redirect -file $REPORT_DIR/alusrca_to_aluout_timing.rpt [list report_timing -from $idex_alusrca_post_q -to $aluout_post_d -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}

write_file -format ddc     -hierarchy -output $RESULT_DIR/${TOP}_compile_pressure.ddc
write_file -format verilog -hierarchy -output $RESULT_DIR/${TOP}_compile_pressure.v
write_sdc $RESULT_DIR/${TOP}_compile_pressure.sdc
catch {write_sdf $RESULT_DIR/${TOP}_compile_pressure.sdf}

puts "Compile-based path-pressure synthesis completed."
puts "Reports  : $REPORT_DIR"
puts "Results  : $RESULT_DIR"
