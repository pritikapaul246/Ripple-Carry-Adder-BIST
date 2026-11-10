module misr #(
    parameter int         WIDTH = 5,
    parameter logic [4:0] POLY  = 5'b1_0011
)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             capture,
    input  logic [WIDTH-1:0] data_in,
    output logic [WIDTH-1:0] signature
);

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            signature <= '0;
        end else if (capture) begin
            signature[4] <= signature[3]                ^ data_in[4];
            signature[3] <= signature[2]                ^ data_in[3];
            signature[2] <= signature[1] ^ signature[4] ^ data_in[2];
            signature[1] <= signature[0]                ^ data_in[1];
            signature[0] <= signature[4]                ^ data_in[0];
        end
    end

endmodule
