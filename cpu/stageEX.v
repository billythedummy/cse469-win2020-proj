`include "defines.v"

module stageEX (
    rn_in, rm_in, rd_in,
    bypass_rm_in, should_bypass_rm_in,
    should_set_cpsr_in, alu_opcode_in,
    shiftcode_in, shiftby_in,
    cond_in,
    ib_in, bv_in, bl_in,
    reg_we_in, mem_we_in, should_bypass_data_in,
    make_invalid_in, stall_in,
    clk,
    alu_out, flagsout
    ib_out, bv_out, bl_out,
    reg_we_out, mem_we_out, should_bypass_data_out,
    is_invalid_out
);

    input [`FULLW-1 : 0] rn_in, rm_in, rd_in, bypass_rm_in;
    input should_bypass_rm_in;
    input [`FLAGS_W-1 : 0] should_set_cpsr_in;
    input [`ALUAW-1 : 0] alu_opcode_in;
    input [`SHIFTCODEW-1 : 0] shiftcode_in;
    input [`WIDTH-1 : 0] shiftby_in;
    input [`FLAGS_W-1 : 0] cond_in, cpsr_flags_in;
    input ib_in;
    input [`FULLW-1 :0 ] bv_in;
    input bl_in, reg_we_in, mem_we_in, should_bypass_data_in, make_invalid_in, stall_in;

    wire [`FULLW-1 : 0] shifter_in_bus, shifter_out_bus;
    wire [`FLAGS_W-1 : 0] alu_flags_write;

    simplemux #(.WIDTH(`FULLW)) rm_bypass_mux (.in1(rm_in), .in2(bypass_rm_in),
        .sel(should_bypass_rm_in),
        .out(shifter_in_bus));

    shifter32 shifter (.shiftby(shiftby_in), .shiftin(shifter_in_bus),
        .shiftcode(shiftcode_in),
        .cflag(cpsr_flags_in[`C_i]),
        .out(shifter_out_bus), .carryout(shifter_carry_out));

    alu32 alu (.codein(alu_opcode_bus), .Rn(rn_out_bus), .shifter(shifter_out_bus),
        .shiftercarryout(shifter_carry_out),
        .out(alu_out_d_bus), .flagsout(alu_flags_write));

    cpsr32 cpsr(.should_set_cpsr(
            should_set_cpsr_bus & {`FLAGS_W{~make_invalid_in}}
         ),
        .cpsrwd(alu_flags_write), .out(cpsr_bus), .clk(clk)
    );    

    preg #(.WIDTH(1)) invalid_reg (.d(make_invalid_in), .q(is_invalid_out), .stall(stall_in), .clk(clk));

endmodule
