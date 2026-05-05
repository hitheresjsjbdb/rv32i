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
wire [31:0] ADD_RESULT;
wire [31:0] SUB_RESULT;
wire [32:0] ADD_EXT;
wire [32:0] SUB_EXT;
wire signed [31:0] LOGIC_RESULT;
wire signed [31:0] SHIFT_RESULT;
wire ADD_CO_UNUSED;
wire SUB_CO_UNUSED;

assign SHAMT = B[4:0];

// Cut the ALUOp -> adder critical path by computing add and sub in parallel.
// ALUOp then only selects between already-computed results.
`ifdef SYNTHESIS
DW01_add #(32) U_DW_ALU_ADD (
    .A   (A),
    .B   (B),
    .CI  (1'b0),
    .SUM (ADD_RESULT),
    .CO  (ADD_CO_UNUSED)
);
DW01_add #(32) U_DW_ALU_SUB (
    .A   (A),
    .B   (~B),
    .CI  (1'b1),
    .SUM (SUB_RESULT),
    .CO  (SUB_CO_UNUSED)
);
`else
assign ADD_EXT       = {1'b0, A} + {1'b0, B};
assign SUB_EXT       = {1'b0, A} + {1'b0, ~B} + 33'b1;
assign ADD_RESULT    = ADD_EXT[31:0];
assign SUB_RESULT    = SUB_EXT[31:0];
assign ADD_CO_UNUSED = ADD_EXT[32];
assign SUB_CO_UNUSED = SUB_EXT[32];
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
        `ALUOp_ADD: ALU_result = $signed(ADD_RESULT);
        `ALUOp_SUB: ALU_result = $signed(SUB_RESULT);
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
