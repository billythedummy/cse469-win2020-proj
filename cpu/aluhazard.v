`include "defines.v"

module aluhazard
    (prev_alu_opcode,
    curr_reg, prev_reg, 
    should_bypass);
    
    // CPSR: 0 - Zero, 1 - Carry, 2 - Negative, 3 - oVerflow
    input [`ALUAW-1:0] prev_alu_opcode;
    input [`REGAW-1:0] curr_reg, prev_reg;

    output should_bypass;

    always @(*) begin
        case (prev_alu_opcode)
            `TST: should_bypass = 0;
            `TEQ: should_bypass = 0;
            `CMP: should_bypass = 0;
            `CMN: should_bypass = 0;
            default: should_bypass = curr_reg == prev_reg;
        endcase
    end

endmodule