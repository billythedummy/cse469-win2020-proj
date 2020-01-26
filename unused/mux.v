// Generalized mux for any number of select bits

module mux
    #(parameter SEL_BITS=3,
        parameter WIDTH=8)
    (out, in, sel);

    output reg [WIDTH-1:0] out;
    input [SEL_BITS-1:0] sel;
    input [WIDTH * 2**SEL_BITS - 1 : 0] in;

    generate
        if (SEL_BITS == 1) begin
            simplemux #(WIDTH) base ( .out(out), .in1(in[0]), .in2(in[1]), .sel(sel) );
        end
        else begin
            reg [WIDTH-1:0] out_top, out_bot;
            mux #(SEL_BITS-1, WIDTH) top ( .out(out_top), .in(in[WIDTH*2**(SEL_BITS-1)-1 : 0]), .sel(sel[SEL_BITS-2 : 0]) );
            mux #(SEL_BITS-1, WIDTH) bot ( .out(out_bot), .in(in[WIDTH*2**SEL_BITS-1 : WIDTH*2**(SEL_BITS-1)]), .sel(sel[SEL_BITS-2 : 0]) );
            simplemux #(WIDTH) combine ( .out(out), .in1(out_top), .in2(out_bot), .sel(sel[SEL_BITS-1]) ); // MSB goes to last one
        end
    endgenerate

endmodule