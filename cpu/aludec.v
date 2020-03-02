`include "defines.v"

localparam U_i = 3; // bit 23

module aludec
    (optype, control,
    alu_opcode, should_set_cpsr);
    
    input [`OP_TYPE_W-1 : 0] optype; 
    input [`CONTROL_W-1 : 0] control;

    output reg [`ALUAW-1 : 0] alu_opcode;
    output reg [`FLAGS_W-1 : 0] should_set_cpsr;

    always @(*) begin
        // to-do: bytes instead of words?
        case (optype)
            `OP_DATA_SHIFT: begin
                alu_opcode = control[1 +: `ALUAW];
                should_set_cpsr = control[0] ? {(`FLAGS_W){1'b1}} : 0;
            end
            `OP_DATA_ROR: begin
                alu_opcode = control[1 +: `ALUAW];
                should_set_cpsr = control[0] ? {(`FLAGS_W){1'b1}} : 0;
            end
            `OP_LDSTR_IMM: begin
                alu_opcode = control[U_i] ? `ADD : `SUB;
                should_set_cpsr = 0;
            end
            `OP_LDSTR_REG: begin
                alu_opcode = control[U_i] ? `ADD : `SUB;
                should_set_cpsr = 0;
            end
            default begin // op branch
                alu_opcode = `PASS;
                should_set_cpsr = 0;
            end
        endcase
    end

endmodule