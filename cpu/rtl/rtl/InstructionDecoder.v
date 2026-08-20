`timescale 1ns / 1ps

`include "ctrl_signal_def.v"
`include "instruction_def.v"

module InstructionDecoder(
    input  [6:0] opcode,
    input  [6:0] Funct7,
    input  [2:0] Funct3,
    input  [4:0] rs1,
    input  [4:0] rs2,
    input  [4:0] rd,

    output dec_valid,

    output       rfwrite,
    output       dmctrl,
    output [1:0] alusrcb,
    output [1:0] wdsel,
    output [3:0] aluop
);

wire dec_is_rtype;
wire dec_is_itype;
wire dec_is_lw;
wire dec_is_sw;
wire dec_is_btype;
wire dec_is_jal;
wire dec_is_jalr;
wire dec_r_add;
wire dec_r_sub;
wire dec_r_and;
wire dec_r_or;
wire dec_r_xor;
wire dec_r_sll;
wire dec_r_srl;
wire dec_r_sra;
wire dec_r_valid;
wire dec_i_addi;
wire dec_i_ori;
wire dec_i_valid;
wire dec_lw_valid;
wire dec_sw_valid;
wire dec_b_valid;
wire dec_jal_valid;
wire dec_jalr_valid;
`ifdef DIFFTEST
wire dec_is_ebreak;
`endif

assign dec_is_rtype = (opcode == `INSTR_RTYPE_OP);
assign dec_is_itype = (opcode == `INSTR_ITYPE_OP);
assign dec_is_lw    = (opcode == `INSTR_LW_OP);
assign dec_is_sw    = (opcode == `INSTR_SW_OP);
assign dec_is_btype = (opcode == `INSTR_BTYPE_OP);
assign dec_is_jal   = (opcode == `INSTR_JAL_OP);
assign dec_is_jalr  = (opcode == `INSTR_JALR_OP);

assign dec_r_add = dec_is_rtype && ({Funct7, Funct3} == `INSTR_ADD_FUNCT);
assign dec_r_sub = dec_is_rtype && ({Funct7, Funct3} == `INSTR_SUB_FUNCT);
assign dec_r_and = dec_is_rtype && ({Funct7, Funct3} == `INSTR_AND_FUNCT);
assign dec_r_or  = dec_is_rtype && ({Funct7, Funct3} == `INSTR_OR_FUNCT);
assign dec_r_xor = dec_is_rtype && ({Funct7, Funct3} == `INSTR_XOR_FUNCT);
assign dec_r_sll = dec_is_rtype && ({Funct7, Funct3} == `INSTR_SLL_FUNCT);
assign dec_r_srl = dec_is_rtype && ({Funct7, Funct3} == `INSTR_SRL_FUNCT);
assign dec_r_sra = dec_is_rtype && ({Funct7, Funct3} == `INSTR_SRA_FUNCT);
assign dec_r_valid = dec_r_add || dec_r_sub || dec_r_and || dec_r_or ||
                     dec_r_xor || dec_r_sll || dec_r_srl || dec_r_sra;

assign dec_i_addi  = dec_is_itype && (Funct3 == `INSTR_ADDI_FUNCT);
assign dec_i_ori   = dec_is_itype && (Funct3 == `INSTR_ORI_FUNCT);
assign dec_i_valid = dec_i_addi || dec_i_ori;

assign dec_lw_valid   = dec_is_lw    && (Funct3 == 3'b010);
assign dec_sw_valid   = dec_is_sw    && (Funct3 == 3'b010);
assign dec_b_valid    = dec_is_btype && ((Funct3 == `INSTR_BEQ_FUNCT) ||
                                         (Funct3 == `INSTR_BNE_FUNCT));
assign dec_jal_valid  = dec_is_jal;
assign dec_jalr_valid = dec_is_jalr && (Funct3 == 3'b000);
`ifdef DIFFTEST
assign dec_is_ebreak  = ({Funct7, rs2, rs1, Funct3, rd, opcode} ==
                         32'h0010_0073);
`endif

assign dec_valid = dec_r_valid || dec_i_valid || dec_lw_valid ||
                   dec_sw_valid || dec_b_valid || dec_jal_valid ||
                   dec_jalr_valid
`ifdef DIFFTEST
                   || dec_is_ebreak
`endif
                   ;

assign rfwrite = dec_r_valid || dec_i_valid || dec_lw_valid ||
                 dec_jal_valid || dec_jalr_valid;
assign dmctrl = dec_sw_valid ? `DMCtrl_WR : `DMCtrl_RD;
assign alusrcb = (dec_i_valid || dec_jalr_valid) ? `ALUSrcB_Imm :
                 ((dec_lw_valid || dec_sw_valid) ?
                  `ALUSrcB_Offset : `ALUSrcB_B);
assign wdsel = dec_lw_valid ? `WDSel_FromMEM :
               ((dec_jal_valid || dec_jalr_valid) ?
                `WDSel_FromPC : `WDSel_FromALU);

assign aluop[0] = dec_b_valid || dec_i_ori ||
                  (dec_r_valid &&
                   (((Funct3 == 3'b000) && Funct7[5]) ||
                    (Funct3 == 3'b110) || (Funct3 == 3'b101)));
assign aluop[1] = dec_i_ori ||
                  (dec_r_valid &&
                   ((Funct3 == 3'b111) || (Funct3 == 3'b110)));
assign aluop[2] = dec_r_valid && Funct3[2] && !Funct3[1] &&
                  (!Funct3[0] || Funct7[5]);
assign aluop[3] = dec_r_valid && !Funct3[1] && Funct3[0] &&
                  (!Funct3[2] || !Funct7[5]);

endmodule
