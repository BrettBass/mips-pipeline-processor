module alu_32bit (
    output logic carry_out,
    output logic overflow,
    output logic negative,
    output logic zero,
    output logic [31:0] output,
    input  logic [31:0] buss_a,
    input  logic [31:0] buss_b,
    input  logic [1:0]  alu_control
);

    logic less_than;
    logic [31:0] carry_ripple;
    logic not_carry_out_31;
    logic addsub31_out;
    logic [7:0] or_reduction_stage;

    // Instantiate 32 instances of the 1-bit ALU
    alu_1bit alu_bit [31:0] (
        .result    (output),
        .carry_out (carry_ripple),
        .a         (buss_a),
        .b         (buss_b),
        .carry_in  ({carry_ripple[30:0], 1'b0}), // Carry-in from previous stage
        .less      (less_than),
        .alu_control(alu_control)
    );

    // The carry-in for the least significant bit
    assign alu_bit[0].carry_in = alu_control[1]; // For addition, carry-in is 0; for subtraction, it's 1

    not #(50) not_carry(not_carry_out_31, carry_ripple[31]);
    mux2_1 #(1) mux_carry_out (
        .o (carry_out),
        .a (carry_ripple[31]),
        .b (not_carry_out_31),
        .sel (alu_control[1])
    );

    xor #(50) xor_overflow(overflow, carry_ripple[30], carry_ripple[31]);

    addsub_1bit addsub_msb (
        .out   (addsub31_out),
        .carry_out (carry_ripple[31]),
        .a     (buss_a[31]),
        .b     (buss_b[31]),
        .carry_in(carry_ripple[30]),
        .select(alu_control[1])
    );

    xor #(50) xor_less_than(less_than, overflow, addsub31_out);

    assign negative = output[31];

    // Zero detection using a reduction OR tree
    or #(50) or_stage1 [7:0] (
        or_reduction_stage[0], output[3:0],
        or_reduction_stage[1], output[7:4],
        or_reduction_stage[2], output[11:8],
        or_reduction_stage[3], output[15:12],
        or_reduction_stage[4], output[19:16],
        or_reduction_stage[5], output[23:20],
        or_reduction_stage[6], output[27:24],
        or_reduction_stage[7], output[31:28]
    );

    or #(50) or_stage2 [1:0] (
        or_reduction_stage[0], or_reduction_stage[0:3],
        or_reduction_stage[1], or_reduction_stage[4:7]
    );

    nor #(50) nor_zero(zero, or_reduction_stage[0], or_reduction_stage[1]);

endmodule
