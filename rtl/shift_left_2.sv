module shift_left_2 (
    output logic [31:0] out32,
    input  logic [31:0] in32
);

    assign out32 = {in32[29:0], 2'b00};

endmodule
