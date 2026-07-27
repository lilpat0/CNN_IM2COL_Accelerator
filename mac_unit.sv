//This is just the preliminary
//I believe this is Aryan's mac unit, if it is, pls elaborate

module mac_unit #(
    parameter int DW = 8,
    parameter int ACC_W = 32
) (
    input logic clk,
    input logic rst_n,

    input logic signed [DW-1:0] a,
    input logic signed [DW-1:0] b,
    input logic valid_in,
    input logic clear_acc,

    output logic signed [ACC_W-1:0] acc_out,
    output logic valid_out
);

    logic signed [(2*DW)-1:0] product_stage1;
    logic valid_stage1;
    logic clear_stage1;

    logic signed [ACC_W-1:0] accumulator;

    assign acc_out = accumulator;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            
            product_stage1 <= '0;
	    valid_stage1 <= 1'b0;
	    clear_stage1 <= 1'b0;
	    accumulator <= '0;
	    valid_out <= 1'b0;

        end else begin
            

	    product_stage1 <= a*b;
	    valid_stage1 <= valid_in;
	    clear_stage1 <= clear_acc;

            
	    valid_out <= valid_stage1;
	    if (valid_stage1) begin
		if (clear_stage1) begin
			accumulator <= product_stage1;
		end
		else begin
		    accumulator <= accumulator + product_stage1;
		end
	    end
        end
    end

endmodule

