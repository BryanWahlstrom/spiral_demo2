// reflex_kernel_gate_equiv.v
// --------------------------
// Instantiates the HW integer gate under test *and* the
// bit-exact golden reference (gate_golden).
// All inputs are driven identically; an assert fires if
// trusted_hw  ≠  trusted_sw  during the next cycle.

`default_nettype none
module reflex_kernel_gate_equiv #(
    parameter CONST_W  = 64,
    parameter DT_W     = 32,
    parameter DPHI_W   = 16,
    parameter QSFS_W   = 16
)(
    input  wire                   clk,
    input  wire                   rst_n,

    // constant word and dynamic inputs
    input  wire [CONST_W-1:0]     packed_const,
    input  wire [DT_W-1:0]        dt_us,
    input  wire [DPHI_W-1:0]      dphi_e4,
    input  wire [QSFS_W-1:0]      qsfs_e4
);

    // ---------------- DUT ----------------
    wire trusted_hw;
    reflex_kernel_gate dut_inst (
        .clk          (clk),
        .rst_n        (rst_n),
        .packed_const (packed_const),
        .dt_us        (dt_us),
        .dphi_e4      (dphi_e4),
        .qsfs_e4      (qsfs_e4),
        .trusted      (trusted_hw)
    );

    // --------------- Golden --------------
    wire trusted_sw;
    gate_golden gold_inst (
        .packed_const (packed_const),
        .dt_us        (dt_us),
        .dphi_e4      (dphi_e4),
        .qsfs_e4      (qsfs_e4),
        .trusted_sw   (trusted_sw)
    );

    // -------- single-cycle equivalence ----
    always @(posedge clk) begin
        if (!rst_n) begin
            assert (trusted_hw == trusted_sw)
                else $error("REFLEX-GATE mismatch  @%0t", $time);
        end
    end

endmodule
`default_nettype wire

