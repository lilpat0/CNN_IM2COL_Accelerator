module mac_unit #(
    parameter DW = 8,
    parameter ACC_W = 32
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic signed [DW-1:0]  a,
    input  logic signed [DW-1:0]  b,
    input  logic              valid_in,
    input  logic              clear_acc,

    output logic signed [ACC_W-1:0] acc_out,
    output logic              valid_out
);

    logic signed [2*DW-1:0] mult_res;

    assign mult_res = a * b;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            acc_out   <= '0;
            valid_out <= 1'b0;
        end else if (clear_acc) begin
            // On clear/new window: load the first product directly
            acc_out   <= mult_res;
            valid_out <= valid_in;
        end else if (valid_in) begin
            // Accumulate subsequent products
            acc_out   <= acc_out + mult_res;
            valid_out <= 1'b1;
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule
