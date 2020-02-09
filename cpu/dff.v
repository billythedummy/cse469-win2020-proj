`include "defines.v"

module dff #(parameter WIDTH=`FULLW) (d, q, clk);
    input clk;
    input [WIDTH-1:0] d;
    output reg [WIDTH-1:0] q;

    always @(posedge clk) begin
        q <= d;
    end
endmodule