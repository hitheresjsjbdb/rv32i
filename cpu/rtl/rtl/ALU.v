`include "ctrl_signal_def.v"
`include "instruction_def.v"

module ALU(A,B,ALUOp,zero,ALU_result);
    input signed [31:0] A;
    input signed [31:0] B;
    input [3:0] ALUOp;
    output zero;
    output reg signed [31:0] ALU_result;

assign zero = (ALU_result == 32'b0);

wire ADD, SUB, AND, OR, XOR, SRA, SLL, SRL, BR;

assign ADD = (ALUOp == `ALUOp_ADD);
assign SUB = (ALUOp == `ALUOp_SUB);
assign AND = (ALUOp == `ALUOp_AND);
assign OR  = (ALUOp == `ALUOp_OR);
assign XOR = (ALUOp == `ALUOp_XOR);
assign SRA = (ALUOp == `ALUOp_SRA);
assign SLL = (ALUOp == `ALUOp_SLL);
assign SRL = (ALUOp == `ALUOp_SRL);
assign BR  = (ALUOp == `ALUOp_BR);

always @(*) begin
    // case (ALUOp)
    //     `ALUOp_ADD: ALU_result = A + B;
    //     `ALUOp_SUB: ALU_result = A - B;
    //     `ALUOp_AND: ALU_result = A & B;
    //     `ALUOp_OR : ALU_result = A | B;
    //     `ALUOp_XOR: ALU_result = A ^ B;
    //     `ALUOp_SRA: ALU_result = A >>> B[4:0];
    //     `ALUOp_SLL: ALU_result = A << B[4:0];
    //     `ALUOp_SRL: ALU_result = $unsigned(A) >> B[4:0];
    //     `ALUOp_BR : ALU_result = A - B;
    //     default   : ALU_result = 32'b0;
    // endcase
    ALU_result = ({32{ADD}} & (A + B)) |
                 ({32{SUB}} & (A - B)) |
                 ({32{AND}} & (A & B)) |
                 ({32{OR} } & (A | B)) |
                 ({32{XOR}} & (A ^ B)) |
                 ({32{SRA}} & (A >>> B[4:0])) |
                 ({32{SLL}} & (A << B[4:0])) |
                 ({32{SRL}} & ($unsigned(A) >> B[4:0]));
end

endmodule