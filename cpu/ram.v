// RAM (watch addr_width, TinyFPGA only has 16KB BRAM available)
module ram
    #(parameter WORD=4,
        parameter WIDTH=8,
        parameter ADDR_WIDTH=8) // note ADDR_WIDTH is how many BYTES
    (d, ad, we, q,
    clk);
    // data in, address, write enable, output,
    // clock,

    // might need a b line for ldrb

    input [WORD*WIDTH-1:0] d, ad; // one word at a time only, no support for bytes yet
    input we;
    output reg [WORD*WIDTH-1:0] q;
    input clk;

    reg [(1 << ADDR_WIDTH)*WIDTH - 1:0] mem;

    wire [ADDR_WIDTH-1:0] data_start;
    assign data_start[ADDR_WIDTH-1:0] = ad[ADDR_WIDTH-1:0]; // limit address to addr_width

    always @(posedge clk) begin
        // write
        if (we) begin
            mem[ data_start*WIDTH +: WORD*WIDTH ] <= d;
        end
        // read (always)
        q <= mem[ data_start*WIDTH +: WORD*WIDTH ];
    end
endmodule