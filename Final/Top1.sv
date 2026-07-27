module top (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic [5:0]  a_m,
    input  logic [3:0]  a_k,
    input  logic [11:0] weight_addr_in,

    output logic        busy,
    output logic        done,
    output logic signed [31:0] mac_out_val
);

    import system_params::*; 

    logic run_mm, run_process;
    logic mmm_done, process_done;

    logic signed [DATA_W-1:0] a_data;
    logic signed [DATA_W-1:0] weight_dout;
    logic signed [ACC_W-1:0]  mac_out;

    logic [11:0] weight_addr;
    
    // Pulse clear_acc when K=0 data arrives from memory (1 cycle delay)
    logic clear_acc_q;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            clear_acc_q <= 1'b0;
        else
            clear_acc_q <= (a_k == 4'd0) && run_mm;
    end

    assign weight_addr = weight_addr_in;
    assign mac_out_val = mac_out;

    // FSM Controller
    fsm u_fsm (
        .clk          (clk),
        .rst_n        (rst_n),
        .start        (start),
        .mmm_done     (mmm_done),
        .process_done (process_done),
        .busy         (busy),
        .done         (done),
        .run_mm       (run_mm),
        .run_process  (run_process)
    );

    // IM2COL Provider
    a_provider_im2col u_im2col (
        .clk       (clk),
        .rst_n     (rst_n),
        .a_m       (a_m),
        .a_k       (a_k),
        .a_data    (a_data),
        .load_we   (1'b0),
        .load_addr ({IF_AW{1'b0}}),
        .load_data ({DATA_W{1'b0}})
    );

    // MAC Unit
    mac_unit #(
        .DW    (DATA_W),
        .ACC_W (ACC_W)
    ) u_mac_unit (
        .clk       (clk),
        .rst_n     (rst_n),
        .a         (a_data),
        .b         (weight_dout),
        .valid_in  (run_mm),
        .clear_acc (clear_acc_q),
        .acc_out   (mac_out),
        .valid_out ()
    );

    memory #(
        .DATA_WIDTH(DATA_W),
        .ADDR_WIDTH(12)
    ) u_weight_mem (
        .clk   (clk),
        .rst_n (rst_n), 
        .we    (1'b0),
        .addr  (weight_addr),
        .din   (8'd0),
        .dout  (weight_dout)
    );

    assign mmm_done     = 1'b0;
    assign process_done = 1'b0;

endmodule
