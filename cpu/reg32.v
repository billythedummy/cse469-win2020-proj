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

    reg [`FULLW-1:0] mem [0 : (1 << ADDR_WIDTH) - 1]; // not including pc (own module)

    integer index;
    always @(posedge clk) begin
        // out, always
        rd_out <= mem[wa];
        rn_out <= mem[rn_a];
        rm_out <= mem[rm_a];
        // write
        if (we) begin
            mem[wa] <= wd;
        end;
    end
endmodule