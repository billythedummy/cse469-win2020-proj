`include "defines.v"

// big endian register
module register
    (we, d, q, clk);
    // write enable, flags in, out, clock
    input we, clk;
    input [`FULLW-1 : 0] d;
    output reg [`FULLW-1 : 0] q;

    reg [`WIDTH - 1:0] mem [0 : `WORD-1];

    integer index;
    always @(posedge clk) begin
        if (we) begin
            for (index=0; index<`WORD; index=index+1) begin
                mem[index] <= d[(`WORD-index-1)*`WIDTH +: `WIDTH];
            end
        end
        for (index=0; index<`WORD; index=index+1) begin
            q[(`WORD-index-1)*`WIDTH +: `WIDTH] <= mem[index];
        end
    end

    // LAB 1 CPSR
    //initial $readmemh("testcode/hexcode_tests/lab1_cpsr.mem", mem);
endmodule