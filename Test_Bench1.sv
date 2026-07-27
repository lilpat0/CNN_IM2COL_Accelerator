`timescale 1ns/1ps

module Test_Bench;

    import system_params::*;

    logic clk;
    logic rst_n;
    logic start;

    logic [5:0]  a_m;
    logic [3:0]  a_k;
    logic [11:0] weight_addr;

    logic busy;
    logic done;
    logic signed [ACC_W-1:0] mac_out_val;

    always #5 clk = ~clk;

    top u_top (
        .clk            (clk),
        .rst_n          (rst_n),
        .start          (start),
        .a_m            (a_m),
        .a_k            (a_k),
        .weight_addr_in (weight_addr),
        .busy           (busy),
        .done           (done),
        .mac_out_val    (mac_out_val)
    );

    logic signed [7:0] test_ifmap [0:63];
    logic signed [7:0] test_weights [0:8];
    logic signed [31:0] expected_out [0:35];

    int err_count;
    int i, k, mr, mc, kr, kc;
    int m_idx, r, c, k_idx;

    initial begin
        $dumpfile("simulation/tb_top.vcd");
        $dumpvars(0, Test_Bench);

        clk         = 0;
        rst_n       = 0;
        start       = 0;
        a_m         = 0;
        a_k         = 0;
        weight_addr = 0;
        err_count   = 0;

        $display("\n==================================================");
        $display("   Starting CNN IM2COL Accelerator Testbench");
        $display("==================================================\n");

        for (i = 0; i < 64; i = i + 1) begin
            test_ifmap[i] = i + 1;
            u_top.u_im2col.ifmap_mem[i] = test_ifmap[i];
        end

        for (k = 0; k < 9; k = k + 1) begin
            test_weights[k] = 8'sd1;
            u_top.u_weight_mem.mem[k] = test_weights[k];
        end

        for (mr = 0; mr < 6; mr = mr + 1) begin
            for (mc = 0; mc < 6; mc = mc + 1) begin
                m_idx = mr * 6 + mc;
                expected_out[m_idx] = 0;
                for (kr = 0; kr < 3; kr = kr + 1) begin
                    for (kc = 0; kc < 3; kc = kc + 1) begin
                        r = mr + kr;
                        c = mc + kc;
                        k_idx = kr * 3 + kc;
                        expected_out[m_idx] = expected_out[m_idx] + (test_ifmap[r * 8 + c] * test_weights[k_idx]);
                    end
                end
            end
        end

        #20;
        rst_n = 1;
        #20;

        $display("[%0t ns] Asserting START...", $time);
        start = 1;
        #10;
        start = 0;

        wait(u_top.run_mm == 1'b1);
        $display("[%0t ns] FSM Active: Matrix Multiplication Started\n", $time);

        @(posedge clk);
        #1;
        a_m = 0;

        // Drive inputs K=0 to 8, one value per cycle. Stimulus changes just
        // after the edge so the DUT samples the value held across the edge.
        for (k = 0; k < 9; k = k + 1) begin
            a_k         = k[3:0];
            weight_addr = k[11:0];
            @(posedge clk);
            #1;
        end

        // One more cycle for the final K=8 product to accumulate
        @(posedge clk);
        #1;

        $display("==================================================");
        $display("   Checking First Output Window Result");
        $display("==================================================");
        $display("Expected First Output Pixel Sum : %0d", expected_out[0]);
        $display("Actual MAC Accumulator Output   : %0d", mac_out_val);

        if (mac_out_val == expected_out[0]) begin
            $display(">>> SUCCESS: First output pixel matches golden reference!");
        end else begin
            $display(">>> ERROR: Mismatch! Expected %0d, got %0d", expected_out[0], mac_out_val);
            err_count = err_count + 1;
        end

        #50;
        $display("\n==================================================");
        if (err_count == 0)
            $display("   TEST PASSED SUCCESSFULLY!");
        else
            $display("   TEST FAILED WITH %0d ERRORS!", err_count);
        $display("==================================================\n");

        $finish;
    end

endmodule
