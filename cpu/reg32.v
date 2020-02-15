`include "defines.v"

module reg32
    #(parameter ADDR_WIDTH=4)
    (rn_a, rm_a,
    we, wd, wa,
    rd_out, rn_out, rm_out,
    clk); 
    // input1, input2
    // write-enable, write-data (register write back), write-address
    // output1, output2,
    // isBranch, branchValue, branch should link, instruction out
    // clock

    // might need a b line for ldrb

    input [ADDR_WIDTH-1:0] rn_a, rm_a, wa; //rd is write address
    input we, clk;
    input [`FULLW - 1:0] wd;

    output reg [`FULLW - 1:0] rd_out, rn_out, rm_out;

    reg [`WIDTH-1:0] mem [0 : ( (1 << ADDR_WIDTH) - 1 )*`WORD-1]; // not including pc (own module)

    integer index;
    always @(posedge clk) begin
        // write
        if (we) begin
            for (index=0; index<`WORD; index=index+1) begin
                mem[ {28'b0, wa}*`WORD + index] <= wd[(`WORD-index-1)*`WIDTH +: `WIDTH];
            end
        end
        // out, always
        for (index=0; index<`WORD; index=index+1) begin
            rd_out[(`WORD-index-1)*`WIDTH +: `WIDTH] <= mem[{28'b0, wa}*`WORD + index];
        end
        for (index=0; index<`WORD; index=index+1) begin
            rn_out[(`WORD-index-1)*`WIDTH +: `WIDTH] <= mem[{28'b0, rn_a}*`WORD + index];
        end
        for (index=0; index<`WORD; index=index+1) begin
            rm_out[(`WORD-index-1)*`WIDTH +: `WIDTH] <= mem[{28'b0, rm_a}*`WORD + index];
        end
    end

    // LAB 1 REGISTERS
    if (!`IS_SIM) initial $readmemh("testcode/hexcode_tests/lab1_reg.mem", mem);
endmodule