module mux2_5bit (
    output logic [4:0] addr_out,
    input  logic [4:0] addr_0,
    input  logic [4:0] addr_1,
    input  logic       select
);

    assign addr_out = select ? addr_1 : addr_0;

endmodule
