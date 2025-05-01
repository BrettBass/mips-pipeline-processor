module jr_control_unit (
    output logic jr_control,
    input  logic [1:0] alu_op,
    input  logic [5:0] function
);

    logic [7:0] test;

    assign test = {alu_op, function};

    always_comb begin
        case (test)
            8'b10001000: jr_control = 1'b1; // JR instruction (function code 0x08)
            default:      jr_control = 1'b0;
        endcase
    end

endmodule
