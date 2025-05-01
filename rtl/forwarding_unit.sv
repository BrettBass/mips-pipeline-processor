module forwarding_unit (
    output logic [1:0] forward_a,
    output logic [1:0] forward_b,
    input  logic        mem_reg_write,
    input  logic        wb_reg_write,
    input  logic [4:0]  mem_write_register,
    input  logic [4:0]  wb_write_register,
    input  logic [4:0]  ex_rs,
    input  logic [4:0]  ex_rt
);

    logic mem_write_reg_not_zero;
    logic wb_write_reg_not_zero;
    logic mem_rs_match;
    logic wb_rs_match;
    logic mem_rt_match;
    logic wb_rt_match;

    // Check if MEM write register is not $zero (0)
    assign mem_write_reg_not_zero = |mem_write_register;

    // Check if WB write register is not $zero (0)
    assign wb_write_reg_not_zero = |wb_write_register;

    // Compare MEM write register with EX_rs
    assign mem_rs_match = (mem_write_register == ex_rs) && mem_write_reg_not_zero;

    // Compare WB write register with EX_rs
    assign wb_rs_match = (wb_write_register == ex_rs) && wb_write_reg_not_zero;

    // Compare MEM write register with EX_rt
    assign mem_rt_match = (mem_write_register == ex_rt) && mem_write_reg_not_zero;

    // Compare WB write register with EX_rt
    assign wb_rt_match = (wb_write_register == ex_rt) && wb_write_reg_not_zero;

    // Forwarding logic for operand A (rs)
    always_comb begin
        forward_a = 2'b00; // Default: no forwarding
        if (mem_reg_write && mem_rs_match) begin
            forward_a = 2'b10; // Forward from MEM/WB
        end else if (wb_reg_write && wb_rs_match) begin
            forward_a = 2'b01; // Forward from WB
        end
    end

    // Forwarding logic for operand B (rt)
    always_comb begin
        forward_b = 2'b00; // Default: no forwarding
        if (mem_reg_write && mem_rt_match) begin
            forward_b = 2'b10; // Forward from MEM/WB
        end else if (wb_reg_write && wb_rt_match) begin
            forward_b = 2'b01; // Forward from WB
        end
    end

endmodule
