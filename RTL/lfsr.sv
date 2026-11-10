module lfsr #(
    parameter int         WIDTH = 9,
    parameter logic [8:0] SEED  = 9'b1_0000_0001
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    output logic [WIDTH-1:0] q
);

    always_ff @(posedge clk) begin
        if (!rst_n)
            q <= SEED;
        else if (en)
            q <= {q[7:0], q[8] ^ q[3]};
    end

endmodule
