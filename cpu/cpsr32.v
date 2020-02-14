`include "defines.v"

module cpsr32
    (should_set_cpsr,
    cpsrwd,
    out, clk);
    
    input wire clk;
    input wire [`FLAGSW-1:0] should_set_cpsr, cpsrwd;
    output wire [`FULLW-1 : 0] out;

    wire [`FULLW-1 : 0] writein;
    dff mem (.d(writein), .q(out), .clk(clk));
    
    //dont care about bit 0-27
    assign writein[`FLAGS_START-1:0] = out[`FLAGS_START-1:0];

    genvar index;
    for (index=0; index<`FLAGSW; index=index+1) begin
        assign writein[`FLAGS_START + index] = should_set_cpsr[index] 
                                                ? cpsrwd[index] 
                                                : out[`FLAGS_START + index];
    end

endmodule