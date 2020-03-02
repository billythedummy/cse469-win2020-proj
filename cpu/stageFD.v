`include "defines.v"

module stageFD (
    instr_addr_in, 
    make_invalid_in, 
    stall_in, clk,
    rn_a_out, rm_a_out, rd_a_out,
    cond_out, optype_out, control_out, shifter_out, branch_imm_out,
    is_invalid_out
);

    input [`FULLW-1 : 0] instr_addr_in;
    input make_invalid_in, stall_in, clk;

    output wire [`REGAW-1 : 0] rn_a_out, rm_a_out, rd_a_out;
    output wire [`FLAGS_W-1 : 0] cond_out;
    output wire [`OP_TYPE_W-1 : 0] optype_out;
    output wire [`CONTROL_W-1 : 0] control_out;
    output wire [`SHIFTER_OPERAND_W-1 : 0] shifter_out;
    output wire [`BRANCHIMM_W - 1 : 0] branch_imm_out;
    output is_invalid_out;

    wire [`FULLW-1 : 0] instr_bus;

    ram #(.IS_INSTR(1)) instr_mem(.wa({`FULLW{1'b0}}), .we(1'b0), .wd({`FULLW{1'b0}}),
        .ra(instr_addr_in), .out(instr_bus), .clk(clk));
    
    preg #(.WIDTH(`REGAW)) rn_a_reg (.d(instr_bus[`RN_START_i +: `REGAW]), .q(rn_a_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`REGAW)) rd_a_reg (.d(instr_bus[`RD_START_i +: `REGAW];), .q(rd_a_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`REGAW)) rm_a_reg (.d(instr_bus[0 +: `REGAW]), .q(rm_a_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`FLAGS_W)) cond_reg (.d(instr_bus[`FLAGS_START +: `FLAGS_W]), .q(cond_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`OP_TYPE_W)) optype_reg (.d(instr_bus[`OP_TYPE_START +: `OP_TYPE_W), .q(optype_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`CONTROL_W)) control_reg (.d(instr_bus[`CONTROL_START +: `CONTROL_W]), .q(control_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(`SHIFTER_OPERAND_W)) shifter_reg (.d(instr_bus[0 +: `SHIFTER_OPERAND_W), .q(shifter_out), .stall(stall_in), .clk(clk));
    preg #(.WIDTH(1)) invalid_reg (.d(make_invalid_in), .q(is_invalid_out), .stall(stall_in), .clk(clk));

endmodule
