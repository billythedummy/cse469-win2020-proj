`include "defines.v"

module cpsr32
    (shouldsetcpsr,
    cpsrwd,
    out, clk);
    
    input wire clk;
    input wire [`FLAGSW-1:0] shouldsetcpsr, cpsrwd;
    output wire [`FULLW-1 : 0] out;

    wire [`FULLW-1 : 0] writein;
    dff mem (.d(writein), .q(out), .clk(clk));
    
    assign writein[`FLAGS_START-1:0] = out[`FLAGS_START-1:0];
    genvar index;
    for (index=0; index<`FLAGSW; index=index+1) begin
        assign writein[`FLAGS_START + index] = shouldsetcpsr[index] 
                                                ? cpsrwd[index] 
                                                : out[`FLAGS_START + index]; 
    end

endmodule