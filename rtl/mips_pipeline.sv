module mips_pipeline (
    input logic clk,
    input logic reset
);

    // Wires
    logic [31:0] pc, pc_in;
    logic [31:0] pc4, id_pc4, ex_pc4;
    logic [31:0] pc_bne, pc4_bne, pc_j, pc4_bne_j, pc_jr; // PC signals in MUX
    logic [31:0] instruction, id_instruction, ex_instruction; // Output of Instruction Memory
    logic [5:0] opcode, function; // Opcode, Function
    logic [15:0] imm16; // immediate in I type instruction
    logic [31:0] im16_ext, ex_im16_ext;
    logic [31:0] sign_ext_out, zero_ext_out;
    logic [4:0] rs, rt, rd, ex_rs, ex_rt, ex_rd, ex_write_register, mem_write_register, wb_write_register;
    logic [31:0] wb_write_data, read_data1, read_data2, read_data1_out, read_data2_out, ex_read_data1, ex_read_data2;
    logic [31:0] bus_a_alu, bus_b_alu, bus_b_forwarded;
    logic [31:0] ex_alu_result, mem_alu_result, wb_alu_result;
    logic zero_flag, overflow_flag, carry_flag, negative_flag, not_zero_flag;
    logic [31:0] write_data_of_mem, mem_read_data_of_mem, wb_read_data_of_mem;
    logic reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch, jump, sign_zero, jr_control;
    logic id_reg_dst, id_alu_src, id_mem_to_reg, id_reg_write, id_mem_read, id_mem_write, id_branch, id_jr_control;
    logic ex_reg_dst, ex_alu_src, ex_mem_to_reg, ex_reg_write, ex_mem_read, ex_mem_write, ex_branch, ex_jr_control;
    logic mem_mem_to_reg, mem_reg_write, mem_mem_read, mem_mem_write;
    logic wb_mem_to_reg, wb_reg_write;
    logic [1:0] alu_op, id_alu_op, ex_alu_op;
    logic [1:0] alu_control;
    logic bne_control, not_bne_control;
    logic jump_control, jump_flush;
    logic [1:0] forward_a, forward_b;
    logic if_flush, ifid_flush, not_ifid_flush, stall_flush, flush;
    logic [31:0] shiftleft2_bne_out, shiftleft2_jump_out; // shift left output
    logic pc_write_en, ifid_write_en;

    // PC register
    pc_reg pc_reg_inst (
        .pc_out  (pc),
        .pc_in   (pc_in),
        .write_en(pc_write_en),
        .reset   (reset),
        .clk     (clk)
    );

    // PC + 4 Adder
    assign pc4 = pc + 4'd4;

    // Instruction Memory
    instruction_mem instruction_mem_inst (
        .instruction(instruction),
        .address    (pc)
    );

    // IF/ID Register
    ifid_pc4 ifid_pc4_inst (
        .q       (id_pc4),
        .d       (pc4),
        .write_en(ifid_write_en),
        .reset   (reset),
        .clk     (clk)
    );

    ifid_instruction ifid_instruction_inst (
        .q       (id_instruction),
        .d       (instruction),
        .write_en(ifid_write_en),
        .reset   (reset),
        .clk     (clk)
    );

    reg_bit if_flush_bit_inst (
        .q       (ifid_flush),
        .d       (if_flush),
        .write_en(ifid_write_en),
        .reset   (reset),
        .clk     (clk)
    );

    // ID Stage
    assign opcode = id_instruction[31:26];
    assign function = id_instruction[5:0];
    assign rs = id_instruction[25:21];
    assign rt = id_instruction[20:16];
    assign rd = id_instruction[15:11];
    assign imm16 = id_instruction[15:0];

    // Main Control
    control_unit main_control_inst (
        .reg_dst  (reg_dst),
        .alu_src  (alu_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .mem_read (mem_read),
        .mem_write(mem_write),
        .branch   (branch),
        .alu_op   (alu_op),
        .jump     (jump),
        .sign_zero(sign_zero),
        .opcode   (opcode)
    );

    // Register File
    regfile register_file_inst (
        .read_data1   (read_data1),
        .read_data2   (read_data2),
        .write_data    (wb_write_data),
        .read_address1 (rs),
        .read_address2 (rt),
        .write_address (wb_write_register),
        .write_enable  (wb_reg_write),
        .reset         (reset),
        .clk           (clk)
    );

    // Write Back Forwarding
    wb_forward wb_forward_block_inst (
        .read_data1_out(read_data1_out),
        .read_data2_out(read_data2_out),
        .read_data1     (read_data1),
        .read_data2     (read_data2),
        .rs             (rs),
        .rt             (rt),
        .write_register (wb_write_register),
        .write_data     (wb_write_data),
        .reg_write      (wb_reg_write)
    );

    // Sign-extend
    sign_extend sign_extend1_inst (
        .sOut32(sign_ext_out),
        .sIn16 (imm16)
    );

    // Zero-extend
    zero_extend zero_extend1_inst (
        .zOut32(zero_ext_out),
        .zIn16 (imm16)
    );

    // Immediate extend: sign or zero
    mux2_32bit mux_sign_zero_inst (
        .data_out(im16_ext),
        .data_0  (sign_ext_out),
        .data_1  (zero_ext_out),
        .select  (sign_zero)
    );

    // JR Control
    jr_control_unit jr_control_block_inst (
        .jr_control(jr_control),
        .alu_op    (alu_op),
        .function  (function)
    );

    // Discard Instructions
    discard_instr discard_instr_block_inst (
        .id_flush (id_flush),
        .if_flush (if_flush),
        .jump     (jump_control),
        .bne      (bne_control),
        .jr       (ex_jr_control) // Using EX_JRControl from EX stage
    );

    // Flush Control
    flush_control flush_block1_inst (
        .id_reg_dst  (id_reg_dst),
        .id_alu_src  (id_alu_src),
        .id_mem_to_reg(id_mem_to_reg),
        .id_reg_write(id_reg_write),
        .id_mem_read (id_mem_read),
        .id_mem_write(id_mem_write),
        .id_branch   (id_branch),
        .id_jr_control(id_jr_control),
        .id_alu_op   (id_alu_op),
        .flush       (flush),
        .reg_dst     (reg_dst),
        .alu_src     (alu_src),
        .mem_to_reg  (mem_to_reg),
        .reg_write   (reg_write),
        .mem_read    (mem_read),
        .mem_write   (mem_write),
        .branch      (branch),
        .jr_control  (jr_control),
        .alu_op      (alu_op)
    );

    assign flush = id_flush | ifid_flush | stall_flush;

    //==========EX STAGE=========================
    // thanh ghi ID/EX
    idex_pc4 idex_pc4_inst (
        .q       (ex_pc4),
        .d       (id_pc4),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    idex_read_data1 idex_read_data1_inst (
        .q       (ex_read_data1),
        .d       (read_data1_out),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    idex_read_data2 idex_read_data2_inst (
        .q       (ex_read_data2),
        .d       (read_data2_out),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    idex_im16_ext idex_im16_ext_inst (
        .q       (ex_im16_ext),
        .d       (im16_ext),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    idex_rs_rt_rd idex_rs_rt_rd_inst (
        .q       (ex_instruction),
        .d       (id_instruction),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    assign ex_rs = ex_instruction[25:21];
    assign ex_rt = ex_instruction[20:16];
    assign ex_rd = ex_instruction[15:11];

    // 9 control signals via ID/EX
    reg_bit  idex_reg_dst_inst (
        .q       (ex_reg_dst),
        .d       (id_reg_dst),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  idex_alu_src_inst (
        .q       (ex_alu_src),
        .d       (id_alu_src),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  idex_mem_to_reg_inst (
        .q       (ex_mem_to_reg),
        .d       (id_mem_to_reg),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  idex_reg_write_inst (
        .q       (ex_reg_write),
        .d       (id_reg_write),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  idex_mem_read_inst (
        .q       (ex_mem_read),
        .d       (id_mem_read),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  idex_mem_write_inst (
        .q       (ex_mem_write),
        .d       (id_mem_write),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  idex_branch_inst (
        .q       (ex_branch),
        .d       (id_branch),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  idex_jr_control_inst (
        .q       (ex_jr_control),
        .d       (id_jr_control),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  idex_alu_op1_inst (
        .q       (ex_alu_op[1]),
        .d       (id_alu_op[1]),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  idex_alu_op0_inst (
        .q       (ex_alu_op[0]),
        .d       (id_alu_op[0]),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    // Forwarding unit
    forwarding_unit forwarding_block_inst (
        .forward_a         (forward_a),
        .forward_b         (forward_b),
        .mem_reg_write     (mem_reg_write),
        .wb_reg_write      (wb_reg_write),
        .mem_write_register(mem_write_register),
        .wb_write_register (wb_write_register),
        .ex_rs             (ex_rs),
        .ex_rt             (ex_rt)
    );

    // mux 3 x32 to 32 to choose source of ALU (forwarding)
    mux3_32bit mux3_a_inst (
        .data_out(bus_a_alu),
        .select  (forward_a),
        .a       (ex_read_data1),
        .b       (mem_alu_result),
        .c       (wb_write_data)
    );
    mux3_32bit mux3_b_inst (
        .data_out(bus_b_forwarded),
        .select  (forward_b),
        .a       (ex_read_data2),
        .b       (mem_alu_result),
        .c       (wb_write_data)
    );

    // mux 2x32 to 32 to select source Bus B of ALU
    mux2_32bit mux_alu_src_inst (
        .data_out(bus_b_alu),
        .data_0  (bus_b_forwarded),
        .data_1  (ex_im16_ext),
        .select  (ex_alu_src)
    );

    // ALU Control
    alu_control_unit alu_control_block1_inst (
        .alu_control(alu_control),
        .alu_op     (ex_alu_op),
        .function   (ex_im16_ext[5:0])
    );

    // ALU
    alu alu_block_inst (
        .output    (ex_alu_result),
        .carry_out (carry_flag),
        .zero      (zero_flag),
        .overflow  (overflow_flag),
        .negative  (negative_flag),
        .buss_a    (bus_a_alu),
        .buss_b    (bus_b_alu),
        .alu_control(alu_control)
    );

    // mux 2x5 to 5 choose shift register is Rd or Rt
    mux2_5bit mux_reg_dst_inst (
        .addr_out(ex_write_register),
        .addr_0  (ex_rt),
        .addr_1  (ex_rd),
        .select  (ex_reg_dst)
    );

    //==============MEM STAGE=================
    // register EX/MEM
    exmem_alu_result exmem_alu_result_inst (
        .q       (mem_alu_result),
        .d       (ex_alu_result),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    exmem_write_data_of_mem exmem_write_data_of_mem_inst (
        .q       (write_data_of_mem),
        .d       (bus_b_forwarded),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    reg_bit  exmem_mem_to_reg_inst (
        .q       (mem_mem_to_reg),
        .d       (ex_mem_to_reg),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  exmem_reg_write_inst (
        .q       (mem_reg_write),
        .d       (ex_reg_write),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  exmem_mem_read_inst (
        .q       (mem_mem_read),
        .d       (ex_mem_read),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  exmem_mem_write_inst (
        .q       (mem_mem_write),
        .d       (ex_mem_write),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    exmem_write_register exmem_write_register_inst (
        .q       (mem_write_register),
        .d       (ex_write_register),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    // Data Memory
    data_mem data_mem1_inst (
        .read_data   (mem_read_data_of_mem), // data
        .address     (mem_alu_result),       // address
        .write_data  (write_data_of_mem),       // writedata
        .write_enable(mem_mem_write),        // writeenable
        .read_enable (mem_mem_read),
        .clk         (clk)
    );

    //==========WB STAGE====================
    // register MEM/WB
    memwb_read_data_of_mem memwb_read_data_of_mem_inst (
        .q       (wb_read_data_of_mem),
        .d       (mem_read_data_of_mem),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    memwb_alu_result memwb_alu_result_inst (
        .q       (wb_alu_result),
        .d       (mem_alu_result),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    memwb_write_register memwb_write_register_inst (
        .q       (wb_write_register),
        .d       (mem_write_register),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    reg_bit  memwb_mem_to_reg_inst (
        .q       (wb_mem_to_reg),
        .d       (mem_mem_to_reg),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );
    reg_bit  memwb_reg_write_inst (
        .q       (wb_reg_write),
        .d       (mem_reg_write),
        .write_en(1'b1),
        .reset   (reset),
        .clk     (clk)
    );

    // Select Data to WriteData for regfile
    mux2_32bit mux_mem_to_reg_inst (
        .data_out(wb_write_data),
        .data_0  (wb_alu_result),
        .data_1  (wb_read_data_of_mem),
        .select  (wb_mem_to_reg)
    );

    //Stalling
    stall_control stall_control_block_inst (
        .pc_write_en  (pc_write_en),
        .ifid_write_en(ifid_write_en),
        .stall_flush  (stall_flush),
        .ex_mem_read  (ex_mem_read),
        .ex_rt        (ex_rt),
        .id_rs        (rs),
        .id_rt        (rt),
        .id_op        (opcode)
    );

    //Jump,bne, JRs
    // bne: Branch if not equal
    shift_left_2 shiftleft2_bne_inst (
        .sOut32(shiftleft2_bne_out),
        .sIn16 (ex_im16_ext)
    );
    assign pc_bne = ex_pc4 + shiftleft2_bne_out;
    assign not_zero_flag = ~zero_flag;
    assign bne_control = ex_branch & not_zero_flag;
    mux2_32bit mux_bne_control_inst (
        .data_out(pc4_bne),
        .data_0  (ex_pc4),
        .data_1  (pc_bne),
        .select  (bne_control)
    );

    // jump
    shift_left_2 shiftleft2_jump_inst (
        .sOut32(shiftleft2_jump_out),
        .sIn16 ({6'b0, id_instruction[25:0]})
    );
    assign pc_j = {id_pc4[31:28], shiftleft2_jump_out[27:0]};
    assign not_ifid_flush = ~ifid_flush;
    assign jump_flush = jump & not_ifid_flush;
    assign not_bne_control = ~bne_control;
    assign jump_control = jump_flush & not_bne_control;
    mux2_32bit mux_jump_inst (
        .data_out(pc4_bne_j),
        .data_0  (pc4_bne),
        .data_1  (pc_j),
        .select  (jump_control)
    );

    // JR: Jump Register
    assign pc_jr = bus_a_alu;
    mux2_32bit mux_jr_inst (
        .data_out(pc_in),
        .data_0  (pc4_bne_j),
        .data_1  (pc_jr),
        .select  (ex_jr_control)
    );

endmodule
