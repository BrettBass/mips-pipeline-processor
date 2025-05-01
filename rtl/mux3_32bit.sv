module mux3_32bit (
    output logic [31:0] data_out,
    input  logic [1:0] select,
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [31:0] c
);

    logic [31:0] data_out_ab;
    logic [31:0] data_out_c_a;

    mux2_32bit mux_ab (
        .data_out(data_out_ab),
        .data_0  (a),
        .data_1  (b),
        .select  (select[1])
    );

    mux2_32bit mux_ca (
        .data_out(data_out_c_a),
        .data_0  (c),
        .data_1  (a),
        .select  (select[1])
    );

    mux2_32bit mux_abc (
        .data_out(data_out),
        .data_0  (data_out_ab),
        .data_1  (data_out_c_a),
        .select  (select[0])
    );

endmodule
