# DC synthesis script for the SRAM-based rv32 core.
# Keep the RTL search paths exactly as the current server-side setup expects.

set TOP        riscv
set CLK_NAME   clock
set CLK_PORT   clk
set CLK_PERIOD 5.0
set CLK_HALF   [expr {$CLK_PERIOD / 2.0}]
set CLK_SETUP_UNCERTAINTY 0.15
set CLK_HOLD_UNCERTAINTY  0.05

set ENABLE_CROSS_MODULE_OPT      true
set AGGRESSIVE_FLATTEN_CONTROL   true
set AGGRESSIVE_FLATTEN_RF        false
set AGGRESSIVE_FLATTEN_IFETCH    false
set ENABLE_RETIME                false
set TIGHTEN_CTRL_RF_RULES        true
set TIGHTEN_DECODE_RULES         true
set TIGHTEN_IM_FEEDBACK_RULES    true
set REPORT_RF_DEBUG              true
set PRESERVE_RF_STATE            true
set PRESERVE_CTRL_STATE          true
set SAFE_PRESERVE_MODE           true
set PRESERVE_ALL_SEQ_DEBUG       true
set DEBUG_ISOLATE_RF_BOUNDARY    false
set PRESERVE_FETCH_PIPELINE      false
set AVOID_SLOW_ARITH_CELLS       false
set ENABLE_FIX_MULTIPLE_PORT_NETS true

if {$SAFE_PRESERVE_MODE} {
    # Preserve-first mode:
    # 1) stop aggressive hierarchy destruction
    # 2) stop broad cross-module optimization while we stabilize architecture state
    set ENABLE_CROSS_MODULE_OPT    false
    set AGGRESSIVE_FLATTEN_CONTROL false
    set AGGRESSIVE_FLATTEN_RF      false
    set AGGRESSIVE_FLATTEN_IFETCH  false
    set ENABLE_FIX_MULTIPLE_PORT_NETS false
}

if {$PRESERVE_ALL_SEQ_DEBUG} {
    # Strongest debug mode: keep all sequential state. Use only for
    # structure-preservation experiments, not final timing closure.
    set ENABLE_CROSS_MODULE_OPT    false
    set AGGRESSIVE_FLATTEN_CONTROL false
    set AGGRESSIVE_FLATTEN_RF      false
    set AGGRESSIVE_FLATTEN_IFETCH  false
    set ENABLE_FIX_MULTIPLE_PORT_NETS false
}

set REPORT_DIR ./reports_sram_opt
set RESULT_DIR ./results_sram_opt
set WORK_DIR   ./work

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
set rtl_files [glob ./rtl/*.v]

analyze -format verilog -define {SRAM SYNTHESIS RF_OBSERVE} $rtl_files
elaborate $TOP
current_design $TOP

if {[catch {link} link_msg]} {
    puts "ERROR: link failed."
    puts "Please make sure .synopsys_dc.setup already loads both the tcbn65lpwc standard-cell DB and the TS1N65LPLL2048X64M8 SRAM macro DB."
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

if {$ENABLE_FIX_MULTIPLE_PORT_NETS} {
    set_fix_multiple_port_nets -all -buffer_constants
}
set_max_fanout 10 [current_design]
set_max_transition 0.22 [current_design]
set_max_area 0
set_cost_priority -delay

# When the top-level observable interface is too small, DC can legally delete
# internal sequential state that does not affect outputs. Keep key architectural
# state alive during synthesis so RF / pipeline state does not collapse away.
catch {set_app_var compile_delete_unloaded_sequential_cells false}

if {$PRESERVE_ALL_SEQ_DEBUG} {
    # Do not blanket-dont_touch generic sequential cells here; that can leave
    # the design in an unmapped GTECH state. Preserve structure via hierarchy
    # and boundary controls instead.
}

if {$AVOID_SLOW_ARITH_CELLS} {
    # The current critical path is a long FA/HA carry chain. Ban the weakest
    # adder drive variants so DC is forced to try faster arithmetic mapping.
    foreach pat {*/HA1D0 */HA1D1 */FA1D0 */FA1D1} {
        set slow_cell [get_lib_cells -quiet $pat]
        if {[sizeof_collection $slow_cell] > 0} {
            catch {set_dont_use $slow_cell true}
        }
    }
}

