`include "defines.v"

module reg32
    #(parameter ADDR_WIDTH=4)
    (in1, in2,
    we, wd, wa,
    out1, out2,
    reset, clk); 
    // input1, input2
    // write-enable, write-data (register write back), write-address
    // output1, output2,
    // isBranch, branchValue, branch should link, instruction out
    // reset clock

    // might need a b line for ldrb

    input [ADDR_WIDTH-1:0] in1, in2, wa;
    input we, clk, reset;
    input [`FULLW - 1:0] wd;

    output reg [`FULLW - 1:0] out1, out2;

    reg [`WIDTH-1:0] mem [0 : ( (1 << ADDR_WIDTH) - 1 )*`WORD-1]; // not including pc (own module)

    integer index;
    always @(posedge clk) begin
        // no reset for other registers..
        // write
        if (we) begin
            for (index=0; index<`WORD; index=index+1) begin
                mem[ {28'b0, wa}*`WORD + index] <= wd[(`WORD-index-1)*`WIDTH +: `WIDTH];
            end
        end
        // out
        for (index=0; index<`WORD; index=index+1) begin
            out2[(`WORD-index-1)*`WIDTH +: `WIDTH] <= mem[{28'b0, in2}*`WORD + index];
        end
        for (index=0; index<`WORD; index=index+1) begin
            out1[(`WORD-index-1)*`WIDTH +: `WIDTH] <= mem[{28'b0, in1}*`WORD + index];
        end
    end

    // LAB 1 REGISTERS
    if (!`IS_SIM) initial $readmemh("testcode/hexcode_tests/lab1_reg.mem", mem);
endmodule