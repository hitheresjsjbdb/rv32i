`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ALU(A,B,ALUOp,ALU_result);
    input signed [31:0] A;
    input signed [31:0] B;
    input [3:0] ALUOp;
    output reg signed [31:0] ALU_result;

wire [4:0] SHAMT;
wire [31:0] ADD_RESULT;
wire [31:0] SUB_RESULT;
wire signed [31:0] LOGIC_RESULT;
wire signed [31:0] SHIFT_RESULT;

assign SHAMT = B[4:0];

// Explicit prefix adders avoid the ripple implementation inferred for the
// DesignWare adders on the ALUOut critical path.
ALU_prefix_adder32 U_PREFIX_ADD (
    .A   (A),
    .B   (B),
    .CI  (1'b0),
    .SUM (ADD_RESULT)
);
ALU_prefix_adder32 U_PREFIX_SUB (
    .A   (A),
    .B   (~B),
    .CI  (1'b1),
    .SUM (SUB_RESULT)
);

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

// 32-bit Kogge-Stone-style prefix adder with carry input.  The carry network
// has five prefix stages rather than a bit-by-bit ripple chain.
module ALU_prefix_adder32(A, B, CI, SUM);
    input  [31:0] A;
    input  [31:0] B;
    input         CI;
    output [31:0] SUM;

    wire [31:0] p0;
    wire [31:0] g0;
    wire [31:0] p1, g1;
    wire [31:0] p2, g2;
    wire [31:0] p3, g3;
    wire [31:0] p4, g4;
    wire [31:0] p5, g5;
    wire [31:0] carry;

    assign p0 = A ^ B;
    assign g0 = A & B;

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : GEN_PREFIX
            if (i < 1) begin
                assign p1[i] = p0[i];
                assign g1[i] = g0[i];
            end else begin
                assign p1[i] = p0[i] & p0[i-1];
                assign g1[i] = g0[i] | (p0[i] & g0[i-1]);
            end

            if (i < 2) begin
                assign p2[i] = p1[i];
                assign g2[i] = g1[i];
            end else begin
                assign p2[i] = p1[i] & p1[i-2];
                assign g2[i] = g1[i] | (p1[i] & g1[i-2]);
            end

            if (i < 4) begin
                assign p3[i] = p2[i];
                assign g3[i] = g2[i];
            end else begin
                assign p3[i] = p2[i] & p2[i-4];
                assign g3[i] = g2[i] | (p2[i] & g2[i-4]);
            end

            if (i < 8) begin
                assign p4[i] = p3[i];
                assign g4[i] = g3[i];
            end else begin
                assign p4[i] = p3[i] & p3[i-8];
                assign g4[i] = g3[i] | (p3[i] & g3[i-8]);
            end

            if (i < 16) begin
                assign p5[i] = p4[i];
                assign g5[i] = g4[i];
            end else begin
                assign p5[i] = p4[i] & p4[i-16];
                assign g5[i] = g4[i] | (p4[i] & g4[i-16]);
            end
        end

        for (i = 0; i < 32; i = i + 1) begin : GEN_SUM
            if (i == 0) begin
                assign carry[i] = CI;
            end else begin
                assign carry[i] = g5[i-1] | (p5[i-1] & CI);
            end
            assign SUM[i] = p0[i] ^ carry[i];
        end
    endgenerate
endmodule
