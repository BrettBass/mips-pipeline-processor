module control_unit (
    output logic reg_dst,
    output logic alu_src,
    output logic mem_to_reg,
    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic branch,
    output logic jump,
    output logic sign_zero,
    output logic [1:0] alu_op,
    input  logic [5:0] opcode
);

    always_comb begin
        reg_dst   = 1'b0;
        alu_src   = 1'b0;
        mem_to_reg= 1'b0;
        reg_write = 1'b0;
        mem_read  = 1'b0;
        mem_write = 1'b0;
        branch    = 1'b0;
        jump      = 1'b0;
        sign_zero = 1'b0;
        alu_op    = 2'b00;

        case (opcode)
            6'b000000: begin // R-type
                reg_dst   = 1'b1;
                alu_src   = 1'b0;
                mem_to_reg= 1'b0;
                reg_write = 1'b1;
                alu_op    = 2'b10;
            end
            6'b100011: begin // lw - load word
                alu_src   = 1'b1;
                mem_to_reg= 1'b1;
                reg_write = 1'b1;
                mem_read  = 1'b1;
                alu_op    = 2'b00;
                sign_zero = 1'b0; // sign extend
            end
            6'b101011: begin // sw - store word
                alu_src   = 1'b1;
                mem_write = 1'b1;
                alu_op    = 2'b00;
            end
            6'b000101: begin // bne - branch if not equal
                alu_src   = 1'b0;
                branch    = 1'b1;
                alu_op    = 2'b01;
                sign_zero = 1'b0; // sign extend
            end
            6'b001110: begin // xori - XOR immediate
                alu_src   = 1'b1;
                reg_write = 1'b1;
                alu_op    = 2'b11;
                sign_zero = 1'b1; // zero extend
            end
            6'b000010: begin // j - Jump
                jump      = 1'b1;
            end
            default: begin
                alu_op    = 2'b10;
            end
        endcase
    end

endmodule
