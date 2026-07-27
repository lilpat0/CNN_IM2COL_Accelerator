module MAC #(
    parameter DATA_WIDTH = 8,
    parameter ACC_WIDTH = 20,
    parameter ADDR_WIDTH = 12
        )(input logic clk, input logic rst, input logic valid, input logic last_tap, input logic [DATA_WIDTH -1: 0] img_data,
                input logic [DATA_WIDTH -1: 0] wt_data, input logic [ADDR_WIDTH -1: 0] out_addr, output logic [ACC_WIDTH -1: 0] result,
                    output logic result_valid, output logic [ADDR_WIDTH -1: 0] result_addr);
    
    logic [ACC_WIDTH -1: 0] acc;

    always_ff @(posedge clk) begin
        if (!rst) begin
            acc          <= '0; // '0 means fill everything with a 0
            result       <= '0;
            result_valid <= 1'b0;
            result_addr  <= '0;

        end else begin
            result_valid <= 1'b0;

            if (valid) begin
                acc <= acc + (img_data * wt_data); //wt = weights
                
                if (last_tap) begin
                    result       <= acc + (img_data * wt_data);
                    result_valid <= 1'b1;
                    result_addr  <= out_addr;
                    acc          <= 0;
                    
                end
            
            end

        end

    end



endmodule