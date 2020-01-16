// RAM (watch addr_width, TinyFPGA only has 16KB BRAM available)
module ram
    #(parameter WORD=4,
        parameter WIDTH=8,
        parameter ADDR_WIDTH=10) 
    (d, ad, we, q, clk); // data in, address, write enable, output, clock

    // might need a b line for ldrb

    input [WORD*WIDTH-1:0] d; // one word at a time only, no support for stm
    input [WORD*WIDTH-1:0] ad;
    input we;
    output reg [WORD*WIDTH-1:0] q;
    input clk;

    reg [(1 << ADDR_WIDTH) - 1:0][WIDTH-1:0] mem;

    wire [ADDR_WIDTH-1:0] start;
    assign start[ADDR_WIDTH-1:0] = ad[ADDR_WIDTH-1:0]; // limit address to addr_width

    always_ff @(posedge clk) begin
        // write
        if (we) begin
            mem[ start +: WORD ] <= d;
        end
        // read (always)
        q <= mem[ start +: WORD ];
    end
endmodule