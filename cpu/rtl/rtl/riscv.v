`timescale 1ns / 1ps


//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 2024/11/22 13:30:25
// Design Name:
// Module Name: riscv
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module riscv(clk, rst, RD, out_ins, trap, trap_cause, trap_epc, trap_tval
`ifdef WISHBONE
, iwb_adr_o, iwb_dat_o, iwb_dat_i, iwb_sel_o, iwb_we_o,
  iwb_cyc_o, iwb_stb_o, iwb_ack_i, iwb_err_i,
  dwb_adr_o, dwb_dat_o, dwb_dat_i, dwb_sel_o, dwb_we_o,
  dwb_cyc_o, dwb_stb_o, dwb_ack_i, dwb_err_i
`endif
`ifdef DIFFTEST
, done
`endif
);
input clk, rst;
output [31:0] RD;
output [31:0] out_ins;
output trap;
output [3:0] trap_cause;
output [31:0] trap_epc;
output [31:0] trap_tval;

`ifdef WISHBONE
output [31:0] iwb_adr_o;
output [31:0] iwb_dat_o;
input  [31:0] iwb_dat_i;
output [3:0]  iwb_sel_o;
output        iwb_we_o;
output        iwb_cyc_o;
output        iwb_stb_o;
input         iwb_ack_i;
input         iwb_err_i;
output [31:0] dwb_adr_o;
output [31:0] dwb_dat_o;
input  [31:0] dwb_dat_i;
output [3:0]  dwb_sel_o;
output        dwb_we_o;
output        dwb_cyc_o;
output        dwb_stb_o;
input         dwb_ack_i;
input         dwb_err_i;
`endif

`ifdef DIFFTEST
output done;
`endif

wire RFWrite, DMCtrl, PCWrite, InsMemRW;
wire [1:0] NPCOp;
wire [3:0] ALUOp;
wire [6:0] opcode;
wire [2:0] Funct3;
wire [6:0] Funct7;
wire [31:0] PC, NPC, PCA4;
wire [31:0] in_ins, DR_out;
wire [4:0] rs1, rs2, rd;
wire [11:0] Imm12;
wire [20:1] Offset20;
wire [11:0] Offset;
wire [4:0] WR;
wire [31:0] RD1, RD1_r, RD2, RD2_r;
wire [31:0] A, B, ALU_result, ALU_result_r;

/* pipeline interconnect */
wire [31:0] PC_NPC, NPC_PC;
wire [31:0] FETCH_PC;
wire        ICache_mem_req;
wire [31:0] ICache_mem_addr;
wire        ICache_mem_ready;
wire        ICache_mem_error;
wire [31:0] ICache_mem_data;
wire [19:0] NPC_EX_Offset20;
wire [11:0] NPC_EX_Offset12;
wire [4:0]  WB_rd;
wire forward1, forward2;
wire [31:0] FD1, FD2;
wire [31:0] EX_ALU_B;
wire [31:0] RF_WD;
wire [31:0] DM_WD;
wire [31:0] NPC_taken_p4;
wire [4:0]  ID_rs1, ID_rs2;
wire IF_ready, IF_error, DM_ready, DM_error;
wire mem_hold;
wire DMReq;

wire [31:0] im_adr;
wire [31:0] im_dat_o;
wire [31:0] im_dat_i;
wire [3:0]  im_sel;
wire        im_we;
wire        im_cyc;
wire        im_stb;
wire        im_ack;
wire        im_err;
wire        im_local;
wire [31:0] im_local_data;
wire        im_local_ack;
wire        im_local_err;

wire [31:0] dm_adr;
wire [31:0] dm_dat_o;
wire [31:0] dm_dat_i;
wire [3:0]  dm_sel;
wire        dm_we;
wire        dm_cyc;
wire        dm_stb;
wire        dm_ack;
wire        dm_err;
wire        dm_local;
wire [31:0] dm_local_data;
wire        dm_local_ack;
wire        dm_local_err;

assign opcode  = out_ins[6:0];
assign Funct3  = out_ins[14:12];
assign Funct7  = out_ins[31:25];
assign rs1     = out_ins[19:15];
assign rs2     = out_ins[24:20];
assign rd      = out_ins[11:7];
assign Imm12   = out_ins[31:20];
assign Offset20 = {out_ins[31],out_ins[19:12],out_ins[20],out_ins[30:21]};
assign Offset  = (opcode == `INSTR_BTYPE_OP) ? {out_ins[31],out_ins[7],out_ins[30:25],out_ins[11:8]} :
                 (opcode == `INSTR_SW_OP)  ? {out_ins[31:25],out_ins[11:7]} : Imm12;

ControlUnit U_ControlUnit(
    .clk(clk), .rst(rst), .opcode(opcode), .Funct7(Funct7), .Funct3(Funct3),
    .RFWrite(RFWrite), .DMCtrl(DMCtrl), .PCWrite(PCWrite), .InsMemRW(InsMemRW),
    .ALUOp(ALUOp), .NPCOp(NPCOp),

    .rs1(rs1), .rs2(rs2), .rd(rd), .Imm12(Imm12), .Offset(Offset),
    .Offset20(Offset20),
    .PC(PC), .PCA4(PCA4),
    .NPC(NPC), .NPC_taken_p4(NPC_taken_p4),
    .RD1(RD1), .RD2(RD2),
    .ALU_result(ALU_result), .ALU_result_r(ALU_result_r),
    .DM_RD(DR_out),
    .RD2_r(RD2_r),
    .IF_ready(IF_ready), .IF_error(IF_error),
    .DM_ready(DM_ready), .DM_error(DM_error),

    .mem_hold(mem_hold),
    .PC_NPC(PC_NPC), .NPC_PC(NPC_PC),
    .FETCH_PC(FETCH_PC),
    .NPC_EX_Offset12(NPC_EX_Offset12), .NPC_EX_Offset20(NPC_EX_Offset20),
    .WB_rd_out(WB_rd),
    .forward1(forward1), .forward2(forward2), .FD1(FD1), .FD2(FD2),
    .RF_WD(RF_WD), .ID_rs1_out(ID_rs1), .ID_rs2_out(ID_rs2),
    .EX_ALU_B(EX_ALU_B), .DM_WD(DM_WD),
    .DMReq(DMReq),
    .trap(trap), .trap_cause(trap_cause), .trap_epc(trap_epc), .trap_tval(trap_tval)


`ifdef DIFFTEST
    , .done(done)
`endif


);

PC U_PC (
    .clk(clk), .rst(rst), .write_enable(PCWrite),
    .next_pc(PC_NPC), .pc(PC)
);

NPC U_NPC (
    .PC(PC), .NPCOp(NPCOp), .PCA4(PCA4), .NPC(NPC),
    .NPC_PC(NPC_PC), .NPC_Offset12(NPC_EX_Offset12), .NPC_Offset20(NPC_EX_Offset20), .NPC_rs(RD1_r),
    .NPC_taken_p4(NPC_taken_p4)
);

InstructionCache U_InstructionCache (
    .clk(clk), .rst(rst),
    .req_valid(InsMemRW), .req_addr(FETCH_PC),
    .rsp_valid(IF_ready), .rsp_error(IF_error), .rsp_data(in_ins),
    .mem_req(ICache_mem_req), .mem_addr(ICache_mem_addr),
    .mem_ready(ICache_mem_ready), .mem_error(ICache_mem_error),
    .mem_rdata(ICache_mem_data)
);

WishboneMaster U_InstructionWishboneMaster (
    .req_valid(ICache_mem_req),
    .req_addr(ICache_mem_addr), .req_wdata(32'b0),
    .req_sel(4'b1111), .req_we(1'b0),
    .rsp_valid(ICache_mem_ready), .rsp_error(ICache_mem_error),
    .rsp_rdata(ICache_mem_data),
    .wb_adr_o(im_adr), .wb_dat_o(im_dat_o), .wb_dat_i(im_dat_i),
    .wb_sel_o(im_sel), .wb_we_o(im_we),
    .wb_cyc_o(im_cyc), .wb_stb_o(im_stb),
    .wb_ack_i(im_ack), .wb_err_i(im_err)
);

// 0x0000_2000-0x0000_2fff is the local instruction SRAM window.
assign im_local = (im_adr[31:12] == 20'h00002);

WishboneInstructionMemory U_InstructionMemorySlave (
    .clk(clk), .rst(rst),
    .wb_adr_i(im_adr),
    .wb_cyc_i(im_cyc && im_local), .wb_stb_i(im_stb && im_local),
    .wb_dat_o(im_local_data), .wb_ack_o(im_local_ack),
    .wb_err_o(im_local_err)
);

assign im_dat_i = im_local ? im_local_data :
`ifdef WISHBONE
                  iwb_dat_i;
assign im_ack   = im_local ? im_local_ack : iwb_ack_i;
assign im_err   = im_local ? im_local_err : iwb_err_i;
assign iwb_adr_o = im_adr;
assign iwb_dat_o = im_dat_o;
assign iwb_sel_o = im_sel;
assign iwb_we_o  = im_we;
assign iwb_cyc_o = im_cyc && !im_local;
assign iwb_stb_o = im_stb && !im_local;
`else
                  32'b0;
assign im_ack   = im_local ? im_local_ack : 1'b0;
assign im_err   = im_local ? im_local_err : (im_cyc && im_stb);
`endif

assign out_ins = in_ins;

RF U_RF (
    .RR1(ID_rs1), .RR2(ID_rs2), .WR(WR), .WD(RF_WD), .clk(clk),
    .RFWrite(RFWrite), .RD1(RD1), .RD2(RD2),
    .forward1(forward1), .forward2(forward2),
    .FD1(FD1), .FD2(FD2)
);

assign WR = WB_rd;

Flopr U_A (
    .clk(clk), .rst(rst), .in_data(mem_hold ? RD1_r : RD1), .out_data(RD1_r)
);

Flopr U_B (
    .clk(clk), .rst(rst), .in_data(mem_hold ? RD2_r : RD2), .out_data(RD2_r)
);

assign A = RD1_r;
assign B = EX_ALU_B;

ALU U_ALU (
    .A(A), .B(B), .ALUOp(ALUOp), .ALU_result(ALU_result)
);

Flopr U_ALUOut (
    .clk(clk), .rst(rst),
    .in_data(mem_hold ? ALU_result_r : ALU_result),
    .out_data(ALU_result_r)
);

WishboneMaster U_DataWishboneMaster (
    .req_valid(DMReq),
    .req_addr(ALU_result_r), .req_wdata(DM_WD),
    .req_sel(4'b1111), .req_we(DMCtrl),
    .rsp_valid(DM_ready), .rsp_error(DM_error), .rsp_rdata(DR_out),
    .wb_adr_o(dm_adr), .wb_dat_o(dm_dat_o), .wb_dat_i(dm_dat_i),
    .wb_sel_o(dm_sel), .wb_we_o(dm_we),
    .wb_cyc_o(dm_cyc), .wb_stb_o(dm_stb),
    .wb_ack_i(dm_ack), .wb_err_i(dm_err)
);

// 0x0000_0000-0x0000_0fff is the local data SRAM window.
assign dm_local = (dm_adr[31:12] == 20'h00000);

WishboneDataMemory U_DataMemorySlave (
    .clk(clk), .rst(rst),
    .wb_adr_i(dm_adr), .wb_dat_i(dm_dat_o), .wb_sel_i(dm_sel),
    .wb_we_i(dm_we), .wb_cyc_i(dm_cyc && dm_local),
    .wb_stb_i(dm_stb && dm_local),
    .wb_dat_o(dm_local_data), .wb_ack_o(dm_local_ack),
    .wb_err_o(dm_local_err)
);

assign dm_dat_i = dm_local ? dm_local_data :
`ifdef WISHBONE
                  dwb_dat_i;
assign dm_ack   = dm_local ? dm_local_ack : dwb_ack_i;
assign dm_err   = dm_local ? dm_local_err : dwb_err_i;
assign dwb_adr_o = dm_adr;
assign dwb_dat_o = dm_dat_o;
assign dwb_sel_o = dm_sel;
assign dwb_we_o  = dm_we;
assign dwb_cyc_o = dm_cyc && !dm_local;
assign dwb_stb_o = dm_stb && !dm_local;
`else
                  32'b0;
assign dm_ack   = dm_local ? dm_local_ack : 1'b0;
assign dm_err   = dm_local ? dm_local_err : (dm_cyc && dm_stb);
`endif

assign RD = DR_out;


endmodule
