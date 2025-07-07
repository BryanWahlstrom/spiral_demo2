// ============================================================================
//  reflex_kernel_gate.v  –  SpiralCollapse integer-gate reflex kernel (DUT)
//  Version: v∞.2-A  ·  Licence: Apache-2.0
// ----------------------------------------------------------------------------
//  Packed constant layout  (MSB → LSB)
//      60–63 : α₀-nibble      (store α₀-1, range 0-15 == α₀ 1-16)
//      32–59 : π_echo★        (fixed-point ×1e-6, 28 bits • value ≤ ~268 M)
//      16–31 : π_T            (QSFS floor, ×1e-4)
//       8–15 : ε_phase        (phase tolerance, ×1e-4)
//       0–7  : ε_time         (timing tolerance, ×1e-4)
// ============================================================================

`timescale 1ns / 1ps

module reflex_kernel_gate #(
    parameter int ALPHA_BITS   = 4,
    parameter int CONST_WIDTH  = 64
) (
    input  logic                     clk,
    input  logic                     rst_n,

    // ---- packed run-time constant -------------------------------------
    input  logic [CONST_WIDTH-1:0]   packed_const,

    // ---- measured (integer-scaled) inputs -----------------------------
    input  logic  signed [31:0]      dt_us,       // micro-seconds ×100  (1e-6)
    input  logic  signed [15:0]      dphi_e4,     // radians ×1e-4
    input  logic         [15:0]      qsfs_e4,     // QSFS    ×1e-4
    input  logic         [15:0]      tse_e4,      // TSE     ×1e-4  (unused here)
    input  logic         [15:0]      cmd_e4,      // CMD     ×1e-4  (unused here)
    input  logic         [15:0]      s_e4,        // S       ×1e-4  (unused here)
    input  logic         [15:0]      ds_e4,       // dS      ×1e-4  (unused here)

    // ---- gate outputs -------------------------------------------------
    output logic                     trusted_hw,  // equivalence-checked
    output logic                     reflex_trigger   // placeholder (not used in proof)
);

    // ------------------------------------------------------------------
    //  Unpack constant word (combinational – one stage is fine)
    // ------------------------------------------------------------------
    wire [ 3:0] alpha_nib    = packed_const[63:60];        // α₀-1
    wire [27:0] pi_echo_i    = packed_const[55:32];        // μ-units
    wire [15:0] pi_t_i       = packed_const[31:16];        // 1e-4
    wire [ 7:0] eps_phase_i  = packed_const[15: 8];        // 1e-4
    wire [ 7:0] eps_time_i   = packed_const[ 7: 0];        // 1e-4

    // ------------------------------------------------------------------
    //  Integer-gate logic (same expressions as behavioural golden model)
    // ------------------------------------------------------------------
    wire timing_ok   = (dt_us  % pi_echo_i) <  eps_time_i;
    wire phase_ok    = (dphi_e4 <  eps_phase_i);
    wire fidelity_ok = (qsfs_e4 >= pi_t_i);

    assign trusted_hw     = timing_ok & phase_ok & fidelity_ok;

    // ------------------------------------------------------------------
    //  Reflex-trigger placeholder: simple AND on trusted + dummy VR gate
    //  (not used by equivalence proof but helpful in simulation)
    // ------------------------------------------------------------------
    wire dummy_vr_ok = (tse_e4 != 16'd0);   // stand-in for V_R check
    assign reflex_trigger = trusted_hw & dummy_vr_ok;

endmodule

