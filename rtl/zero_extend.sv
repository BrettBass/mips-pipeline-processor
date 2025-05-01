module zero_extend (
    output logic [31:0] zOut32,
    input  logic [15:0] zIn16
);

    assign zOut32 = {16'b0, zIn16};

endmodule
