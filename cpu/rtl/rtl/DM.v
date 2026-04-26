`include "ctrl_signal_def.v"

module DM(
    Addr, clk, rst, RD,
    EX_WD_in, EX_PCA4_in, EX_rd_in, EX_WDSel_in, EX_RFWrite_in, EX_DMCtrl_in, EX_done_in,
    MEM_PCA4_out, MEM_rd_out, MEM_WDSel_out, MEMStall_WDSel_out, MEMStall_stall_out,
    WB_rd_out, WB_RFWrite_out, WB_WD_in, WB_WD_out, done_out,
    DMReadStall, EX_branch_in, NPC_NPC_in, dnpc_out
);
    input  [11:2] Addr;
    input         clk;
    input         rst;

    input  [31:0] EX_WD_in;
    input  [31:0] EX_PCA4_in;
    input  [4:0]  EX_rd_in;
    input  [1:0]  EX_WDSel_in;
    input         EX_RFWrite_in;
    input         EX_DMCtrl_in;
    input         EX_done_in;
    input         EX_branch_in;
    input  [31:0] NPC_NPC_in;

    output reg [31:0] RD;
    output reg [31:0] MEM_PCA4_out;
    output reg [4:0]  MEM_rd_out;
    output reg [1:0]  MEM_WDSel_out;
    output reg [1:0]  MEMStall_WDSel_out;
    output reg        MEMStall_stall_out;

    output reg [4:0]  WB_rd_out;
    output reg        WB_RFWrite_out;
    input  [31:0]     WB_WD_in;
    output reg [31:0] WB_WD_out;
    output reg        done_out;

    output        DMReadStall;
    output reg [31:0] dnpc_out;

    reg [31:0] memory[0:1023];
    reg [31:0] MEM_WD_out;
    reg        MEM_RFWrite_out;
    reg        MEM_DMCtrl_out;
    reg        MEM_done_out;
    reg [4:0]  MEMStall_rd_out;
    reg        MEMStall_RFWrite_out;
    reg        MEMStall_done_out;
    reg        WB_done_out;
    reg [31:0] MEM_dnpc_out;
    reg [31:0] MEMStall_dnpc_out;
    reg [31:0] WB_dnpc_out;

    assign DMReadStall = (MEM_RFWrite_out == 1'b1) && (MEM_WDSel_out == `WDSel_FromMEM);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            MEM_WD_out <= 32'b0;
            MEM_PCA4_out <= 32'b0;
            MEM_rd_out <= 5'b0;
            MEM_WDSel_out <= 2'b0;
            MEM_RFWrite_out <= 1'b0;
            MEM_DMCtrl_out <= 1'b0;
            MEM_done_out <= 1'b0;
        end else begin
            MEM_WD_out <= EX_WD_in;
            MEM_PCA4_out <= EX_PCA4_in;
            MEM_rd_out <= EX_rd_in;
            MEM_WDSel_out <= EX_WDSel_in;
            MEM_RFWrite_out <= EX_RFWrite_in;
            MEM_DMCtrl_out <= EX_DMCtrl_in;
            MEM_done_out <= EX_done_in;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            MEM_dnpc_out <= 32'b0;
            MEMStall_rd_out <= 5'b0;
            MEMStall_WDSel_out <= 2'b0;
            MEMStall_RFWrite_out <= 1'b0;
            MEMStall_done_out <= 1'b0;
            MEMStall_stall_out <= 1'b0;
            MEMStall_dnpc_out <= 32'b0;
        end else begin
            MEM_dnpc_out <= EX_branch_in ? NPC_NPC_in : EX_PCA4_in;
            MEMStall_rd_out <= DMReadStall ? MEM_rd_out : 5'b0;
            MEMStall_WDSel_out <= DMReadStall ? MEM_WDSel_out : 2'b0;
            MEMStall_RFWrite_out <= DMReadStall ? MEM_RFWrite_out : 1'b0;
            MEMStall_done_out <= DMReadStall ? MEM_done_out : 1'b0;
            MEMStall_stall_out <= DMReadStall;
            MEMStall_dnpc_out <= MEM_dnpc_out;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            WB_rd_out <= 5'b0;
            WB_RFWrite_out <= 1'b0;
            WB_done_out <= 1'b0;
            WB_WD_out <= 32'b0;
            done_out <= 1'b0;
            WB_dnpc_out <= 32'b0;
            dnpc_out <= 32'b0;
        end else begin
            WB_rd_out <= MEMStall_stall_out ? MEMStall_rd_out : MEM_rd_out;
            WB_RFWrite_out <= DMReadStall ? 1'b0 : (MEMStall_stall_out ? MEMStall_RFWrite_out : MEM_RFWrite_out);
            WB_done_out <= DMReadStall ? 1'b0 : (MEMStall_stall_out ? MEMStall_done_out : MEM_done_out);
            WB_WD_out <= WB_WD_in;
            done_out <= WB_done_out;
            WB_dnpc_out <= MEMStall_stall_out ? MEMStall_dnpc_out : MEM_dnpc_out;
            dnpc_out <= WB_dnpc_out;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            RD <= 32'b0;
        end else if (MEM_DMCtrl_out) begin
            memory[Addr] <= MEM_WD_out;
        end else begin
            RD <= memory[Addr];
        end
    end

endmodule
