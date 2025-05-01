module alu_1bit (
    output logic result,
    output logic carry_out,
    input  logic a,
    input  logic b,
    input  logic carry_in,
    input  logic less,
    input  logic [1:0] alu_control
);

    logic addsub_out;
    logic xor_out;
    logic xor_less_out;

    addsub_1bit add_sub_unit (
        .out   (addsub_out),
        .carry_out (carry_out),
        .a     (a),
        .b     (b),
        .carry_in(carry_in),
        .select(alu_control[1])
    );

    xor #(50) xor_gate(xor_out, a, b);

    mux2_1 #(1) mux_xor_less (
        .o   (xor_less_out),
        .a   (xor_out),
        .b   (less),
        .sel (alu_control[1])
    );

    mux2_1 #(1) mux_result (
        .o   (result),
        .a   (addsub_out),
        .b   (xor_less_out),
        .sel (alu_control[0])
    );

endmodule