if {$TIGHTEN_CTRL_RF_RULES} {
    foreach dsn {ControlUnit RF ALU NPC PC} {
        set dsn_obj [get_designs -quiet $dsn]
        if {[sizeof_collection $dsn_obj] > 0} {
            catch {set_max_fanout 6 $dsn_obj}
            catch {set_max_transition 0.14 $dsn_obj}
        }
    }
}

set alu_dsn [get_designs -quiet ALU]
if {[sizeof_collection $alu_dsn] > 0} {
    # Push only the ALU harder than the rest of the design.
    catch {set_max_fanout 4 $alu_dsn}
    catch {set_max_transition 0.10 $alu_dsn}
}

if {$TIGHTEN_IM_FEEDBACK_RULES} {
    foreach dsn {IM IR NPC PC ControlUnit ALU} {
        set dsn_obj [get_designs -quiet $dsn]
        if {[sizeof_collection $dsn_obj] > 0} {
            catch {set_max_fanout 5 $dsn_obj}
            catch {set_max_transition 0.14 $dsn_obj}
        }
    }
}

if {$TIGHTEN_DECODE_RULES} {
    # The current hot path is SRAM Q -> instruction decode -> IF/ID ALUOp flop.
    # Apply this after the generic IM feedback rules so the tighter decode
    # electrical limits remain the effective ones.
    foreach dsn {ControlUnit IR} {
        set dsn_obj [get_designs -quiet $dsn]
        if {[sizeof_collection $dsn_obj] > 0} {
            catch {set_max_fanout 4 $dsn_obj}
            catch {set_max_transition 0.12 $dsn_obj}
        }
    }
}

# Keep the SRAM hard macros fixed, but still optimize the logic on their boundaries.
set im_sram [get_cells -quiet -hier U_IM/memory]
set dm_sram [get_cells -quiet -hier U_DM/memory]

if {[sizeof_collection $im_sram] > 0} {
    set_dont_touch $im_sram
    catch {set_boundary_optimization $im_sram false}
}

if {[sizeof_collection $dm_sram] > 0} {
    set_dont_touch $dm_sram
    catch {set_boundary_optimization $dm_sram false}
}

if {$ENABLE_CROSS_MODULE_OPT} {
    catch {set_boundary_optimization [current_design] true}

    foreach inst {U_IM U_IR U_ControlUnit U_RF U_EXT U_NPC U_PC U_ALU U_MUX_2to1_A U_MUX_3to1 U_MUX_3to1_B U_MUX_3to1_LMD} {
        set cell_obj [get_cells -quiet $inst]
        if {[sizeof_collection $cell_obj] > 0} {
            catch {set_boundary_optimization $cell_obj true}
        }
    }

    foreach inst {U_IR U_EXT U_NPC U_PC U_ALU U_MUX_2to1_A U_MUX_3to1 U_MUX_3to1_B U_MUX_3to1_LMD} {
        set cell_obj [get_cells -quiet $inst]
        if {[sizeof_collection $cell_obj] > 0} {
            catch {set_ungroup $cell_obj true}
        }
    }

    if {$AGGRESSIVE_FLATTEN_CONTROL} {
        set ctrl_obj [get_cells -quiet U_ControlUnit]
        if {[sizeof_collection $ctrl_obj] > 0} {
            catch {set_ungroup $ctrl_obj true}
        }
    }

    if {$AGGRESSIVE_FLATTEN_RF} {
        set rf_obj [get_cells -quiet U_RF]
        if {[sizeof_collection $rf_obj] > 0} {
            catch {set_ungroup $rf_obj true}
        }
    }

    if {$AGGRESSIVE_FLATTEN_IFETCH} {
        foreach inst {U_IM U_IR U_NPC U_PC} {
            set cell_obj [get_cells -quiet $inst]
            if {[sizeof_collection $cell_obj] > 0} {
                catch {set_ungroup $cell_obj true}
            }
        }
    }
}

