module register_32bit (
    output logic [31:0] reg_out,
    input  logic [31:0] reg_in,
    input  logic        write_en,
    input  logic        reset,
    input  logic        clk
);

    d_ff bit_reg [31:0] (
        .q     (reg_out),
        .d     (reg_in),
        .reset (reset),
        .clk   (clk)
    );

endmodule
