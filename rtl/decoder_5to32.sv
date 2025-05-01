module decoder_5to32 (
    output logic [31:0] write_enable,
    input  logic        reg_write,
    input  logic [4:0]  write_register
);

    logic [31:0] oe; // Output Enable

    assign oe = (1 << write_register); // Efficiently create the one-hot output

    always_comb begin
        write_enable = 32'b0;
        if (reg_write) begin
            write_enable = oe;
        end
        write_enable[0] = 1'b0; // Register 0 is always zero
    end

endmodule
