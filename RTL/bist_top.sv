module bist_top #(
    parameter logic [4:0] GOLDEN_SIG   = 5'b10001,
    parameter bit         INJECT_FAULT = 1'b0,
    parameter int         FAULT_BIT    = 0,
    parameter logic       FAULT_VAL    = 1'b0
)(
    input  logic       clk,
    input  logic       rst_n,
    input  logic       bist_en,

    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,

    output logic [3:0] sum,
    output logic       cout,

    output logic       bist_active,
    output logic       pass_out
);

    logic       lfsr_en, mux_sel, misr_capture, latch_sig;
    logic [8:0] lfsr_pattern;
    logic [8:0] cut_in;
    logic [3:0] cut_a, cut_b;
    logic       cut_cin;
    logic [3:0] cut_sum;
    logic       cut_cout;
    logic [4:0] misr_sig;
    logic       pass_comb;

    test_controller #(
        .TEST_LEN (511)
    ) u_ctrl (
        .clk         (clk),
        .rst_n       (rst_n),
        .bist_en     (bist_en),
        .lfsr_en     (lfsr_en),
        .mux_sel     (mux_sel),
        .misr_capture(misr_capture),
        .latch_sig   (latch_sig),
        .bist_active (bist_active)
    );

    lfsr #(
        .WIDTH (9),
        .SEED  (9'b1_0000_0001)
    ) u_lfsr (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (lfsr_en),
        .q     (lfsr_pattern)
    );

    mux #(
        .WIDTH (9)
    ) u_mux (
        .in0 ({a, b, cin}),
        .in1 (lfsr_pattern),
        .sel (mux_sel),
        .y   (cut_in)
    );

    assign {cut_a, cut_b, cut_cin} = cut_in;

    rca #(
        .INJECT_FAULT (INJECT_FAULT),
        .FAULT_BIT    (FAULT_BIT),
        .FAULT_VAL    (FAULT_VAL)
    ) u_rca (
        .a   (cut_a),
        .b   (cut_b),
        .cin (cut_cin),
        .sum (cut_sum),
        .cout(cut_cout)
    );

    misr #(
        .WIDTH (5)
    ) u_misr (
        .clk      (clk),
        .rst_n    (rst_n),
        .capture  (misr_capture),
        .data_in  ({cut_cout, cut_sum}),
        .signature(misr_sig)
    );

    comparator #(
        .WIDTH      (5),
        .GOLDEN_SIG (GOLDEN_SIG)
    ) u_cmp (
        .signature(misr_sig),
        .pass_out (pass_comb)
    );

    always_ff @(posedge clk) begin
        if (!rst_n)
            pass_out <= 1'b0;
        else if (latch_sig)
            pass_out <= pass_comb;
    end

    assign sum  = bist_active ? 4'bz : cut_sum;
    assign cout = bist_active ? 1'bz : cut_cout;

endmodule