if {$PRESERVE_RF_STATE} {
    set rf_obj [get_cells -quiet U_RF]
    if {[sizeof_collection $rf_obj] > 0} {
        catch {set_boundary_optimization $rf_obj false}
        catch {set_ungroup $rf_obj false}
    }
}

if {$PRESERVE_CTRL_STATE} {
    set ctrl_obj [get_cells -quiet U_ControlUnit]
    if {[sizeof_collection $ctrl_obj] > 0} {
        catch {set_boundary_optimization $ctrl_obj false}
        catch {set_ungroup $ctrl_obj false}
        set ctrl_child_cells [get_cells -quiet -hier U_ControlUnit/*]
        if {[sizeof_collection $ctrl_child_cells] > 0} {
            catch {set_ungroup $ctrl_child_cells false}
        }
    }
}

if {$SAFE_PRESERVE_MODE} {
    # Keep other key architectural state from collapsing while the top-level
    # observable interface is minimal.
    foreach inst {U_PC U_A U_B U_ALUOut} {
        set cell_obj [get_cells -quiet $inst]
        if {[sizeof_collection $cell_obj] > 0} {
            catch {set_boundary_optimization $cell_obj false}
            catch {set_ungroup $cell_obj false}
        }
    }
}

if {$DEBUG_ISOLATE_RF_BOUNDARY} {
    # Debug-only knob: keep RF hierarchy/boundary intact for one synthesis run
    # so we can tell whether the constant-removal messages are coming from
    # cross-module propagation into U_RF or from the RF cone itself.
    set rf_obj [get_cells -quiet U_RF]
    if {[sizeof_collection $rf_obj] > 0} {
        catch {set_boundary_optimization $rf_obj false}
        catch {set_ungroup $rf_obj false}
    }
}

if {$PRESERVE_FETCH_PIPELINE} {
    # If you re-enable this knob, keep it narrow: preserve only the SRAM-facing fetch cells.
    foreach inst {U_IM U_IR} {
        set cell_obj [get_cells -quiet $inst]
        if {[sizeof_collection $cell_obj] > 0} {
            catch {set_boundary_optimization $cell_obj false}
            catch {set_ungroup $cell_obj false}
        }
    }
}

set im_q_pins    [get_pins -quiet -hier U_IM/memory/Q*]
set im_a_pins    [get_pins -quiet -hier U_IM/memory/A*]
set clock_regs   [all_registers -clock [get_clocks $CLK_NAME]]
set ir_in_pins   [get_pins -quiet -hier U_IR/in_ins*]
set ctrl_in_pins [get_pins -quiet -hier U_ControlUnit/opcode*]
set ctrl_funct3_pins [get_pins -quiet -hier U_ControlUnit/Funct3*]
set ctrl_funct7_pins [get_pins -quiet -hier U_ControlUnit/Funct7*]
set ctrl_decode_in_pins $ctrl_in_pins
if {[sizeof_collection $ctrl_funct3_pins] > 0} {
    if {[sizeof_collection $ctrl_decode_in_pins] > 0} {
        set ctrl_decode_in_pins [add_to_collection $ctrl_decode_in_pins $ctrl_funct3_pins]
    } else {
        set ctrl_decode_in_pins $ctrl_funct3_pins
    }
}
if {[sizeof_collection $ctrl_funct7_pins] > 0} {
    if {[sizeof_collection $ctrl_decode_in_pins] > 0} {
        set ctrl_decode_in_pins [add_to_collection $ctrl_decode_in_pins $ctrl_funct7_pins]
    } else {
        set ctrl_decode_in_pins $ctrl_funct7_pins
    }
}
set pc_q_pins    [get_pins -quiet -hier U_PC/PC]
set npc_out_pins [get_pins -quiet -hier U_NPC/NPC]
set npcop_q_pins [get_pins -quiet -hier U_ControlUnit/U_NPCOp/out_data*]
set ifpca4_d_pins [get_pins -quiet -hier U_ControlUnit/U_IF_PCA4/in_data*]
set ifid_offset_d_pins [get_pins -quiet -hier U_ControlUnit/U_IFID_Offet/in_data*]
set ifid_aluop_d_pins [get_pins -quiet -hier U_ControlUnit/U_IFID_ALUOp/in_data*]
set alua_q_pins [get_pins -quiet -hier U_A/out_data*]
set idex_b_q_pins [get_pins -quiet -hier U_ControlUnit/U_IDEX_ALU_B/out_data*]
set aluout_d_pins [get_pins -quiet -hier U_ALUOut/in_data*]

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $clock_regs] > 0} {
    group_path -name IM_TO_PIPE -from $im_q_pins -to $clock_regs -weight 8 -critical_range 0.20
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $im_a_pins] > 0} {
    group_path -name IM_Q_TO_IM_A -from $im_q_pins -to $im_a_pins -weight 24 -critical_range 0.50
}

if {[sizeof_collection $ir_in_pins] > 0 && [sizeof_collection $clock_regs] > 0} {
    group_path -name IR_TO_PIPE -from $ir_in_pins -to $clock_regs -weight 10 -critical_range 0.20
}

if {[sizeof_collection $ctrl_decode_in_pins] > 0 && [sizeof_collection $clock_regs] > 0} {
    group_path -name CTRL_DECODE -from $ctrl_decode_in_pins -to $clock_regs -weight 12 -critical_range 0.20
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $pc_q_pins] > 0} {
    group_path -name IM_Q_TO_PC -from $im_q_pins -to $pc_q_pins -weight 12 -critical_range 0.25
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $npc_out_pins] > 0} {
    group_path -name IM_Q_TO_NPC -from $im_q_pins -to $npc_out_pins -weight 10 -critical_range 0.20
}

if {[sizeof_collection $npcop_q_pins] > 0 && [sizeof_collection $ifpca4_d_pins] > 0} {
    group_path -name NPCOP_TO_IFPCA4 -from $npcop_q_pins -to $ifpca4_d_pins -weight 18 -critical_range 0.20
    set_max_delay 4.72 -from $npcop_q_pins -to $ifpca4_d_pins -datapath_only
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $ifid_offset_d_pins] > 0} {
    group_path -name IM_TO_IFID_OFFSET -from $im_q_pins -to $ifid_offset_d_pins -weight 20 -critical_range 0.25
    set_max_delay 4.80 -from $im_q_pins -to $ifid_offset_d_pins -datapath_only
}

if {[sizeof_collection $im_q_pins] > 0 && [sizeof_collection $ifid_aluop_d_pins] > 0} {
    # Exact hot path seen in timing: U_IM/memory/Q* -> decode -> U_IFID_ALUOp/D.
    group_path -name IM_TO_IFID_ALUOP -from $im_q_pins -to $ifid_aluop_d_pins -weight 30 -critical_range 0.35
    set_max_delay 4.66 -from $im_q_pins -to $ifid_aluop_d_pins -datapath_only
}

if {[sizeof_collection $ctrl_decode_in_pins] > 0 && [sizeof_collection $ifid_aluop_d_pins] > 0} {
    group_path -name CTRL_TO_IFID_ALUOP -from $ctrl_decode_in_pins -to $ifid_aluop_d_pins -weight 18 -critical_range 0.22
}

if {[sizeof_collection $idex_b_q_pins] > 0 && [sizeof_collection $aluout_d_pins] > 0} {
    group_path -name IDEXB_TO_ALUOUT -from $idex_b_q_pins -to $aluout_d_pins -weight 32 -critical_range 0.35
    set_max_delay 4.68 -from $idex_b_q_pins -to $aluout_d_pins -datapath_only
}

if {[sizeof_collection $alua_q_pins] > 0 && [sizeof_collection $aluout_d_pins] > 0} {
    group_path -name ALUA_TO_ALUOUT -from $alua_q_pins -to $aluout_d_pins -weight 28 -critical_range 0.30
    set_max_delay 4.68 -from $alua_q_pins -to $aluout_d_pins -datapath_only
}

redirect -file $REPORT_DIR/precompile_check_design.rpt {check_design}
redirect -file $REPORT_DIR/precompile_check_timing.rpt {check_timing}

set compile_base_opts [list -timing_high_effort_script]
if {$SAFE_PRESERVE_MODE || $PRESERVE_ALL_SEQ_DEBUG} {
    lappend compile_base_opts -no_autoungroup
}

if {$ENABLE_RETIME} {
    eval compile_ultra [concat $compile_base_opts [list -retime]]
    eval compile_ultra [concat [list -incremental] $compile_base_opts [list -retime]]
} else {
    eval compile_ultra $compile_base_opts
    eval compile_ultra [concat [list -incremental] $compile_base_opts]
    eval compile_ultra [concat [list -incremental] $compile_base_opts]
}

set_fix_hold [get_clocks $CLK_NAME]
if {$ENABLE_RETIME} {
    if {$SAFE_PRESERVE_MODE || $PRESERVE_ALL_SEQ_DEBUG} {
        compile_ultra -incremental -retime -no_autoungroup
    } else {
        compile_ultra -incremental -retime
    }
} else {
    if {$SAFE_PRESERVE_MODE || $PRESERVE_ALL_SEQ_DEBUG} {
        compile_ultra -incremental -no_autoungroup
        compile_ultra -incremental -timing_high_effort_script -no_autoungroup
        compile_ultra -incremental -timing_high_effort_script -no_autoungroup
    } else {
        compile_ultra -incremental
        compile_ultra -incremental -timing_high_effort_script
        compile_ultra -incremental -timing_high_effort_script
    }
}

if {$REPORT_RF_DEBUG} {
    set rf_reg_bit4_d_pre [get_pins -quiet -hier {U_RF/register_reg*\[4\]/D}]
    set rf_reg_bit6_d_pre [get_pins -quiet -hier {U_RF/register_reg*\[6\]/D}]
    if {[sizeof_collection $rf_reg_bit4_d_pre] > 0} {
        catch {redirect -file $REPORT_DIR/rf_reg_bit4_d_pre_timing.rpt [list report_timing -to $rf_reg_bit4_d_pre -delay max -max_paths 32 -nworst 1 -input_pins -nets -transition_time]}
    }
    if {[sizeof_collection $rf_reg_bit6_d_pre] > 0} {
        catch {redirect -file $REPORT_DIR/rf_reg_bit6_d_pre_timing.rpt [list report_timing -to $rf_reg_bit6_d_pre -delay max -max_paths 32 -nworst 1 -input_pins -nets -transition_time]}
    }
}

change_names -rules verilog -hierarchy

set im_q_post [get_pins -quiet -hier *U_IM*memory*/Q*]
set im_a_post [get_pins -quiet -hier *U_IM*memory*/A*]
set ifid_aluop_post [get_pins -quiet -hier *U_ControlUnit*U_IFID_ALUOp*out_data_reg*/D]
set rf_post [get_cells -quiet -hier *U_RF*]
set rf_wd_post [get_pins -quiet -hier *U_RF*RF_WD*]
set rf_wr_post [get_pins -quiet -hier *U_RF*WR*]
set rf_write_post [get_pins -quiet -hier *U_RF*RFWrite*]
set rf_rr1_post [get_pins -quiet -hier *U_RF*RF_RR1*]
set rf_rr2_post [get_pins -quiet -hier *U_RF*RF_RR2*]

redirect -file $REPORT_DIR/qor.rpt                {report_qor}
redirect -file $REPORT_DIR/area.rpt               {report_area}
redirect -file $REPORT_DIR/reference.rpt          {report_reference}
redirect -file $REPORT_DIR/resources.rpt          {report_resources}
redirect -file $REPORT_DIR/constraint.rpt         {report_constraint -all_violators}
redirect -file $REPORT_DIR/timing_max_20.rpt      {report_timing -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time}
if {$REPORT_RF_DEBUG} {
    redirect -file $REPORT_DIR/rf_debug_summary.rpt {
        echo "REPORT_RF_DEBUG summary"
        echo "rf_post count:"
        sizeof_collection $rf_post
        query_objects $rf_post
        echo "rf_wd_post count:"
        sizeof_collection $rf_wd_post
        query_objects $rf_wd_post
        echo "rf_wr_post count:"
        sizeof_collection $rf_wr_post
        query_objects $rf_wr_post
        echo "rf_write_post count:"
        sizeof_collection $rf_write_post
        query_objects $rf_write_post
        echo "rf_rr1_post count:"
        sizeof_collection $rf_rr1_post
        query_objects $rf_rr1_post
        echo "rf_rr2_post count:"
        sizeof_collection $rf_rr2_post
        query_objects $rf_rr2_post
    }
}
if {[sizeof_collection $im_q_post] > 0} {
    redirect -file $REPORT_DIR/im_to_pipe_timing.rpt [list report_timing -from $im_q_post -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}
if {[sizeof_collection $im_q_post] > 0 && [sizeof_collection $im_a_post] > 0} {
    redirect -file $REPORT_DIR/im_feedback_timing.rpt [list report_timing -from $im_q_post -to $im_a_post -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}
if {[sizeof_collection $im_a_post] > 0} {
    redirect -file $REPORT_DIR/im_address_endpoint_timing.rpt [list report_timing -to $im_a_post -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}
if {[sizeof_collection $im_q_post] > 0 && [sizeof_collection $ifid_aluop_post] > 0} {
    redirect -file $REPORT_DIR/im_to_ifid_aluop_timing.rpt [list report_timing -from $im_q_post -to $ifid_aluop_post -delay max -max_paths 20 -nworst 1 -input_pins -nets -transition_time]
}
if {$REPORT_RF_DEBUG} {
    if {[sizeof_collection $rf_post] > 0} {
        redirect -file $REPORT_DIR/rf_cell.rpt [list report_cell $rf_post]
    }
    if {[sizeof_collection $rf_wd_post] > 0} {
        redirect -file $REPORT_DIR/rf_wd_timing.rpt [list report_timing -to $rf_wd_post -delay max -max_paths 32 -nworst 1 -input_pins -nets -transition_time]
    }
    if {[sizeof_collection $rf_wr_post] > 0} {
        redirect -file $REPORT_DIR/rf_wr_timing.rpt [list report_timing -to $rf_wr_post -delay max -max_paths 16 -nworst 1 -input_pins -nets -transition_time]
    }
    if {[sizeof_collection $rf_write_post] > 0} {
        redirect -file $REPORT_DIR/rf_write_enable_timing.rpt [list report_timing -to $rf_write_post -delay max -max_paths 8 -nworst 1 -input_pins -nets -transition_time]
    }
    if {[sizeof_collection $rf_rr1_post] > 0} {
        redirect -file $REPORT_DIR/rf_rr1_timing.rpt [list report_timing -to $rf_rr1_post -delay max -max_paths 8 -nworst 1 -input_pins -nets -transition_time]
    }
    if {[sizeof_collection $rf_rr2_post] > 0} {
        redirect -file $REPORT_DIR/rf_rr2_timing.rpt [list report_timing -to $rf_rr2_post -delay max -max_paths 8 -nworst 1 -input_pins -nets -transition_time]
    }
    foreach bit {4 6} {
        set rf_wd_bit_pin [get_pins -quiet -hier *U_RF*RF_WD\[$bit\]]
        if {[sizeof_collection $rf_wd_bit_pin] > 0} {
            redirect -file $REPORT_DIR/rf_wd_bit${bit}_timing.rpt [list report_timing -to $rf_wd_bit_pin -delay max -max_paths 8 -nworst 1 -input_pins -nets -transition_time]
            set rf_wd_bit_net [get_nets -quiet -of_objects $rf_wd_bit_pin]
            if {[sizeof_collection $rf_wd_bit_net] > 0} {
                redirect -file $REPORT_DIR/rf_wd_bit${bit}_net.rpt [list report_net -connections $rf_wd_bit_net]
            }
        }
    }
}
catch {redirect -file $REPORT_DIR/power.rpt {report_power}}

write_file -format ddc     -hierarchy -output $RESULT_DIR/${TOP}_sram_opt.ddc
write_file -format verilog -hierarchy -output $RESULT_DIR/${TOP}_sram_opt.v
write_sdc $RESULT_DIR/${TOP}_sram_opt.sdc
catch {write_sdf $RESULT_DIR/${TOP}_sram_opt.sdf}

puts "Synthesis completed."
puts "Reports  : $REPORT_DIR"
puts "Results  : $RESULT_DIR"
