`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ALU(A,B,ALUOp,zero,ALU_result);
    input signed [31:0] A;
    input signed [31:0] B;
    input [3:0] ALUOp;
    output zero;
    output reg signed [31:0] ALU_result;

// Branch compare is better driven by direct operand compare than ALU-result fanout.
assign zero = (A == B);

wire [4:0] SHAMT;
wire [31:0] B_ADDSUB;
wire [31:0] ADDSUB_RESULT;
wire [32:0] ADDSUB_EXT;
wire signed [31:0] LOGIC_RESULT;
wire signed [31:0] SHIFT_RESULT;
wire SUB_MODE;
wire ADDSUB_CO_UNUSED;

assign SHAMT = B[4:0];

// Keep the RTL arithmetic simple for simulation, and let synthesis map only
// the ALU add/sub datapath to a stronger implementation.
assign SUB_MODE = (ALUOp == `ALUOp_SUB);
assign B_ADDSUB = B ^ {32{SUB_MODE}};
`ifdef SYNTHESIS
DW01_add #(32) U_DW_ALU_ADDER (
    .A   (A),
    .B   (B_ADDSUB),
    .CI  (SUB_MODE),
    .SUM (ADDSUB_RESULT),
    .CO  (ADDSUB_CO_UNUSED)
);
`else
assign ADDSUB_EXT    = {1'b0, A} + {1'b0, B_ADDSUB} + {32'b0, SUB_MODE};
assign ADDSUB_RESULT = ADDSUB_EXT[31:0];
assign ADDSUB_CO_UNUSED = ADDSUB_EXT[32];
`endif

assign LOGIC_RESULT =
    (ALUOp == `ALUOp_AND) ? (A & B) :
    (ALUOp == `ALUOp_OR)  ? (A | B) :
    (ALUOp == `ALUOp_XOR) ? (A ^ B) :
    32'sb0;

assign SHIFT_RESULT =
    (ALUOp == `ALUOp_SRA) ? (A >>> SHAMT) :
    (ALUOp == `ALUOp_SLL) ? (A << SHAMT) :
    (ALUOp == `ALUOp_SRL) ? $signed($unsigned(A) >> SHAMT) :
    32'sb0;

always @(*) begin
    // synopsys parallel_case full_case
    case (ALUOp)
        `ALUOp_ADD,
        `ALUOp_SUB: ALU_result = $signed(ADDSUB_RESULT);
        `ALUOp_AND,
        `ALUOp_OR,
        `ALUOp_XOR: ALU_result = LOGIC_RESULT;
        `ALUOp_SRA,
        `ALUOp_SLL,
        `ALUOp_SRL: ALU_result = SHIFT_RESULT;
        default:    ALU_result = 32'sb0;
    endcase
end

endmodule
