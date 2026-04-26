`include "ctrl_signal_def.v"
`include "instruction_def.v"

module EXT(
    imm_in, ExtSel, imm_out, ins, opcode_out, Funct3_out, Funct7_out, rs1_out, rs2_out, rd_out, Imm12_out, Offset20_out, Offset_out,
    clk, rst, ID_Imm12_pipe, ID_Offset_pipe, ID_Offset20_pipe, EX_Imm32_pipe, EX_Offset_pipe, EX_Offset20_pipe,
    IF_PCA4_in, IF_PC_in, ID_rs1_pipe, ID_rs2_pipe, ID_rd_pipe, EX_PCA4_pipe, EX_PC_pipe, EX_rd_pipe
);
    input  [11:0] imm_in;
    input         ExtSel;
    input  [31:0] ins;
    input         clk;
    input         rst;
    input  [31:0] IF_PCA4_in;
    input  [31:0] IF_PC_in;
    output reg [31:0] imm_out;
    output [6:0] opcode_out;
    output [2:0] Funct3_out;
    output [6:0] Funct7_out;
    output [4:0] rs1_out;
    output [4:0] rs2_out;
    output [4:0] rd_out;
    output [11:0] Imm12_out;
    output [20:1] Offset20_out;
    output [11:0] Offset_out;
    output reg [11:0] ID_Imm12_pipe;
    output reg [11:0] ID_Offset_pipe;
    output reg [19:0] ID_Offset20_pipe;
    output reg [31:0] EX_Imm32_pipe;
    output reg [11:0] EX_Offset_pipe;
    output reg [19:0] EX_Offset20_pipe;
    output reg [4:0]  ID_rs1_pipe;
    output reg [4:0]  ID_rs2_pipe;
    output reg [4:0]  ID_rd_pipe;
    output reg [31:0] EX_PCA4_pipe;
    output reg [31:0] EX_PC_pipe;
    output reg [4:0]  EX_rd_pipe;
    reg [31:0] ID_PCA4_pipe;
    reg [31:0] ID_PC_pipe;

    always @(*) begin
        case(ExtSel)
            `ExtSel_ZERO  : imm_out = {20'b0, imm_in[11:0]};
            `ExtSel_SIGNED: imm_out = {imm_in[11] ? 20'hfffff : 20'h00000, imm_in[11:0]};
            default       : imm_out = 32'b0;
        endcase
    end

    assign opcode_out = ins[6:0];
    assign Funct3_out = ins[14:12];
    assign Funct7_out = ins[31:25];
    assign rs1_out = ins[19:15];
    assign rs2_out = ins[24:20];
    assign rd_out = ins[11:7];
    assign Imm12_out = ins[31:20];
    assign Offset20_out = {ins[31], ins[19:12], ins[20], ins[30:21]};
    assign Offset_out = (opcode_out == `INSTR_BTYPE_OP) ? {ins[31], ins[7], ins[30:25], ins[11:8]} :
                        (opcode_out == `INSTR_SW_OP) ? {ins[31:25], ins[11:7]} : Imm12_out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ID_Imm12_pipe <= 12'b0;
            ID_Offset_pipe <= 12'b0;
            ID_Offset20_pipe <= 20'b0;
            ID_PCA4_pipe <= 32'b0;
            ID_PC_pipe <= 32'b0;
            ID_rs1_pipe <= 5'b0;
            ID_rs2_pipe <= 5'b0;
            ID_rd_pipe <= 5'b0;
            EX_Imm32_pipe <= 32'b0;
            EX_Offset_pipe <= 12'b0;
            EX_Offset20_pipe <= 20'b0;
            EX_PCA4_pipe <= 32'b0;
            EX_PC_pipe <= 32'b0;
            EX_rd_pipe <= 5'b0;
        end else begin
            ID_Imm12_pipe <= Imm12_out;
            ID_Offset_pipe <= Offset_out;
            ID_Offset20_pipe <= Offset20_out;
            ID_PCA4_pipe <= IF_PCA4_in;
            ID_PC_pipe <= IF_PC_in;
            ID_rs1_pipe <= rs1_out;
            ID_rs2_pipe <= rs2_out;
            ID_rd_pipe <= rd_out;
            EX_Imm32_pipe <= imm_out;
            EX_Offset_pipe <= ID_Offset_pipe;
            EX_Offset20_pipe <= ID_Offset20_pipe;
            EX_PCA4_pipe <= ID_PCA4_pipe;
            EX_PC_pipe <= ID_PC_pipe;
            EX_rd_pipe <= ID_rd_pipe;
        end
    end

endmodule
