module adder_32bit (
    output logic [31:0] sum,
    input  logic [31:0] a,
    input  logic [31:0] b
);

    logic [31:0] carry;

    // Instantiate 32 instances of the 1-bit adder
    adder_1bit adder_bit [31:0] (
        .sum(sum),
        .cout(carry[31:0]),
        .a(a),
        .b(b),
        .cin({carry[30:0], 1'b0}) // Connect carry-out of previous stage to carry-in of current stage
    );

endmodule
