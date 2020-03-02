`include "defines.v"

module cpu(
  input wire clk,
  input wire nreset,
  output wire led,
  output wire [7:0] debug_port1,
  output wire [7:0] debug_port2,
  output wire [7:0] debug_port3,
  output wire [7:0] debug_port4,
  output wire [7:0] debug_port5,
  output wire [7:0] debug_port6,
  output wire [7:0] debug_port7
  );

  // Controls the LED on the board.
  assign led = 1'b1;

  // These are how you communicate back to the serial port debugger.
  assign debug_port1 = instr_addr_FD[7:0];
  assign debug_port2 = 8'b0; 
  assign debug_port3 = {4'b0, instr_FDRE[`RD_START_i +: `REGAW]}; // RE rd
  assign debug_port4 = rd_REEX[7:0]; 
  assign debug_port5 = alu_out_EXME[7:0];
  assign debug_port6 = reg_wd[7:0];
  assign debug_port7 = {7'b0, nreset};

  wire dummy0 = 1'b0;
  wire dummy1 = 1'b1;
  wire reset = `IS_SIM ? 1'b0 : ~nreset;
  wire [`PHASES-1 : 0] stall_bits;

  // phase 0: Instr Fetch and decode
  pc32 pc (.ib(ib), .bv(bv), .we(pc_we_final), .wd(reg_wd),
    .iaddrout(instr_addr_FD), .reset(reset), .mod_en(~stall_bits[`FETCH_PHASE]),
    .clk(clk)
  );
  
  wire [`FULLW-1 : 0] instr_FD, instr_addr_FD, instr_FDRE, instr_addr_FDRE;

  ram #(.IS_INSTR(1)) instr_mem(.wa({`FULLW{dummy0}}), .we(dummy0), .wd({`FULLW{dummy0}}),
    .ra(instr_addr_FD), .out(instr_FD), .clk(clk));

  wire set_FD_invalid = ib;
  wire invalid_FDRE;

  preg #(.WIDTH(`FULLW)) instr_FDRE_reg (.d(instr_FD), .q(instr_FDRE), .stall(stall_bits[`FETCH_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_addr_FDRE_reg (.d(instr_addr_FD), .q(instr_addr_FDRE), .stall(stall_bits[`FETCH_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) FD_invalid_reg (.d(set_FD_invalid), .q(invalid_FDRE), .stall(stall_bits[`FETCH_PHASE]), .clk(clk));

  // phase 1: Register access
  reg32 registers(.rn_a(instr_FDRE[`RN_START_i +: `REGAW]),
    .rm_a(instr_FDRE[`RM_START_i +: `REGAW]),
    .rd_a(instr_FDRE[`RD_START_i +: `REGAW]),
    .we(reg_we_final), .wd(reg_wd), .wa(reg_wa),
    .rn_out(rn_RE), .rm_out(rm_RE), .rd_out(rd_RE),
    .clk(clk));

  wire [`FULLW-1 : 0] rn_RE, rn_REEX, rm_RE, rm_REEX, rd_RE, rd_REEX;
  wire [`FULLW-1 : 0] instr_REEX, instr_addr_REEX;
  wire set_RE_invalid = ib;
  wire invalid_REEX;

  preg #(.WIDTH(`FULLW)) rn_REEX_reg (.d(rn_RE), .q(rn_REEX), .stall(stall_bits[`REG_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) rm_REEX_reg (.d(rm_RE), .q(rm_REEX), .stall(stall_bits[`REG_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) rd_REEX_reg (.d(rd_RE), .q(rd_REEX), .stall(stall_bits[`REG_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_REEX_reg (.d(instr_FDRE), .q(instr_REEX), .stall(stall_bits[`FETCH_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_addr_REEX_reg (.d(instr_addr_FDRE), .q(instr_addr_REEX), .stall(stall_bits[`FETCH_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) RE_invalid_reg (.d(set_RE_invalid | invalid_FDRE), .q(invalid_REEX), .stall(stall_bits[`FETCH_PHASE]), .clk(clk));

  // phase 2: Exec
  condchecker cchecker (.codein(instr_REEX[`FLAGS_START +: `FLAGS_W]),
    .cpsrin(cpsr_out[`FLAGS_START +: `FLAGS_W]),
    .shouldexecout(should_exec)
  );

  wire should_exec;
  wire is_ex_valid = should_exec & ~invalid_REEX;

  shifterdec sdec (.optype(instr_REEX[`OP_TYPE_START +: `OP_TYPE_W]),
    .in(instr_REEX[0+:`SHIFTER_OPERAND_W]),
    .bypass_rm(bypass_rm), .should_bypass_rm(should_bypass_rm),
    .shiftcode(shiftcode), .shiftby(shiftby));

  wire [`FULLW-1 : 0] bypass_rm;
  wire should_bypass_rm;
  wire [`SHIFTCODEW-1:0] shiftcode;
  wire [`WIDTH-1:0] shiftby;

/*
  aluhazard rm_hazard_detector (
    .prev_instr(alu_opcode_EXME),
    .curr_reg(instr_REEX[`RM_START_i +: `REGAW]),
    .should_bypass(rm_has_hazard)
  );
*/

  wire rm_has_hazard;

  simplemux #(.WIDTH(`FULLW)) rm_hazard_mux(.in1(rm_REEX), .in2(alu_out_EXME),
    .sel(rm_has_hazard),
    .out(rm_EX)
  );

  wire [`FULLW-1 : 0] rm_EX;

  simplemux #(.WIDTH(`FULLW)) rm_bypass_mux (.in1(rm_EX), .in2(bypass_rm),
    .sel(should_bypass_rm),
    .out(shifter_operand));

  wire [`FULLW-1 : 0] shifter_operand;
  
  shifter32 shifter (.shiftby(shiftby), .shiftin(shifter_operand),
    .shiftcode(shiftcode),
    .cflag(cpsr_out[`FLAGS_START + `C_i]),
    .out(shifter_out), .carryout(shifter_carry_out));

  wire shifter_carry_out;
  wire [`FULLW-1 : 0] shifter_out;

  aludec adec (.optype(instr_REEX[`OP_TYPE_START +: `OP_TYPE_W]),
    .control(instr_REEX[`CONTROL_START +: `CONTROL_W]),
    .alu_opcode(alu_opcode), 
    .should_set_cpsr(should_set_cpsr));

  wire [`ALUAW-1 : 0] alu_opcode, alu_opcode_EXME;
  wire [`FLAGS_W-1 : 0] should_set_cpsr;

  alu32 alu (.codein(alu_opcode), .Rn(rn_REEX), .shifter(shifter_out),
    .shiftercarryout(shifter_carry_out), .out(alu_out_EX), .flagsout(alu_flags_write));

  wire [`FULLW-1 : 0] alu_out_EX, alu_out_EXME;
  wire [`FLAGS_W-1 : 0] alu_flags_write;
  
  cpsr32 cpsr (.should_set_cpsr(
      should_set_cpsr & {`FLAGS_W{is_ex_valid}}
    ),
    .cpsrwd(alu_flags_write), .out(cpsr_out), .clk(clk));
  
  wire [`FULLW-1 : 0] cpsr_out;

  branchdec bdec (.optype(instr_REEX[`OP_TYPE_START +: `OP_TYPE_W]),
    .branch_imm(instr_REEX[0 +: `BRANCHIMM_W]),
    .ib_out(ib_nocond), .bv_out(bv));

  wire ib_nocond;
  wire ib = ib_nocond & is_ex_valid; // goes back to PC
  wire [`FULLW-1 : 0] bv;

  wire [`FULLW-1 : 0] rd_EXME;

  wire bl_EXME;

  wire [`FULLW-1 : 0] instr_EXME, instr_addr_EXME;
  wire set_EX_invalid = ~is_ex_valid;
  wire invalid_EXME;

  preg #(.WIDTH(`FULLW)) alu_out_EXME_reg (.d(alu_out_EX), .q(alu_out_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(`ALUAW)) alu_opcode_EXME_reg(.d(alu_opcode), .q(alu_opcode_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) rd_EXME_reg (.d(rd_REEX), .q(rd_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) bl_EXME_reg (.d(ib & instr_REEX[`BL_i]), .q(bl_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_EXME_reg (.d(instr_REEX), .q(instr_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_addr_EXME_reg (.d(instr_addr_REEX), .q(instr_addr_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) EX_invalid_reg (.d(set_EX_invalid | invalid_REEX), .q(invalid_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));

  // phase 3: mem access
  wire [`FULLW-1 : 0] mem_out, mem_out_MEWB;
  wire [`OP_TYPE_W-1 : 0]optype_ME = instr_EXME[`OP_TYPE_START +: `OP_TYPE_W];

  ram data_mem(.wd(rd_EXME), .wa(alu_out_EXME),
    .we(
      optype_ME[2:1] == `OP_LDSTR & ~instr_EXME[`LD_OR_STR_i] & ~invalid_EXME
    ),
    .ra(alu_out_EXME), .out(mem_out),
    .clk(clk));
  
  wire [`FULLW-1 : 0] alu_out_MEWB;

  wire bl_MEWB;

  wire [`FULLW-1 : 0] instr_MEWB, instr_addr_MEWB;
  wire invalid_MEWB;

  preg #(.WIDTH(`FULLW)) mem_MEWB_reg (.d(mem_out), .q(mem_out_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) alu_out_MEWB_reg (.d(alu_out_EXME), .q(alu_out_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) bl_MEWB_reg (.d(bl_EXME), .q(bl_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_MEWB_reg (.d(instr_EXME), .q(instr_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_addr_MEWB_reg (.d(instr_addr_EXME), .q(instr_addr_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) ME_invalid_reg (.d(invalid_EXME), .q(invalid_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));

  // phase 4: reg writeback
  wire reg_we;
  wire [`FULLW-1 : 0] mem_or_alu, reg_wd;
  wire [`REGAW-1 : 0] reg_wa;
  wire [`OP_TYPE_W-1 : 0] optype_WB = instr_MEWB[`OP_TYPE_START +: `OP_TYPE_W];

  simplemux #(.WIDTH(`FULLW)) data_bypass_mux (.in1(mem_out_MEWB), .in2(alu_out_MEWB),
    .sel(~(optype_WB[2:1] == `OP_LDSTR)),
    .out(mem_or_alu));
    
  wbdec writebackdec (
    .curr_instr(instr_MEWB),
    .is_bl(bl_MEWB),
    .mem_stage_in(mem_or_alu),
    .curr_instr_addr_in(instr_addr_MEWB),
    .reg_we_out(reg_we),
    .reg_wa_out(reg_wa),
    .reg_wd_out(reg_wd)
  );

  wire pc_we_final = reg_we & (reg_wa == `PC_i) & ~invalid_MEWB;
  wire reg_we_final = reg_we & ~invalid_MEWB;

  
  // Note: cant do this in synthesis  
  initial begin
    if (`IS_SIM) begin
      $readmemh("../../testcode/hexcode_tests/lab2_instr.mem", instr_mem.mem);
    end
  end
endmodule
