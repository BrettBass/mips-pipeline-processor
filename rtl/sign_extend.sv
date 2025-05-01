module sign_extend (
    output logic [31:0] sOut32,
    input  logic [15:0] sIn16
);

    assign sOut32 = {{16{sIn16[15]}}, sIn16};

endmodule
