module mux #(
    parameter int WIDTH = 9
)(
    input  logic [WIDTH-1:0] in0,
    input  logic [WIDTH-1:0] in1,
    input  logic             sel,
    output logic [WIDTH-1:0] y
);

    assign y = sel ? in1 : in0;

endmodule
