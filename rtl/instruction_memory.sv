// Instruction memory module.
// Change the $readmemb line to have the name of the program you want to load
module instruction_memory (
    output logic [31:0] instruction,
    input  logic [31:0] address
);

    reg [31:0] instrmem [1023:0];

    always_ff @(address) begin
        instruction <= instrmem[address / 4];
    end

    initial begin
        $readmemb("instr.txt", instrmem);
    end

endmodule
