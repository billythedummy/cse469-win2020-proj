`include "defines.v"

// RAM (watch addr_width, TinyFPGA only has 16KB BRAM available)
module ram
    #(parameter ADDR_WIDTH=8, IS_INSTR=0) // note ADDR_WIDTH is how many WORDS
    (wd, wa, we,
    ra, out,
    clk);
    // data in, address, write enable, output,
    // clock

    // might need a b line for ldrb

    input reg [`FULLW-1:0] wd, wa, ra; // one word at a time only, no support for bytes yet
    input wire we, clk;
    output reg [`FULLW-1:0] out;

    reg [`FULLW - 1:0] mem [0 : (1 << ADDR_WIDTH)-1];

    integer index;

    always @(posedge clk) begin
        // note: read must come before write for successful bram inference
        // https://github.com/YosysHQ/yosys/issues/1087
        // read (always)
        out <= mem[ra >> $clog2(`WORD)];
        // write
        if (we) begin
            // shitty vanilla verilog cant do multi array assign
            mem[wa >> $clog2(`WORD)] <= wd;
        end
    end

    // LAB 1 INSTR
    if (!`IS_SIM) begin
        if (IS_INSTR) initial $readmemh("testcode/hexcode_tests/lab2_instr.mem", mem);
    end

endmodule