`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ALU(A, B, ALUOp, zero, ALU_result, use_pipe, ALUOp_pipe);
    input signed [31:0] A;
    input signed [31:0] B;
    input [3:0] ALUOp;
    input use_pipe;
    input [3:0] ALUOp_pipe;
    output zero;
    output reg signed [31:0] ALU_result;
    wire use_pipe_en;
    wire [3:0] alu_op_sel;

// Branch compare is better driven by direct operand compare than ALU-result fanout.
assign zero = (A == B);
assign use_pipe_en = (use_pipe === 1'b1);
assign alu_op_sel = use_pipe_en ? ALUOp_pipe : ALUOp;

wire [4:0] SHAMT;
wire [31:0] B_ADDSUB;
wire signed [31:0] ADD_RESULT;
wire signed [31:0] SUB_RESULT;
wire signed [31:0] LOGIC_RESULT;
wire signed [31:0] SHIFT_RESULT;
wire SUB_MODE;

assign SHAMT = B[4:0];

// Share one add/sub datapath: A + (B xor sub_mask) + cin.
assign SUB_MODE = (alu_op_sel == `ALUOp_SUB);
assign B_ADDSUB = B ^ {32{SUB_MODE}};
assign ADD_RESULT = A + B;
assign SUB_RESULT = $signed($unsigned(A) + $unsigned(B_ADDSUB) + {31'b0, SUB_MODE});

assign LOGIC_RESULT =
    (alu_op_sel == `ALUOp_AND) ? (A & B) :
    (alu_op_sel == `ALUOp_OR)  ? (A | B) :
    (alu_op_sel == `ALUOp_XOR) ? (A ^ B) :
    32'sb0;

assign SHIFT_RESULT =
    (alu_op_sel == `ALUOp_SRA) ? (A >>> SHAMT) :
    (alu_op_sel == `ALUOp_SLL) ? (A << SHAMT) :
    (alu_op_sel == `ALUOp_SRL) ? $signed($unsigned(A) >> SHAMT) :
    32'sb0;

always @(*) begin
    // synopsys parallel_case full_case
    case (alu_op_sel)
        `ALUOp_ADD: ALU_result = ADD_RESULT;
        `ALUOp_SUB: ALU_result = SUB_RESULT;
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
