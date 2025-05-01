module d_ff (
    output logic q,
    input  logic d,
    input  logic reset,
    input  logic clk
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            q <= 32'b0; // Assuming a 32-bit register, adjust if needed
        end else begin
            q <= d;
        end
    end

endmodule
