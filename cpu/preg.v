`include "defines.v"

module preg #(parameter WIDTH=`FULLW) (d, q, stall, clk);
    input clk, stall;
    input [WIDTH-1:0] d;
    output reg [WIDTH-1:0] q;

    always @(posedge clk) begin
        if (stall) q <= q;
        else q <= d;
    end
endmodule