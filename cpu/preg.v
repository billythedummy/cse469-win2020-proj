`include "defines.v"

module preg #(parameter WIDTH=`FULLW) (d, q, stall, clk);
    input clk, stall;
    input [WIDTH-1:0] d;
    output reg [WIDTH-1:0] q;

    wire [WIDTH-1:0] dff_in;

    simplemux #(.WIDTH(WIDTH)) sel (.in1(d), .in2(q), .sel(stall), .out(dff_in));
    dff #(.WIDTH(WIDTH)) the_dff (.d(dff_in), .q(q), .clk(clk));

endmodule