// Filename: wb_forward.sv

module wb_forward (
    output logic [31:0] read_data1_out,
    output logic [31:0] read_data2_out,
    input  logic [31:0] read_data1,
    input  logic [31:0] read_data2,
    input  logic [4:0]  rs,
    input  logic [4:0]  rt,
    input  logic [4:0]  write_register,
    input  logic [31:0] write_data,
    input  logic        reg_write
);

    logic read_source_rs;
    logic read_source_rt;
    logic write_reg_not_zero;
    logic rs_match;
    logic rt_match;

    // Check if WriteRegister is not $zero (0)
    assign write_reg_not_zero = |write_register;

    // Compare WriteRegister with rs
    assign rs_match = (reg_write && write_reg_not_zero && (write_register == rs));

    // Compare WriteRegister with rt
    assign rt_match = (reg_write && write_reg_not_zero && (write_register == rt));

    // Select ReadData1 output
    mux2_32bit mux_read_data1 (
        .data_out(read_data1_out),
        .data_0  (read_data1),
        .data_1  (write_data),
        .select  (rs_match)
    );

    // Select ReadData2 output
    mux2_32bit mux_read_data2 (
        .data_out(read_data2_out),
        .data_0  (read_data2),
        .data_1  (write_data),
        .select  (rt_match)
    );

endmodule
