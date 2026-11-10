module comparator #(
    parameter int         WIDTH      = 5,
    parameter logic [4:0] GOLDEN_SIG = 5'b10001
)(
    input  logic [WIDTH-1:0] signature,
    output logic             pass_out
);

    assign pass_out = (signature == GOLDEN_SIG);

endmodule
