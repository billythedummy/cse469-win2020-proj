`include "defines.v"

module idec32  //instruction decoder
    (i_in, cpsr_in, ispb_in,
    alu_opcode_out,
    rn_out, rd_out, rm_out,
    bypass_rm_out, should_bypass_rm_out,
    should_set_cpsr_out,
    reg_we_out, mem_we_out,
    shiftcode_out, shiftby_out,
    ib_out, bv_out, bl_out);
    // instruction in, CPSR in, is previous instruction branch in
    // ALU out, Rn out, Rd out, 
    // should set CPSR out, register write enable, memory write enable,
    // instruction branch out, branch value out, branch should link (store in r14)
    // clock

    // rd goes to register write
    // rm goes to shifter
    // rn unaffected

    input [`FULLW-1 : 0] i_in;
    input [`FLAGSW-1 : 0] cpsr_in;
    input ispb_in;

    // dont really care if comb logic goes through, state doesnt change
    // long as registers dont change:
    // reg_we_out, mem_we_out, ib_out, should_set_cpsr_out

    output reg [`ALUAW-1 : 0] alu_opcode_out;
    output reg [`REGAW-1 : 0] rn_out, rd_out, rm_out;
    output reg reg_we_out, mem_we_out, bl_out;
    output reg ib_out, should_bypass_rm_out;
    output reg [`FLAGSW-1 : 0] should_set_cpsr_out;
    output reg [`FULLW-1 : 0] bv_out, bypass_rm_out;
    output reg [`WIDTH-1 : 0] shiftby_out;
    output reg [`SHIFTCODEW-1 : 0] shiftcode_out;

    wire [`OP_TYPE_W-1 : 0] optype;
    wire shouldexec;
    assign optype = i_in[`OP_TYPE_START +: `OP_TYPE_W];
    wire [`FLAGSW-1 : 0] should_set_cpsr;
    wire is_load;
    assign is_load = i_in[`LD_OR_STR_i];
    wire shouldwritereg;
    assign shouldwritereg = (optype[2:1] == `OP_DATA) 
        | ((optype[2:1] == `OP_LDSTR) & is_load);
    wire [`ALUAW-1 : 0] rm;

    condchecker check (.codein(i_in[`FLAGS_START +: `FLAGSW]), .cpsrin(cpsr_in),
        .shouldexecout(shouldexec));

    shifterdec sdec (.optype(optype), .in(i_in[0+:`SHIFTER_OPERAND_W]),
        .rm(rm), .bypass_rm(bypass_rm_out),
        .should_bypass_rm(should_bypass_rm_out),
        .shiftcode(shiftcode_out), .shiftby(shiftby_out));

    aludec adec (.optype(i_in[`LDSTR_OR_DATA_i]),
        .in(i_in[`CONTROL_START +: `CONTROLW]),
        .alu_opcode(alu_opcode_out), .should_set_cpsr(should_set_cpsr));

    always @(*) begin
        reg_we_out = shouldexec & shouldwritereg; 
        mem_we_out = shouldexec & ((optype[2:1] == `OP_LDSTR) & (~is_load)); // L = 0 means store
        ib_out = shouldexec & (optype == `OP_BRANCH); 
        should_set_cpsr_out = shouldexec ? {`FLAGSW{1'b0}} : should_set_cpsr;
        // rd and rn
        rn_out = i_in[`RN_START_i +: `REGAW];
        rd_out = i_in[`RD_START_i +: `REGAW];
        rm_out = ((optype[2:1] == `OP_LDSTR) & (~is_load)) // if store, rm=rd since rd is data to be written
            ? rd_out
            : rm;
        // branching
        bl_out = i_in[`BL_i];
        bv_out = {{(`FULLW-`BRANCH_SHIFT-`BRANCHIMM_W){i_in[`BRANCHIMM_W-1]}},
            i_in[0+:`BRANCHIMM_W], {(`BRANCH_SHIFT){1'b0}} }; // sign extend and << 2
    end


endmodule