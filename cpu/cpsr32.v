`include "defines.v"

module cpsr32
    (shouldsetcpsr,
    cpsrwd,
    out, clk);
    
    input clk;
    input [`FLAGSW-1:0] shouldsetcpsr, cpsrwd;
    output reg [`FULLW-1 : 0] out;

    reg [`FULLW-1 : 0] writein;
    register mem (.we(1), .d(writein), .q(out), .clk(clk));
    
    integer index;
    always @(*) begin
        writein[`FLAGS_START-1:0] = out[`FLAGS_START-1:0];
        for (index=0; index<`FLAGSW; index=index+1) begin
            writein[`FLAGS_START + index] = shouldsetcpsr[index] 
                                            ? cpsrwd[index]
                                            : out[`FLAGS_START + index];
        end
    end

endmodule