module phaser #(parameter PHASES=5) (out, clk, reset);
    input clk, reset;
    output reg [$clog2(PHASES)-1:0] out;

    always @(posedge clk) begin
        if (reset) out <= 0;
        else if (out == (PHASES - 1)) out <= 0;
        else out <= out + 1;
    end
endmodule