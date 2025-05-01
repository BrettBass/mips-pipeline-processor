module mux_andmore (
    output logic g,
    input  logic a,
    input  logic b,
    input  logic c,
    input  logic d,
    input  logic e
);
    assign #50 g = a & b & c & d & e;
endmodule
