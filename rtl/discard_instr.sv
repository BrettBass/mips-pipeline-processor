module discard_instr (
    output logic id_flush,
    output logic if_flush,
    input  logic        jump,
    input  logic        bne,
    input  logic        jr
);

    assign if_flush = jump | bne | jr;
    assign id_flush = bne | jr;

endmodule
