module mux_32to1 (
    output logic [31:0] out,
    input  logic [31:0] in_bus [0:31],
    input  logic [4:0]  select
);
    logic [31:0] oe; // Output Enable

    decoder_5to32 dec1 (
        .write_enable(oe),
        .reg_write   (1'b1), // Decoder is always enabled for selection
        .write_register(select)
    );

    always_comb begin
        out = 32'bx; // Initialize to X
        for (int i = 0; i < 32; i++) begin
            if (oe[i]) begin
                out = in_bus[i];
            end
        end
    end

endmodule
