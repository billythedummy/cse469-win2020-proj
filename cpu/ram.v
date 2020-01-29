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

    reg [WIDTH - 1:0] mem [0 : (1 << ADDR_WIDTH)-1];

    wire [ADDR_WIDTH-1:0] data_start;
    assign data_start[ADDR_WIDTH-1:0] = ad[ADDR_WIDTH-1:0]; // limit address to addr_width

    integer index;
    always @(posedge clk) begin
        // write
        if (we) begin
            // shitty vanilla verilog cant do multi array assign
            for (index=0; index<WORD; index=index+1) begin
                mem[ad + index] <= d[(WORD-index-1)*WIDTH +: WIDTH];
            end
        end
        // read (always)
        for (index=0; index<WORD; index=index+1) begin
            q[(WORD-index-1)*WIDTH +: WIDTH] <= mem[ad + index];
        end
    end

    // LAB 1 INSTR
    initial $readmemh("testcode/hexcode_tests/lab1_instr.mem", mem);

endmodule