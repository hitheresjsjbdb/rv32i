`include "ctrl_signal_def.v"

module EXT(imm_in, ExtSel, imm_out);
    input  [11:0] imm_in;
    input         ExtSel;
    output reg [31:0] imm_out;

    always @(imm_in or ExtSel) begin
        case(ExtSel)
            `ExtSel_ZERO  : imm_out = {20'b0, imm_in[11:0]};
            `ExtSel_SIGNED: imm_out = (imm_in[11]) ? {20'hfffff, imm_in[11:0]} : {20'h00000, imm_in[11:0]};
            default       : imm_out = 32'b0;
        endcase
    end

endmodule