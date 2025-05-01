module compare_address (
    output logic equal,
    input  logic [4:0] addr1,
    input  logic [4:0] addr2
);

    assign equal = (addr1 == addr2);

endmodule
