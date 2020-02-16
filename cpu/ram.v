`include "defines.v"

// RAM (watch addr_width, TinyFPGA only has 16KB BRAM available)
module ram
    #(parameter ADDR_WIDTH=8, IS_INSTR=0) // note ADDR_WIDTH is how many BYTES
    (wd, wa, we,
    ra, out,
    clk);
    // data in, address, write enable, output,
    // clock

    // might need a b line for ldrb

    input [`FULLW-1:0] wd, wa, ra; // one word at a time only, no support for bytes yet
    input we, clk;
    output reg [`FULLW-1:0] out;

    reg [`WIDTH - 1:0] mem [0 : (1 << ADDR_WIDTH)-1];

    integer index;
    always @(posedge clk) begin
        // write
        if (we) begin
            // shitty vanilla verilog cant do multi array assign
            for (index=0; index<`WORD; index=index+1) begin
                mem[wa + index] <= wd[(`WORD-index-1)*`WIDTH +: `WIDTH];
            end
        end
        // read (always)
        for (index=0; index<`WORD; index=index+1) begin
            out[(`WORD-index-1)*`WIDTH +: `WIDTH] <= mem[ra + index];
        end
    end

    // LAB 1 INSTR
    if (!`IS_SIM) begin
        if (IS_INSTR) initial $readmemh("testcode/hexcode_tests/lab2_instr.mem", mem);
    end

endmodule