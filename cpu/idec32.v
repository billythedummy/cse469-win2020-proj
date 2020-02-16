`include "defines.v"

module idec32  //instruction decoder
    (i_in, cpsr_in,
    alu_opcode_out,
    rn_a_out, rd_a_out, rm_a_out,
    bypass_rm_out, should_bypass_rm_out,
    should_set_cpsr_out,
    reg_we_out, mem_we_out,
    shiftcode_out, shiftby_out,
    should_bypass_data_out,
    ib_out, bv_out, bl_out);
    // instruction in, CPSR in, is previous instruction branch in
    // ALU out, Rn out, Rd out, 
    // should set CPSR out, register write enable, memory write enable,
    // instruction branch out, branch value out, branch should link (store in r14)
    // clock

    // rd goes to register write and rd
    // rm goes to shifter
    // rn unaffected

    input [`FULLW-1 : 0] i_in;
    input [`FLAGSW-1 : 0] cpsr_in;

    // dont really care if comb logic goes through, state doesnt change
    // long as registers dont change:
    // reg_we_out, mem_we_out, ib_out, should_set_cpsr_out

    output wire [`ALUAW-1 : 0] alu_opcode_out;
    output wire [`REGAW-1 : 0] rn_a_out, rd_a_out, rm_a_out;
    output wire reg_we_out, mem_we_out, bl_out;
    output wire ib_out, should_bypass_rm_out;
    output wire [`FLAGSW-1 : 0] should_set_cpsr_out;
    output wire [`FULLW-1 : 0] bv_out, bypass_rm_out;
    output wire [`WIDTH-1 : 0] shiftby_out;
    output wire [`SHIFTCODEW-1 : 0] shiftcode_out;
    output wire should_bypass_data_out;

    wire [`OP_TYPE_W-1 : 0] optype = i_in[`OP_TYPE_START +: `OP_TYPE_W];
    wire shouldexec;
    wire [`FLAGSW-1 : 0] should_set_cpsr;
    wire is_load = i_in[`LD_OR_STR_i];
    wire is_bl = i_in[`BL_i] & (optype == `OP_BRANCH);
    wire shouldwritereg = (optype[2:1] == `OP_DATA) 
        | ((optype[2:1] == `OP_LDSTR) & is_load)
        | is_bl;

    condchecker check (.codein(i_in[`FLAGS_START +: `FLAGSW]), .cpsrin(cpsr_in),
        .shouldexecout(shouldexec));

    shifterdec sdec (.optype(optype), .in(i_in[0+:`SHIFTER_OPERAND_W]),
        .rm(rm_a_out), .bypass_rm(bypass_rm_out),
        .should_bypass_rm(should_bypass_rm_out),
        .shiftcode(shiftcode_out), .shiftby(shiftby_out));

    aludec adec (.optype(i_in[`LDSTR_OR_DATA_i]),
        .in(i_in[`CONTROL_START +: `CONTROLW]),
        .alu_opcode(alu_opcode_out), .should_set_cpsr(should_set_cpsr));

    // write enables for mem, reg, cpsr
    assign reg_we_out = shouldexec & shouldwritereg; 
    assign mem_we_out = shouldexec & ((optype[2:1] == `OP_LDSTR) & (~is_load)); // L = 0 means store
    assign should_set_cpsr_out = shouldexec ? {`FLAGSW{1'b0}} : should_set_cpsr;

    // branching
    assign bl_out = is_bl;
    assign ib_out = shouldexec & (optype == `OP_BRANCH);
    assign bv_out = {{(`FULLW-`BRANCH_SHIFT-`BRANCHIMM_W){i_in[`BRANCHIMM_W-1]}},
        i_in[0+:`BRANCHIMM_W], {(`BRANCH_SHIFT){1'b0}} }; // sign extend and << 2
    
    // register select
    assign rn_a_out = i_in[`RN_START_i +: `REGAW];
    // if bl, rd should be Link Register
    assign rd_a_out = is_bl ? `LR_i : i_in[`RD_START_i +: `REGAW];
    // rm_a_out set by shifterdec

    // should get data from ALU or register
    assign should_bypass_data_out = ~(optype[2:1] == `OP_LDSTR);
endmodule