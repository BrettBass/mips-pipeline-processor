module mux2_1 #(parameter DATA_WIDTH = 32) (
    output logic [DATA_WIDTH-1:0] o,
    input  logic [DATA_WIDTH-1:0] a,
    input  logic [DATA_WIDTH-1:0] b,
    input  logic sel
);

    assign #(50) o = sel ? b : a;

endmodule
