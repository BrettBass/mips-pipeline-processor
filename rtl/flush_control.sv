module flush_control (
    output logic id_reg_dst,
    output logic id_alu_src,
    output logic id_mem_to_reg,
    output logic id_reg_write,
    output logic id_mem_read,
    output logic id_mem_write,
    output logic id_branch,
    output logic id_jr_control,
    output logic [1:0] id_alu_op,
    input  logic        flush,
    input  logic        reg_dst,
    input  logic        alu_src,
    input  logic        mem_to_reg,
    input  logic        reg_write,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic        branch,
    input  logic        jr_control,
    input  logic [1:0]  alu_op
);

    assign id_reg_dst   = reg_dst   & ~flush;
    assign id_alu_src   = alu_src   & ~flush;
    assign id_mem_to_reg= mem_to_reg& ~flush;
    assign id_reg_write = reg_write & ~flush;
    assign id_mem_read  = mem_read  & ~flush;
    assign id_mem_write = mem_write & ~flush;
    assign id_branch    = branch    & ~flush;
    assign id_jr_control= jr_control& ~flush;
    assign id_alu_op    = alu_op    & ~flush;

endmodule
