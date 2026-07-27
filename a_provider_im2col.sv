//=====================================================================
// a_provider_im2col   -- person A
//   The im2col layer. Answers "what is A[a_m][a_k]?" in one cycle.
//   Contains no FSM and no counters of its own.
//=====================================================================
module a_provider_im2col
  import cnn_pkg::*;
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
 
 
//=====================================================================
