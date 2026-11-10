module rca #(
    parameter bit        INJECT_FAULT = 1'b0,
    parameter int        FAULT_BIT    = 0,
    parameter logic      FAULT_VAL    = 1'b0
)(
    input  logic [3:0] a,
    input  logic [3:0] b,
    input  logic       cin,
    output logic [3:0] sum,
    output logic       cout
);

    logic [4:0] result;

    assign result = {1'b0, a} + {1'b0, b} + {4'b0, cin};
    assign cout   = result[4];

    generate
        genvar i;
        for (i = 0; i < 4; i++) begin : gen_sum
            if (INJECT_FAULT && (i == FAULT_BIT))
                assign sum[i] = FAULT_VAL;
            else
                assign sum[i] = result[i];
        end
    endgenerate

endmodule
