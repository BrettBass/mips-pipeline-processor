module adder_1bit (
    output logic sum,
    output logic cout,
    input  logic a,
    input  logic b,
    input  logic cin
);

    assign #50 sum = a ^ b ^ cin;
    assign #50 cout = (a & b) | (cin & (a ^ b));

endmodule
