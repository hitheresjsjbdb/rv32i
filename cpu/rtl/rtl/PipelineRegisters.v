`timescale 1ns / 1ps

`include "ctrl_signal_def.v"

module FetchDecodeRegisters(
    input         clk,
    input         rst,
    input         ready,
    input         kill,
    input         ex_redirect,
    input  [31:0] im_pc,
    input  [31:0] pc,
    input  [31:0] pca4,
    input  [31:0] npc_taken_p4,
    input  [31:0] if_stage_pc,
    input  [31:0] if_stage_pca4,
    input         if_stage_valid,
    input  [31:0] raw_instruction,
    input         if_illegal,
    input         if_access_fault,
    input  [11:0] imm12,
    input  [11:0] offset,
    input  [19:0] offset20,
    input  [4:0]  rs1,
    input  [4:0]  rs2,
    input  [4:0]  rd,
    input  [3:0]  if_aluop,
    input  [1:0]  if_regsel,
    input  [1:0]  if_alusrcb,
    input  [1:0]  if_wdsel,
    input         if_alusrca,
    input         if_rfwrite,
    input         if_dmctrl,

    output reg        if_valid,
    output reg [31:0] if_pc,
    output reg [31:0] if_pca4,
    output reg [31:0] id_pca4,
    output reg [31:0] id_pc,
    output reg [31:0] id_ins,
    output reg        id_illegal,
    output reg        id_access_fault,
    output reg [11:0] id_imm12,
    output reg [11:0] id_offset,
    output reg [11:0] id_offset12,
    output reg [19:0] id_offset20,
    output reg [4:0]  id_rs1,
    output reg [4:0]  id_rs2,
    output reg [4:0]  id_rd,
    output reg [3:0]  id_aluop,
    output reg [1:0]  id_regsel,
    output reg [1:0]  id_alusrcb,
    output reg [1:0]  id_wdsel,
    output reg        id_alusrca,
    output reg        id_rfwrite,
    output reg        id_dmctrl,
    output reg        id_valid
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        if_valid        <= 1'b0;
        if_pc           <= 32'b0;
        if_pca4         <= 32'b0;
        id_pca4         <= 32'b0;
        id_pc           <= 32'b0;
        id_ins          <= 32'b0;
        id_illegal      <= 1'b0;
        id_access_fault <= 1'b0;
        id_imm12        <= 12'b0;
        id_offset       <= 12'b0;
        id_offset12     <= 12'b0;
        id_offset20     <= 20'b0;
        id_rs1          <= 5'b0;
        id_rs2          <= 5'b0;
        id_rd           <= 5'b0;
        id_aluop        <= 4'b0;
        id_regsel       <= 2'b0;
        id_alusrcb      <= 2'b0;
        id_wdsel        <= 2'b0;
        id_alusrca      <= 1'b0;
        id_rfwrite      <= 1'b0;
        id_dmctrl       <= `DMCtrl_RD;
        id_valid        <= 1'b0;
    end
    else begin
        if (ready) begin
            if_valid <= 1'b1;
            if_pc    <= ex_redirect ? im_pc : pc;
            if_pca4  <= ex_redirect ? npc_taken_p4 : pca4;
        end

        if (kill) begin
            id_pca4         <= 32'b0;
            id_pc           <= 32'b0;
            id_ins          <= 32'b0;
            id_illegal      <= 1'b0;
            id_access_fault <= 1'b0;
            id_imm12        <= 12'b0;
            id_offset       <= 12'b0;
            id_offset12     <= 12'b0;
            id_offset20     <= 20'b0;
            id_rs1          <= 5'b0;
            id_rs2          <= 5'b0;
            id_rd           <= 5'b0;
            id_aluop        <= 4'b0;
            id_regsel       <= 2'b0;
            id_alusrcb      <= 2'b0;
            id_wdsel        <= 2'b0;
            id_alusrca      <= 1'b0;
            id_rfwrite      <= 1'b0;
            id_dmctrl       <= `DMCtrl_RD;
            id_valid        <= 1'b0;
        end
        else if (ready) begin
            id_pca4         <= if_stage_pca4;
            id_pc           <= if_stage_pc;
            id_ins          <= raw_instruction;
            id_illegal      <= if_stage_valid && if_illegal;
            id_access_fault <= if_stage_valid && if_access_fault;
            id_imm12        <= imm12;
            id_offset       <= offset;
            id_offset12     <= offset;
            id_offset20     <= offset20;
            id_rs1          <= rs1;
            id_rs2          <= rs2;
            id_rd           <= rd;
            id_aluop        <= if_stage_valid ? if_aluop : 4'b0;
            id_regsel       <= if_stage_valid ? if_regsel : 2'b0;
            id_alusrcb      <= if_stage_valid ? if_alusrcb : 2'b0;
            id_wdsel        <= if_stage_valid ? if_wdsel : 2'b0;
            id_alusrca      <= if_stage_valid && if_alusrca;
            id_rfwrite      <= if_stage_valid && if_rfwrite;
            id_dmctrl       <= if_stage_valid ? if_dmctrl : `DMCtrl_RD;
            id_valid        <= if_stage_valid;
        end
    end
end

endmodule

module DecodeExecuteRegisters(
    input         clk,
    input         rst,
    input         ready,
    input         kill,
    input  [31:0] id_imm32,
    input  [31:0] id_pca4,
    input  [31:0] id_pc,
    input  [31:0] id_alu_b,
    input  [11:0] id_offset,
    input  [19:0] id_offset20,
    input  [4:0]  id_rd,
    input  [3:0]  id_aluop,
    input  [1:0]  id_regsel,
    input  [1:0]  id_alusrcb,
    input  [1:0]  id_wdsel,
    input         id_alusrca,
    input         id_rfwrite,
    input         id_dmctrl,
    input         id_valid,
    input         id_branch,
    input  [1:0]  id_npcop,

    output reg [31:0] ex_imm32,
    output reg [31:0] ex_pca4,
    output reg [31:0] ex_pc,
    output reg [31:0] ex_alu_b,
    output reg [11:0] ex_offset,
    output reg [19:0] ex_offset20,
    output reg [4:0]  ex_rd,
    output reg [3:0]  ex_aluop,
    output reg [1:0]  ex_regsel,
    output reg [1:0]  ex_alusrcb,
    output reg [1:0]  ex_wdsel,
    output reg        ex_alusrca,
    output reg        ex_rfwrite,
    output reg        ex_dmctrl,
    output reg        ex_valid,
    output reg        ex_branch,
    output reg [1:0]  ex_npcop
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        ex_imm32    <= 32'b0;
        ex_pca4     <= 32'b0;
        ex_pc       <= 32'b0;
        ex_alu_b    <= 32'b0;
        ex_offset   <= 12'b0;
        ex_offset20 <= 20'b0;
        ex_rd       <= 5'b0;
        ex_aluop    <= 4'b0;
        ex_regsel   <= 2'b0;
        ex_alusrcb  <= 2'b0;
        ex_wdsel    <= 2'b0;
        ex_alusrca  <= 1'b0;
        ex_rfwrite  <= 1'b0;
        ex_dmctrl   <= `DMCtrl_RD;
        ex_valid    <= 1'b0;
        ex_branch   <= 1'b0;
        ex_npcop    <= `NPC_PC;
    end
    else if (ready) begin
        if (kill) begin
            ex_imm32    <= 32'b0;
            ex_pca4     <= 32'b0;
            ex_pc       <= 32'b0;
            ex_alu_b    <= 32'b0;
            ex_offset   <= 12'b0;
            ex_offset20 <= 20'b0;
            ex_rd       <= 5'b0;
            ex_aluop    <= 4'b0;
            ex_regsel   <= 2'b0;
            ex_alusrcb  <= 2'b0;
            ex_wdsel    <= 2'b0;
            ex_alusrca  <= 1'b0;
            ex_rfwrite  <= 1'b0;
            ex_dmctrl   <= `DMCtrl_RD;
            ex_valid    <= 1'b0;
            ex_branch   <= 1'b0;
            ex_npcop    <= `NPC_PC;
        end
        else begin
            ex_imm32    <= id_imm32;
            ex_pca4     <= id_pca4;
            ex_pc       <= id_pc;
            ex_alu_b    <= id_alu_b;
            ex_offset   <= id_offset;
            ex_offset20 <= id_offset20;
            ex_rd       <= id_rd;
            ex_aluop    <= id_valid ? id_aluop : 4'b0;
            ex_regsel   <= id_valid ? id_regsel : 2'b0;
            ex_alusrcb  <= id_valid ? id_alusrcb : 2'b0;
            ex_wdsel    <= id_valid ? id_wdsel : 2'b0;
            ex_alusrca  <= id_valid && id_alusrca;
            ex_rfwrite  <= id_valid && id_rfwrite;
            ex_dmctrl   <= id_valid ? id_dmctrl : `DMCtrl_RD;
            ex_valid    <= id_valid;
            ex_branch   <= id_valid && id_branch;
            ex_npcop    <= id_valid ? id_npcop : `NPC_PC;
        end
    end
end

endmodule

module ExecuteMemoryRegisters(
    input         clk,
    input         rst,
    input         ready,
    input         kill,
    input  [31:0] ex_store_data,
    input  [31:0] ex_pca4,
    input  [31:0] ex_pc,
    input  [4:0]  ex_rd,
    input  [1:0]  ex_wdsel,
    input         ex_rfwrite,
    input         ex_dmctrl,
    input         ex_valid,

    output reg [31:0] mem_store_data,
    output reg [31:0] mem_pca4,
    output reg [31:0] mem_pc,
    output reg [4:0]  mem_rd,
    output reg [1:0]  mem_wdsel,
    output reg        mem_rfwrite,
    output reg        mem_dmctrl,
    output reg        mem_valid
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        mem_store_data <= 32'b0;
        mem_pca4       <= 32'b0;
        mem_pc         <= 32'b0;
        mem_rd         <= 5'b0;
        mem_wdsel      <= 2'b0;
        mem_rfwrite    <= 1'b0;
        mem_dmctrl     <= `DMCtrl_RD;
        mem_valid      <= 1'b0;
    end
    else if (ready) begin
        if (kill) begin
            mem_store_data <= 32'b0;
            mem_pca4       <= 32'b0;
            mem_pc         <= 32'b0;
            mem_rd         <= 5'b0;
            mem_wdsel      <= 2'b0;
            mem_rfwrite    <= 1'b0;
            mem_dmctrl     <= `DMCtrl_RD;
            mem_valid      <= 1'b0;
        end
        else begin
            mem_store_data <= ex_store_data;
            mem_pca4       <= ex_pca4;
            mem_pc         <= ex_pc;
            mem_rd         <= ex_rd;
            mem_wdsel      <= ex_valid ? ex_wdsel : 2'b0;
            mem_rfwrite    <= ex_valid && ex_rfwrite;
            mem_dmctrl     <= ex_valid ? ex_dmctrl : `DMCtrl_RD;
            mem_valid      <= ex_valid;
        end
    end
end

endmodule

module MemoryWritebackRegisters(
    input         clk,
    input         rst,
    input         ready,
    input         kill,
    input  [31:0] mem_writeback_data,
    input  [4:0]  mem_rd,
    input  [1:0]  mem_wdsel,
    input         mem_rfwrite,
    input         mem_valid,
    input         mem_dmread_stall,

    output reg [31:0] wb_data,
    output reg [4:0]  wb_rd,
    output reg        wb_rfwrite,
    output reg        wb_valid,
    output reg [4:0]  memstall_rd,
    output reg [1:0]  memstall_wdsel,
    output reg        memstall_rfwrite,
    output reg        memstall_valid
);

always @(posedge clk or posedge rst) begin
    if (rst) begin
        wb_data          <= 32'b0;
        wb_rd            <= 5'b0;
        wb_rfwrite       <= 1'b0;
        wb_valid         <= 1'b0;
        memstall_rd      <= 5'b0;
        memstall_wdsel   <= 2'b0;
        memstall_rfwrite <= 1'b0;
        memstall_valid   <= 1'b0;
    end
    else begin
        if (ready && !kill && mem_dmread_stall && mem_valid) begin
            memstall_rd      <= mem_rd;
            memstall_wdsel   <= mem_wdsel;
            memstall_rfwrite <= mem_rfwrite;
            memstall_valid   <= 1'b1;
        end
        else begin
            memstall_rd      <= 5'b0;
            memstall_wdsel   <= 2'b0;
            memstall_rfwrite <= 1'b0;
            memstall_valid   <= 1'b0;
        end

        if (!ready || kill || mem_dmread_stall) begin
            wb_data    <= 32'b0;
            wb_rd      <= 5'b0;
            wb_rfwrite <= 1'b0;
            wb_valid   <= 1'b0;
        end
        else if (memstall_valid) begin
            wb_data    <= mem_writeback_data;
            wb_rd      <= memstall_rd;
            wb_rfwrite <= memstall_rfwrite;
            wb_valid   <= 1'b1;
        end
        else begin
            wb_data    <= mem_writeback_data;
            wb_rd      <= mem_rd;
            wb_rfwrite <= mem_valid && mem_rfwrite;
            wb_valid   <= mem_valid;
        end
    end
end

endmodule
