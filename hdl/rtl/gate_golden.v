// ============================================================================
//  gate_golden.v  –  behavioural reference for reflex_kernel_gate
//  Mirrors exactly the integer logic used in Lean/Coq proof & SBY job
// ============================================================================

`timescale 1ns / 1ps

module gate_golden (
    input  wire [63:0] packed_const,
    input  wire [31:0] dt_us,      // micro-seconds ×100 (1e-6)
    input  wire [15:0] dphi_e4,    // radians ×1e-4
    input  wire [15:0] qsfs_e4,    // QSFS   ×1e-4
    output wire        trusted_sw  // behavioural truth value
);
    // -----------------------------------------------------------
    // Unpack identical bit-slices to DUT
    // -----------------------------------------------------------
    wire [27:0] pi_echo_i   = packed_const[55:32];
    wire [15:0] pi_t_i      = packed_const[31:16];
    wire [ 7:0] eps_phase_i = packed_const[15: 8];
    wire [ 7:0] eps_time_i  = packed_const[ 7: 0];

    // -----------------------------------------------------------
    // Pure-combinational trusted predicate
    // -----------------------------------------------------------
    wire timing_ok   = (dt_us  % pi_echo_i) <  eps_time_i;
    wire phase_ok    =  dphi_e4 <  eps_phase_i;
    wire fidelity_ok =  qsfs_e4 >= pi_t_i;

    assign trusted_sw = timing_ok & phase_ok & fidelity_ok;
endmodule

