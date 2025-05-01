module alu_control_unit (
    output logic [1:0] alu_control,
    input  logic [1:0] alu_op,
    input  logic [5:0] function
);

    logic [7:0] alu_control_in;

    assign alu_control_in = {alu_op, function};

    always_comb begin
        unique case (alu_control_in)
            8'b11xxxxxx: alu_control = 2'b01;
            8'b00xxxxxx: alu_control = 2'b00;
            8'b01xxxxxx: alu_control = 2'b10;
            8'b10100000: alu_control = 2'b00; // add
            8'b10100010: alu_control = 2'b10; // slt
            8'b10101010: alu_control = 2'b11; // xor
            default:       alu_control = 2'b00;
        endcase
    end

endmodule
