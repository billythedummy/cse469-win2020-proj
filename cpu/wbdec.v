`include "defines.v"

// comb decoder for WB stage
module wbdec 
    (curr_instr,
    is_bl,
    mem_stage_in, curr_instr_addr_in,
    reg_we_out, reg_wa_out, reg_wd_out);

    input [`FULLW-1 : 0] curr_instr;

    input is_bl;
    input [`FULLW-1 : 0] mem_stage_in, curr_instr_addr_in;

    wire [`OP_TYPE_W-1 : 0] optype = curr_instr[`OP_TYPE_START +: `OP_TYPE_W];
    wire is_load = curr_instr[`LD_OR_STR_i];
    wire [`ALUAW-1 : 0] alu_opcode = curr_instr[`ALU_START +: `ALUAW];

    wire mutate_reg = optype[2:1] == `OP_DATA 
        & alu_opcode != `TST 
        & alu_opcode != `TEQ
        & alu_opcode != `CMP
        & alu_opcode != `CMN;

    output wire reg_we_out = mutate_reg 
        | ((optype[2:1] == `OP_LDSTR) & is_load)
        | is_bl;
    output wire [`REGAW-1 : 0] reg_wa_out = is_bl ? `LR_i : curr_instr[`RD_START_i +: `REGAW];
    output wire [`FULLW-1 : 0] reg_wd_out = is_bl ? curr_instr_addr_in + 4 : mem_stage_in;
endmodule