`include "defines.v"

localparam AND = 4'b0000; 
localparam EOR = 4'b0001; 
localparam SUB = 4'b0010;
localparam RSB = 4'b0011;  
localparam ADD = 4'b0100;
localparam ADC = 4'b0100; // ADD but add +1 if C flag is set, unsupported for now
localparam SBC = 4'b0110; // SUB but another -1 if C flag NOT set, unsupported for now
localparam RSC = 4'b0111; // shifter - Rn instead of Rn - shifter
localparam TST = 4'b1000; // just AND
localparam TEQ = 4'b1001; // just EOR
localparam CMP = 4'b1010; // just SUB
localparam CMN = 4'b1011; // just ADD
localparam ORR = 4'b1100; 
localparam PASS = 4'b1101; // passes shifter operand. Use this for MOV, etc
localparam BIC = 4'b1110; // Rd = Rn AND NOT(shifter)
localparam MVN = 4'b1111; // Rd = NOT shifter

module alu32
    (codein,
    Rn, shifter,
    out, flagsout);
    
    // CPSR: 0 - Zero, 1 - Carry, 2 - Negative, 3 - oVerflow
    input [`ALUAW-1:0] codein;
    input [`FULLW-1:0] Rn, shifter;

    output reg [`FULLW-1:0] out;
    output reg [3:0] flagsout; // always outputs flags. CPSR decides to write to self or not

    always @(*) begin
        case (codein)
            AND: out = Rn & shifter;
            EOR: out = Rn ^ shifter;
            SUB: out = Rn - shifter;
            RSB: out = shifter - Rn;
            ADD: out = Rn + shifter;
            TST: out = Rn & shifter;
            TEQ: out = Rn ^ shifter;
            CMP: out = Rn - shifter;
            CMN: out = Rn + shifter;
            ORR: out = Rn | shifter;
            PASS: out = shifter;
            BIC: out = Rn & (~shifter);
            MVN: out = ~shifter;
            default: out = 0; // for unsupported ops
        endcase
        flagsout[0] = out == 0;
        flagsout[2] = out[31];
    end

endmodule