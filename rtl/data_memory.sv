module data_memory (
    output logic [31:0] data,
    input  logic [31:0] address,
    input  logic [31:0] write_data,
    input  logic        write_enable,
    input  logic        mem_read,
    input  logic        clk
);

    reg [7:0] data_mem [1023:0];
    logic [31:0] temp;

    always_ff @(posedge clk) begin
        if (write_enable) begin
            data_mem[address]   <= write_data[31:24];
            data_mem[address + 1] <= write_data[23:16];
            data_mem[address + 2] <= write_data[15:8];
            data_mem[address + 3] <= write_data[7:0];
        end
    end

    always_comb begin
        if (mem_read) begin
            temp = {data_mem[address], data_mem[address + 1], data_mem[address + 2], data_mem[address + 3]};
        end else begin
            temp = 32'bx; // Output X when not reading
        end
        data = temp;
    end

    // initial begin
    //     $readmemh("data.dat", data_mem);
    // end

endmodule
