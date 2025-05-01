module stall_control (
    output logic pc_write_en,
    output logic ifid_write_en,
    output logic stall_flush,
    input  logic        ex_mem_read,
    input  logic [4:0]  ex_rt,
    input  logic [4:0]  id_rs,
    input  logic [4:0]  id_rt,
    input  logic [5:0]  id_op
);

    logic rs_match;
    logic rt_match;
    logic not_lw;
    logic not_xori;
    logic stall_condition;

    // Check if EX_rt matches ID_rs
    assign rs_match = (ex_rt == id_rs);

    // Check if EX_rt matches ID_rt
    assign rt_match = (ex_rt == id_rt);

    // Check if ID_Op is NOT load word (lw) - opcode 6'b100011
    assign not_lw = (id_op != 6'b100011);

    // Check if ID_Op is NOT XOR immediate (xori) - opcode 6'b001110
    assign not_xori = (id_op != 6'b001110);

    // Stall condition: Load word hazard
    assign stall_condition = ex_mem_read && (rs_match || (rt_match && (not_lw || not_xori)));

    // Control signals
    assign pc_write_en   = ~stall_condition;
    assign ifid_write_en = ~stall_condition;
    assign stall_flush   = stall_condition;

endmodule
