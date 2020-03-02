`include "defines.v"

module branchdec
    (optype, branch_imm,
    ib_out, bv_out);
    
    input [`OP_TYPE_W-1 : 0] optype; 
    input [`BRANCHIMM_W-1 : 0] branch_imm;

    output wire ib_out = optype == `OP_BRANCH;
    output wire [`FULLW-1 : 0] bv_out = {{(`FULLW-`BRANCH_SHIFT-`BRANCHIMM_W){branch_imm[`BRANCHIMM_W-1]}},
        branch_imm, {(`BRANCH_SHIFT){1'b0}} }; // sign extend and << 2

endmodule