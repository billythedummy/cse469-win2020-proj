`include "defines.v"

module reg32
    #(parameter ADDR_WIDTH=4)
    (rn_a, rm_a, rd_a,
    we, wd, wa,
    rn_out, rm_out, rd_out, 
    clk); 

    // might need a b line for ldrb

    input [ADDR_WIDTH-1:0] rn_a, rm_a, rd_a, wa;
    input we, clk;
    input [`FULLW - 1:0] wd;

    output reg [`FULLW - 1:0] rd_out, rn_out, rm_out;

    reg [`FULLW-1:0] mem [0 : (1 << ADDR_WIDTH) - 1]; // not including pc (own module)

    integer index;
    always @(posedge clk) begin
        // out, always
        rd_out <= mem[rd_a];
        rn_out <= mem[rn_a];
        rm_out <= mem[rm_a];
        // write
        if (we) begin
            mem[wa] <= wd;
        end;
    end
endmodule