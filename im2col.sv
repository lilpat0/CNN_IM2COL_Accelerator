//=====================================================================
// a_provider_im2col   -- person A
//   The im2col layer. Answers "what is A[a_m][a_k]?" in one cycle.
//   Contains no FSM and no counters of its own.
//=====================================================================
module a_provider_im2col
  import system_params.sv::*;
(
  input  logic                     clk,
  input  logic                     rst_n,
 
  // query seam from cnn_top (a_m already includes the tile base)
  input  logic [MW-1:0]            a_m,
  input  logic [KW-1:0]            a_k,
  output logic signed [DATA_W-1:0] a_data,   // CONTRACT: valid exactly
                                             // 1 cycle after a_m/a_k
 
  // load port - real ports, never hierarchical TB access
  input  logic                     load_we,
  input  logic [IF_AW-1:0]         load_addr,
  input  logic signed [DATA_W-1:0] load_data
);
 
  logic [2:0]              mr, mc;      // 0..5, radix-6 decode of a_m
  logic [1:0]              kr, kc;      // 0..2, radix-3 decode of a_k
  logic [2:0]              row, col;    // 0..7, exactly 3 bits each
  logic [IF_AW-1:0]        ifmap_addr;
  logic                    a_valid;
  logic                    a_valid_q;
  logic signed [DATA_W-1:0] ifmap_rdata;
 
  logic signed [DATA_W-1:0] ifmap_mem [0:H*W-1];   // 64 x INT8
 
  // -----------------------------------------------------------------
  // TODO (A-1): radix-6 decode of a_m -> {mr, mc}
  //   36-entry case. Generate it, don't hand-type it.
  //   default arm covers the padded region 36..47.
  // -----------------------------------------------------------------
 function automatic logic [5:0] dec6(input logic [5:0] lin);
    case (lin)
      6'd0 : dec6 = {3'd0, 3'd0};
      6'd1 : dec6 = {3'd0, 3'd1};
      6'd2 : dec6 = {3'd0, 3'd2};
      6'd3 : dec6 = {3'd0, 3'd3};
      6'd4 : dec6 = {3'd0, 3'd4};
      6'd5 : dec6 = {3'd0, 3'd5};
      6'd6 : dec6 = {3'd1, 3'd0};
      6'd7 : dec6 = {3'd1, 3'd1};
      6'd8 : dec6 = {3'd1, 3'd2};
      6'd9 : dec6 = {3'd1, 3'd3};
      6'd10: dec6 = {3'd1, 3'd4};
      6'd11: dec6 = {3'd1, 3'd5};
      6'd12: dec6 = {3'd2, 3'd0};
      6'd13: dec6 = {3'd2, 3'd1};
      6'd14: dec6 = {3'd2, 3'd2};
      6'd15: dec6 = {3'd2, 3'd3};
      6'd16: dec6 = {3'd2, 3'd4};
      6'd17: dec6 = {3'd2, 3'd5};
      6'd18: dec6 = {3'd3, 3'd0};
      6'd19: dec6 = {3'd3, 3'd1};
      6'd20: dec6 = {3'd3, 3'd2};
      6'd21: dec6 = {3'd3, 3'd3};
      6'd22: dec6 = {3'd3, 3'd4};
      6'd23: dec6 = {3'd3, 3'd5};
      6'd24: dec6 = {3'd4, 3'd0};
      6'd25: dec6 = {3'd4, 3'd1};
      6'd26: dec6 = {3'd4, 3'd2};
      6'd27: dec6 = {3'd4, 3'd3};
      6'd28: dec6 = {3'd4, 3'd4};
      6'd29: dec6 = {3'd4, 3'd5};
      6'd30: dec6 = {3'd5, 3'd0};
      6'd31: dec6 = {3'd5, 3'd1};
      6'd32: dec6 = {3'd5, 3'd2};
      6'd33: dec6 = {3'd5, 3'd3};
      6'd34: dec6 = {3'd5, 3'd4};
      6'd35: dec6 = {3'd5, 3'd5};
      default: dec6 = {3'd0, 3'd0};
    endcase
  endfunction
 

  // -----------------------------------------------------------------
  // TODO (A-2): radix-3 decode of a_k -> {kr, kc}
  //   9-entry case, default {2'd0, 2'd0}.
  //   NOTE: this is a DIFFERENT function from A-1. Two decoders.
  // -----------------------------------------------------------------
 
  // -----------------------------------------------------------------
  // TODO (A-3): address math and range check, both combinational.
  //   row = mr + kr;  col = mc + kc;   (no carry possible, 3 bits)
  //   ifmap_addr = {row, col};          (W=8, so row*8 is free)
  //   a_valid    = (a_m < M) && (a_k < K);
  // -----------------------------------------------------------------
 
  // -----------------------------------------------------------------
  // TODO (A-4): single always_ff holding
  //   - load write:  if (load_we) ifmap_mem[load_addr] <= load_data;
  //   - datapath read (REGISTERED): ifmap_rdata <= ifmap_mem[ifmap_addr];
  //   - the validity pipeline:      a_valid_q   <= a_valid;
  //   rst_n clears a_valid_q ONLY. Never reset the array.
  // -----------------------------------------------------------------
 
  // -----------------------------------------------------------------
  // TODO (A-5): output mux
  //   a_data = a_valid_q ? ifmap_rdata : '0;
  //   Must use a_valid_q, not a_valid.
  // -----------------------------------------------------------------
 
endmodule
 
