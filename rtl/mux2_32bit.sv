module mux2_32bit (
    output logic [31:0] data_out,
    input  logic [31:0] data_0,
    input  logic [31:0] data_1,
    input  logic        select
);
    assign data_out = select ? data_1 : data_0;

endmodule
