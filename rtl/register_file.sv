module register_file (
    output logic [31:0] read_data1,
    output logic [31:0] read_data2,
    input  logic [31:0] write_data,
    input  logic [4:0]  read_register1,
    input  logic [4:0]  read_register2,
    input  logic [4:0]  write_register,
    input  logic        reg_write,
    input  logic        reset,
    input  logic        clk
);

    logic [31:0] write_enable [31:0];
    logic [31:0] reg_array [0:31];
    integer      i;

    //----Decoder Block
    decoder_5to32 decoder1 (
        .write_enable(write_enable),
        .reg_write   (reg_write),
        .write_register(write_register)
    );

    // Instantiate 32 registers
    register reg_instance [31:0] (
        .reg_out  (reg_array),
        .reg_in   (write_data),
        .write_en (write_enable),
        .reset    (reset),
        .clk      (clk)
    );

    // Special handling for register 0 (should always be zero)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_array[0] <= 32'b0;
        end else begin
            reg_array[0] <= 32'b0; // Always maintain zero
        end
    end

    //----32x32to32 Multiplexor1 Block----
    mux_32x32to32 mux1 (
        .read_data    (read_data1),
        .input_array  (reg_array),
        .select       (read_register1)
    );

    //----32x32to32 Multiplexor2 Block----
    mux_32x32to32 mux2 (
        .read_data    (read_data2),
        .input_array  (reg_array),
        .select       (read_register2)
    );

endmodule
