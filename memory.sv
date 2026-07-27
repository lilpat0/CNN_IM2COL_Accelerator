module memory #(
                parameter DATA_WIDTH = 8,
                parameter ADDR_WIDTH = 12
            )
    (input logic clk, input logic rst, input logic we, input logic [ADDR_WIDTH-1:0]addr, 
        input logic [DATA_WIDTH-1:0] din, output logic [DATA_WIDTH-1:0] dout);

    logic [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1]; //create a 


    always_ff @(posedge clk) begin
        if(!rst) begin
            dout <= {DATA_WIDTH{1'b0}}; //sets to 0

            for (int i = 0; i < 2**ADDR_WIDTH; i++) begin
                mem[i] = 0;
            end

        end else begin
            if(we) begin
                mem[addr] <= din;
            end else begin
                dout <= mem[addr]; //synchronous read
            end
        end
    end
endmodule