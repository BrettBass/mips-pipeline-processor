`timescale 1 ps / 100 fs
module mips_stimulus;
    parameter logic [31:0] clock_delay = 5000;

    logic clk, reset;

    mips_pipeline my_mips (
        .clk   (clk),
        .reset (reset)
    );

    initial clk = 0;
    always #(clock_delay / 2) clk = ~clk;

    initial begin
        reset = 1;
        #(clock_delay / 4);
        reset = 0;
    end

endmodule
