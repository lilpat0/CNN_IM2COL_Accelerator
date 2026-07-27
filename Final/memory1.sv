module memory #(
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 12
) (
    input  logic                  clk,
    input  logic                  rst_n, 
    input  logic                  we,
    input  logic [ADDR_WIDTH-1:0] addr, 
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

    // Memory array declaration (4096 x DATA_WIDTH)
    logic [DATA_WIDTH-1:0] mem [0:(2**ADDR_WIDTH)-1];

    initial begin
        for (int i = 0; i < (2**ADDR_WIDTH); i++) begin
            mem[i] = '0;
        end
    end

    // Synchronous memory logic
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            dout <= '0;
        end else begin
            if (we) begin
                mem[addr] <= din;
            end else begin
                dout <= mem[addr]; 
            end
        end
    end

endmodule