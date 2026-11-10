module test_controller #(
    parameter int TEST_LEN = 511
)(
    input  logic clk,
    input  logic rst_n,
    input  logic bist_en,

    output logic lfsr_en,
    output logic mux_sel,
    output logic misr_capture,
    output logic latch_sig,
    output logic bist_active
);

    typedef enum logic [2:0] {
        IDLE    = 3'b000,
        TEST    = 3'b001,
        LATCH   = 3'b010,
        COMPARE = 3'b011,
        DONE    = 3'b100
    } state_t;

    state_t state, next_state;

    localparam int CNT_W = $clog2(TEST_LEN + 1);
    logic [CNT_W-1:0] count;

    always_ff @(posedge clk) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end

    always_ff @(posedge clk) begin
        if (!rst_n)
            count <= '0;
        else if (state == TEST)
            count <= count + 1;
        else
            count <= '0;
    end

    always_comb begin
        unique case (state)
            IDLE:    next_state = bist_en ? TEST : IDLE;
            TEST:    next_state = (count == CNT_W'(TEST_LEN - 1)) ? LATCH : TEST;
            LATCH:   next_state = COMPARE;
            COMPARE: next_state = DONE;
            DONE:    next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            lfsr_en      <= 1'b0;
            mux_sel      <= 1'b0;
            misr_capture <= 1'b0;
            latch_sig    <= 1'b0;
            bist_active  <= 1'b0;
        end else begin
            lfsr_en      <= (next_state == TEST);
            mux_sel      <= (next_state == TEST);
            misr_capture <= (next_state == TEST) || (next_state == LATCH);
            latch_sig    <= (next_state == COMPARE) || (next_state == DONE);
            bist_active  <= (next_state != IDLE);
        end
    end

endmodule
