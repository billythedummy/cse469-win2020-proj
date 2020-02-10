`include "defines.v"

localparam AND = 4'b0000; 
localparam EOR = 4'b0001; 
localparam SUB = 4'b0010;
localparam RSB = 4'b0011;  
localparam ADD = 4'b0100;
localparam ADC = 4'b0101; // ADD but add +1 if C flag is set, unsupported for now
localparam SBC = 4'b0110; // SUB but another -1 if C flag NOT set, unsupported for now
localparam RSC = 4'b0111; // shifter - Rn instead of Rn - shifter and another -1 f C flag, unsupported for now
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
    Rn, shifter, shiftercarryout,
    out, flagsout);
    
    // CPSR: 0 - Zero, 1 - Carry, 2 - Negative, 3 - oVerflow
    input [`ALUAW-1:0] codein;
    input [`FULLW-1:0] Rn, shifter;
    input shiftercarryout;

    wire [`FULLW : 0] Rn_exp, shifter_exp;
    assign Rn_exp = {1'b0, Rn};
    assign shifter_exp = {1'b0, shifter};
    reg [`FULLW : 0] out_exp;

    output wire [`FULLW-1:0] out;
    assign out = out_exp[`FULLW-1:0];
    output reg [`FLAGSW-1:0] flagsout; // always outputs flags. CPSR decides to write to self or not

    always @(*) begin
        case (codein)
            AND: begin
                out_exp = Rn_exp & shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            EOR: begin
                out_exp = Rn_exp ^ shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            SUB: begin
                out_exp = Rn_exp + ~shifter_exp + 1;
                flagsout[`C_i] = Rn >= shifter; // invert Rn < shifter note: unsigned comparison
                flagsout[`V_i] = (Rn[`FULLW-1] ^ shifter[`FULLW-1]) & ~(shifter[`FULLW-1] ^ out_exp[`FULLW-1]); // Rn and shifter have different signs, output has same sign as shifter 
            end
            RSB: begin
                out_exp = shifter_exp + ~Rn_exp + 1;
                flagsout[`C_i] = shifter >= Rn;
                flagsout[`V_i] = (Rn[`FULLW-1] ^ shifter[`FULLW-1]) & ~(Rn[`FULLW-1] ^ out_exp[`FULLW-1]);
            end
            ADD: begin
                out_exp = Rn_exp + shifter_exp;
                flagsout[`C_i] = out_exp[`FULLW];
                flagsout[`V_i] = ~(Rn[`FULLW-1] ^ shifter[`FULLW-1]) & (Rn[`FULLW-1] ^ out_exp[`FULLW-1]); // operands same sign but result different sign
            end
            TST: begin
                out_exp = Rn_exp & shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            TEQ: begin
                out_exp = Rn_exp ^ shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            CMP: begin
                out_exp = Rn_exp + ~shifter_exp + 1;
                flagsout[`C_i] = Rn >= shifter;
                flagsout[`V_i] = (Rn[`FULLW-1] ^ shifter[`FULLW-1]) & ~(shifter[`FULLW-1] ^ out_exp[`FULLW-1]);
            end
            CMN: begin
                out_exp = Rn_exp + shifter_exp;
                flagsout[`C_i] = out_exp[`FULLW];
                flagsout[`V_i] = ~(Rn[`FULLW-1] ^ shifter[`FULLW-1]) & (Rn[`FULLW-1] ^ out_exp[`FULLW-1]); 
            end
            ORR: begin
                out_exp = Rn_exp | shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            PASS: begin
                out_exp = shifter_exp;
                flagsout[`C_i] = 0; // don't care
                flagsout[`V_i] = 0; // don't care
            end
            BIC: begin
                out_exp = Rn_exp & (~shifter_exp);
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            MVN: begin
                out_exp = ~shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            default: begin
                out_exp = 0; // for unsupported ops
                flagsout[`C_i] = 0;
                flagsout[`V_i] = 0;
            end
        endcase
        // update Z and N flag
        flagsout[`Z_i] = (out_exp[`FULLW-1:0] == 0); // Z 
        flagsout[`N_i] = out_exp[`FULLW-1]; // N
    end

endmodule