module mux_32x32to32 (
    output logic [31:0] read_data,
    input  logic [31:0] input_array [0:31],
    input  logic [4:0]  select
);

    mux_32to1 mux_instance [31:0] (
        .out   (read_data),
        .in_bus(input_array),
        .select(select)
    );

endmodule
