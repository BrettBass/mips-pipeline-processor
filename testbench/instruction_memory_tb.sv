module instruction_memory_tb ();
    reg [31:0] addr;
    wire [31:0] instr;

    instruction_memory instruction_memory_inst (
        .instruction (instr),
        .address     (addr)
    );

    initial begin
        $monitor("Mem Address=%h instruction=%b", addr, instr);
        addr = 32'd0;
        #10000 addr = 32'd4;
        #10000 addr = 32'd8;
        #10000 addr = 32'd12;
        #10000 addr = 32'd16;
        #10000 addr = 32'd20;
        #10000 addr = 32'd24;
        #10000 addr = 32'd28;
        #10000 $finish;
    end

endmodule
