`include "defines.v"

module branchdec
    (instr,
    ib_out, bv_out,
    pc_we_out);
    
    input [`FULLW-1 : 0] instr;

    wire [`OP_TYPE_W-1 : 0] optype = instr[`OP_TYPE_START +: `OP_TYPE_W]; 
    wire [`BRANCHIMM_W-1 : 0] branch_imm = instr[0 +: `BRANCHIMM_W];
    wire [`ALUAW-1 : 0] alu_opcode = instr[`ALU_START +: `ALUAW];
    wire mutate_reg = optype[2:1] == `OP_DATA 
        & alu_opcode != `TST 
        & alu_opcode != `TEQ
        & alu_opcode != `CMP
        & alu_opcode != `CMN;
    wire [`REGAW-1 : 0] rd = instr[`RD_START_i +: `REGAW];

    output wire ib_out = optype == `OP_BRANCH;
    output wire [`FULLW-1 : 0] bv_out = {{(`FULLW-`BRANCH_SHIFT-`BRANCHIMM_W){branch_imm[`BRANCHIMM_W-1]}},
        branch_imm, {(`BRANCH_SHIFT){1'b0}} }; // sign extend and << 2
    output wire pc_we_out = rd == `PC_i & mutate_reg;

endmodule
