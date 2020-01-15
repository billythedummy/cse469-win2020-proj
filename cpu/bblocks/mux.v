// Generalized mux for any number of select bits

module mux
    #(parameter selbits=3,
        parameter width=8)
    (out, in, sel);

    output reg [width-1:0] out;
    input [selbits-1:0] sel;
    input [width-1:0] in[0:2**selbits-1]; // in[0][1] accesses 1st bit of 0th byte

    generate
        if (selbits == 1) begin
            simplemux #(width) base ( .out(out), .in1(in[0]), .in2(in[1]), .sel(sel) );
        end
        else begin
            reg [width-1:0] out_top, out_bot;
            mux #(selbits-1, width) top ( .out(out_top), .in(in[0 : 2**(selbits-1)-1]), .sel(sel[selbits-2 : 0]) );
            mux #(selbits-1, width) bot ( .out(out_bot), .in(in[2**(selbits-1) : 2**selbits-1]), .sel(sel[selbits-2 : 0]) );
            simplemux #(width) combine ( .out(out), .in1(out_top), .in2(out_bot), .sel(sel[selbits-1]) ); // MSB goes to last one
        end
    endgenerate

endmodule