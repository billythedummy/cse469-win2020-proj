// RAM (watch addr_width, TinyFPGA only has 16KB BRAM available)
module ram
    #(parameter WORD=4,
        parameter WIDTH=8,
        parameter ADDR_WIDTH=10) 
    (d, ad, we, q,
    ia, iout,
    clk);
    // data in, address, write enable, output,
    // instruction address, instruction out
    // clock,

    // might need a b line for ldrb

    input [WORD*WIDTH-1:0] d, ad, ia; // one word at a time only, no support for bytes yet
    input we;
    output reg [WORD*WIDTH-1:0] q, iout;
    input clk;

    reg [(1 << ADDR_WIDTH) - 1:0][WIDTH-1:0] mem;

    wire [ADDR_WIDTH-1:0] data_start;
    assign data_start[ADDR_WIDTH-1:0] = ad[ADDR_WIDTH-1:0]; // limit address to addr_width

    wire [ADDR_WIDTH-1:0] inst_start;
    assign inst_start[ADDR_WIDTH-1:0] = ia[ADDR_WIDTH-1:0]; // limit address to addr_width

    always_ff @(posedge clk) begin
        // write
        if (we) begin
            mem[ data_start +: WORD ] <= d;
        end
        // read (always)
        q <= mem[ data_start +: WORD ];
        // instruction out (always)
        iout <= mem[ inst_start +: WORD ];
    end
endmodule