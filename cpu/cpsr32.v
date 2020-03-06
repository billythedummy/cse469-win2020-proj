`include "defines.v"

module cpsr32
    (should_set_cpsr,
    cpsrwd,
    out, clk, reset);
    
    input wire clk, reset;
    input wire [`FLAGS_W-1:0] should_set_cpsr, cpsrwd;
    output wire [`FULLW-1 : 0] out;

    wire [`FULLW-1 : 0] writein;
    wire [`FULLW-1 : 0] reset_before_writein;
    dff mem (.d(writein), .q(out), .clk(clk));
    
    //dont care about bit 0-27
    assign reset_before_writein[`FLAGS_START-1:0] = out[`FLAGS_START-1:0];

    genvar index;
    for (index=0; index<`FLAGS_W; index=index+1) begin
        assign reset_before_writein[`FLAGS_START + index] = should_set_cpsr[index] 
                                                ? cpsrwd[index] 
                                                : out[`FLAGS_START + index];
    end
    for (index=0; index<`FULLW; index=index+1) begin
        assign writein[index] = reset
                                ? 0
                                : reset_before_writein[index];
    end

endmodule