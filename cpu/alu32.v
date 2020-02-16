`include "defines.v"

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
            `AND: begin
                out_exp = Rn_exp & shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            `EOR: begin
                out_exp = Rn_exp ^ shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            `SUB: begin
                out_exp = Rn_exp + ~shifter_exp + 1;
                flagsout[`C_i] = Rn >= shifter; // invert Rn < shifter note: unsigned comparison
                flagsout[`V_i] = (Rn[`FULLW-1] ^ shifter[`FULLW-1]) 
                    & ( ~(shifter[`FULLW-1] ^ out_exp[`FULLW-1]) 
                        | (out_exp[`FULLW-1:0] == 0) ); // Rn and shifter have different signs, output has same sign as shifter or zero
            end
            `RSB: begin
                out_exp = shifter_exp + ~Rn_exp + 1;
                flagsout[`C_i] = shifter >= Rn;
                flagsout[`V_i] = (Rn[`FULLW-1] ^ shifter[`FULLW-1]) & ~(Rn[`FULLW-1] ^ out_exp[`FULLW-1]);
            end
            `ADD: begin
                out_exp = Rn_exp + shifter_exp;
                flagsout[`C_i] = out_exp[`FULLW];
                flagsout[`V_i] = ~(Rn[`FULLW-1] ^ shifter[`FULLW-1]) 
                    & ( (Rn[`FULLW-1] ^ out_exp[`FULLW-1]) 
                        | (out_exp[`FULLW-1:0] == 0) ); // operands same sign but result different sign or 0
            end
            `TST: begin
                out_exp = Rn_exp & shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            `TEQ: begin
                out_exp = Rn_exp ^ shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            `CMP: begin
                out_exp = Rn_exp + ~shifter_exp + 1;
                flagsout[`C_i] = Rn >= shifter;
                flagsout[`V_i] = (Rn[`FULLW-1] ^ shifter[`FULLW-1]) & ~(shifter[`FULLW-1] ^ out_exp[`FULLW-1]);
            end
            `CMN: begin
                out_exp = Rn_exp + shifter_exp;
                flagsout[`C_i] = out_exp[`FULLW];
                flagsout[`V_i] = ~(Rn[`FULLW-1] ^ shifter[`FULLW-1]) & (Rn[`FULLW-1] ^ out_exp[`FULLW-1]); 
            end
            `ORR: begin
                out_exp = Rn_exp | shifter_exp;
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            `PASS: begin
                out_exp = shifter_exp;
                flagsout[`C_i] = 0; // don't care
                flagsout[`V_i] = 0; // don't care
            end
            `BIC: begin
                out_exp = Rn_exp & (~shifter_exp);
                flagsout[`C_i] = shiftercarryout;
                flagsout[`V_i] = 0; // don't care
            end
            `MVN: begin
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