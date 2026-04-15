module BPStats(
    input        clk,
    input        rst,
    input        branch_valid,
    input        branch_miss,
    input        report_valid
);

reg [63:0] total_branches;
reg [63:0] miss_branches;

wire [63:0] total_next;
wire [63:0] miss_next;
wire [63:0] hit_next;
wire [63:0] hit_rate_x100;

assign total_next = total_branches + (branch_valid ? 64'd1 : 64'd0);
assign miss_next = miss_branches + (branch_miss ? 64'd1 : 64'd0);
assign hit_next = total_next - miss_next;
assign hit_rate_x100 = (total_next != 64'd0) ? ((hit_next * 64'd10000) / total_next) : 64'd0;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        total_branches <= 64'd0;
        miss_branches <= 64'd0;
    end
    else begin
        total_branches <= total_next;
        miss_branches <= miss_next;

        if (report_valid) begin
            if (total_next == 64'd0) begin
                $display("[BP] total=0 miss=0 hit=0 hit_rate=0.00%%");
            end
            else begin
                $display("[BP] total=%0d miss=%0d hit=%0d hit_rate=%0d.%02d%%",
                         total_next,
                         miss_next,
                         hit_next,
                         hit_rate_x100 / 64'd100,
                         hit_rate_x100 % 64'd100);
            end
        end
    end
end

endmodule
