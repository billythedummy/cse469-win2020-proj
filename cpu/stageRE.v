`include "defines.v"

module stageRE (
    rn_a_in, rm_a_in, rd_a_in,
    cond_in, optype_in, control_in, shifter_in, branch_imm_in,
    reg_we_final_in, reg_wd_in, reg_wa_in,
    make_invalid_in, stall_in,
    clk,
    rn_out, rm_out, rd_out,
    bypass_rm_out, should_bypass_rm_out,
    should_set_cpsr_out, alu_opcode_out,
    shiftcode_out, shiftby_out,
    cond_out,
    ib_out, bv_out, bl_out,
    reg_we_out, mem_we_out, should_bypass_data_out,
    is_invalid_out
);
    input [`REGAW-1 : 0] rn_a_in, rm_a_in, rd_a_in;
    input [`FLAGS_W-1 : 0] cond_in;
    input [`OP_TYPE_W-1 : 0] optype_in;
    input [`CONTROL_W-1 : 0] control_in;
    input [`SHIFTER_OPERAND_W-1 : 0] shifter_in;
    input [`BRANCHIMM_W-1 : 0] branch_imm_in;
    input reg_we_final_in;
    input [`FULLW-1 : 0] reg_wd_in;
    input [`REGAW-1 : 0] reg_wa_in; 
    input make_invalid_in, stall_in, clk;

    output [`FULLW-1 : 0] rn_out, rm_out, rd_out, bypass_rm_out;
    output should_bypass_rm_out;
    output [`FLAGS_W-1 : 0] should_set_cpsr_out;
    output [`ALUAW-1 : 0] alu_opcode_out;
    output [`SHIFTCODEW-1 : 0] shiftcode_out;
    output [`WIDTH-1 : 0] shiftby_out;
    output [`FLAGS_W-1 : 0] cond_out;
    output ib_out;
    output [`FULLW-1 :0 ] bv_out;
    output bl_out, reg_we_out, mem_we_out, should_bypass_data_out, is_invalid_out;

    reg32 registers(.rn_a(rn_a_in), .rm_a(rm_a_in),
        .we(reg_we_final_in), .wd(reg_wd_in), .wa(reg_wa_in),
        .rn_out(rn), .rm_out(rm), .rd_out(rd),
        .clk(clk));
    wire [`FULLW-1 : 0] rn, rm, rd;
    preg #(.WIDTH(`FULLW)) rn_reg (.d(rn), .q(rn_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`FULLW)) rm_reg (.d(rm), .q(rm_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`FULLW)) rd_reg (.d(rd), .q(rd_out), .stall(stall_in), .clk(clk));

    shifterdec sdec (.optype(optype_in), .in(shifter_in),
        .bypass_rm(bypass_rm),
        .should_bypass_rm(should_bypass_rm),
        .shiftcode(shiftcode), .shiftby(shiftby));
    wire [`FULLW-1 : 0] bypass_rm;
    wire should_bypass_rm;
    wire [`SHIFTCODEW-1 : 0] shiftcode;
    wire [`WIDTH-1 : 0] shiftby;
    preg #(.WIDTH(`FULLW)) bypass_rm_reg (.d(bypass_rm), .q(bypass_rm_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(1)) should_bypass_rm_reg(.d(should_bypass_rm), .q(should_bypass_rm_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`SHIFTCODEW)) shiftcode_reg (.d(shiftcode), .q(shiftcode_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`WIDTH)) shiftby_reg (.d(shiftby), .q(shiftby_out), .stall(stall_in), .clk(clk));

    aludec adec (.optype(optype_in[`LDSTR_OR_DATA_OFFSET]),
        .in(control_in),
        .alu_opcode(alu_opcode), .should_set_cpsr(should_set_cpsr));
    wire [`ALUAW-1 : 0] alu_opcode;
    wire [`FLAGS_W-1 : 0] should_set_cpsr;
    preg #(.WIDTH(`ALUAW)) alu_opcode_reg (.d(alu_opcode), .q(alu_opcode_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`FLAGS_W)) should_set_cpsr_reg(.d(should_set_cpsr), .q(should_set_cpsr_out), .stall(stall_in), .clk(clk));

    preg #(.WIDTH(1)) ib_reg(.d(optype_in == `OP_BRANCH), .q(ib_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`FULLW)) bv_reg(.d(
        {{(`FULLW-`BRANCH_SHIFT-`BRANCHIMM_W){branch_imm_in[`BRANCHIMM_W-1]}},
            branch_imm_in, {(`BRANCH_SHIFT){1'b0}} }
    ), .q(bv_out), .stall(stall_in), .clk(clk));
    wire is_bl = control_in[`BL_OFFSET] & optype_in == `OP_BRANCH;
    preg #(.WIDTH(1)) bl_reg(.d(is_bl), .q(ib_out), .stall(stall_in), .clk(clk));

    wire is_load = control_in[`LD_OR_STR_OFFSET];
    preg #(.WIDTH(1)) mem_we_out_reg(.d(
        (optype_in[2:1] == `OP_LDSTR) & (~is_load)
    ), .q(mem_we_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(1)) should_bypass_data_reg(.d(
        ~(optype_in[2:1] == `OP_LDSTR)
    ), .q(should_bypass_data_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(1)) reg_we_reg(.d(
        (optype_in[2:1] == `OP_DATA) 
        | ((optype_in[2:1] == `OP_LDSTR) & is_load)
        | is_bl
    ), .q(reg_we_out), .stall(stall_in), .clk(clk));

    preg #(.WIDTH(`FLAGS_W)) cond_reg(.d(cond_in), .q(cond_out), .stall(stall_in), .clk(clk));

    preg #(.WIDTH(1)) invalid_reg (.d(make_invalid_in), .q(is_invalid_out), .stall(stall_in), .clk(clk));

endmodule
