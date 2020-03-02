`include "defines.v"

localparam U_i = 3; // bit 23
localparam OP_DATA = 0;
localparam OP_LDSTR = 1;

module aludec
    (optype, in,
    alu_opcode, should_set_cpsr);
    // if store, rd is rn
    input optype; // only need bit 26 to differentiate between data and ldstr
    input [`CONTROL_W-1 : 0] in;

    output reg [`ALUAW-1 : 0] alu_opcode;
    output reg [`FLAGS_W-1 : 0] should_set_cpsr;

    always @(*) begin
        // to-do: bytes instead of words?
        case (optype)
            OP_DATA: begin
                alu_opcode = in[1 +: `ALUAW];
                should_set_cpsr = in[0] ? {(`FLAGS_W){1'b1}} : {(`FLAGS_W){1'b0}};
            end
            OP_LDSTR: begin
                alu_opcode = in[U_i] ? `ADD : `SUB;
                should_set_cpsr = 0;
            end
        endcase
    end

endmodule