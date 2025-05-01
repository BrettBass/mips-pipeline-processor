module addsub_1bit (
    output logic out,
    output logic carry_out,
    input  logic a,
    input  logic b,
    input  logic carry_in,
    input  logic select
);

    logic not_b;
    logic b_in;

    not #(50) not_b_gate(not_b, b);
    mux2_1 #(1) mux_b (
        .o   (b_in),
        .a   (b),
        .b   (not_b),
        .sel (select)
    );

    adder_1bit adder_unit (
        .sum   (out),
        .cout  (carry_out),
        .a     (a),
        .b     (b_in),
        .cin   (carry_in)
    );

endmodule
