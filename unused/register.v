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
                q[index*`WIDTH +: `WIDTH] <= d[index*`WIDTH +: `WIDTH];
            end
        end
        // can't seem to infer this as block ram so gotta do this
        // assign q in write block shit to ensure 1 clock delay
        else begin
            for (index=0; index<`WORD; index=index+1) begin
                q[(`WORD-index-1)*`WIDTH +: `WIDTH] <= mem[index];
            end
        end
    end

    // LAB 1 CPSR
    //if (!`IS_SIM) initial $readmemh("testcode/hexcode_tests/lab1_cpsr.mem", mem);
endmodule