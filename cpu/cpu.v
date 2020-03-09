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
  assign debug_port2 = instr_addr_FDRE[7:0]; 
  assign debug_port3 = instr_addr_REEX[7:0];
  assign debug_port4 = rn_EX[31:24]; //instr_addr_EXME[7:0]; 
  assign debug_port5 = shifter_out[31:24]; //{7'b0, is_ex_valid};
  assign debug_port6 = {4'b0, alu_flags_write}; //{7'b0, ib};
  assign debug_port7 = {7'b0, is_ex_valid}; //cpsr_out[31:24];

  wire dummy0 = 1'b0;
  wire dummy1 = 1'b1;
  wire reset = `IS_SIM ? 1'b0 : ~nreset;
  wire [`PHASES-1 : 0] stall_bits;

  // phase 0: Instr Fetch and decode
  preg #(.WIDTH(1)) pre_FD_invalid_reg (.d(pc_modified), .q(invalid_pre_FD), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  wire invalid_pre_FD;

  pc32 pc (.ib(ib), .bv(bv), .we(pc_we_final), .wd(alu_out_EX),
    .iaddrout(curr_instr_addr), .reset(reset), .mod_en(~stall_bits[`FETCH_PHASE]),
    .clk(clk)
  );
  wire [`FULLW-1 : 0] curr_instr_addr;
  
  dff #(.WIDTH(`FULLW)) instr_addr_dff (.d(curr_instr_addr), .q(prev_instr_addr_cache), .clk(clk));
  wire [`FULLW-1 : 0] prev_instr_addr_cache;
  simplemux #(.WIDTH(`FULLW)) instr_stall_mux (.in1(curr_instr_addr), .in2(prev_instr_addr_cache),
    .sel(stall_bits[`FETCH_PHASE]), .out(instr_addr_FD)
  );

  wire [`FULLW-1 : 0] instr_addr_FD, instr_FDRE, instr_addr_FDRE;

  ram #(.IS_INSTR(1)) instr_mem(.wa({`FULLW{dummy0}}), .we(dummy0), .wd({`FULLW{dummy0}}),
    .ra(instr_addr_FD), .out(instr_FDRE), .clk(clk));
  //wire [`FULLW-1 : 0] curr_instr;

  wire invalid_FDRE;

  wire pc_modified = ib | pc_we_final;

  preg #(.WIDTH(`FULLW)) instr_addr_FDRE_reg (.d(instr_addr_FD), .q(instr_addr_FDRE), .stall(stall_bits[`FETCH_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) FD_invalid_reg (.d(invalid_pre_FD | pc_modified), .q(invalid_FDRE), .stall(stall_bits[`FETCH_PHASE]), .clk(clk));

  // phase 1: Register access
  wire [`REGAW-1 : 0] rn_a_RE = instr_FDRE[`RN_START_i +: `REGAW];
  wire [`REGAW-1 : 0] rm_a_RE = instr_FDRE[`RM_START_i +: `REGAW];
  wire [`REGAW-1 : 0] rd_a_RE = instr_FDRE[`RD_START_i +: `REGAW];

  reg32 registers(.rn_a(rn_a_RE), .rm_a(rm_a_RE), .rd_a(rd_a_RE),
    .we(reg_we_final), .wd(reg_wd), .wa(reg_wa),
    .rn_out(rn_from_reg_REEX),
    .rm_out(rm_from_reg_REEX),
    .rd_out(rd_from_reg_REEX),
    .clk(clk));

  wire [`FULLW-1 : 0] rn_from_reg_REEX, rm_from_reg_REEX, rd_from_reg_REEX;

  wire [`FULLW-1 : 0] prev_reg_wd_REEX;
  wire [`REGAW-1 : 0] prev_reg_wa_REEX;
  wire prev_reg_we_REEX, prev_pc_we_REEX;

  wire [`FULLW-1 : 0] instr_REEX, instr_addr_REEX;
  wire invalid_REEX;

  preg #(.WIDTH(`FULLW)) prev_reg_wd (.d(reg_wd), .q(prev_reg_wd_REEX), .stall(stall_bits[`REG_PHASE]), .clk(clk));
  preg #(.WIDTH(`REGAW)) prev_reg_wa (.d(reg_wa), .q(prev_reg_wa_REEX), .stall(stall_bits[`REG_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) prev_reg_we (.d(reg_we_final), .q(prev_reg_we_REEX), .stall(stall_bits[`REG_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) prev_pc_we (.d(pc_we_final), .q(prev_pc_we_REEX), .stall(stall_bits[`REG_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_REEX_reg (.d(instr_FDRE), .q(instr_REEX), .stall(stall_bits[`REG_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_addr_REEX_reg (.d(instr_addr_FDRE), .q(instr_addr_REEX), .stall(stall_bits[`REG_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) RE_invalid_reg (.d(pc_modified | invalid_FDRE), .q(invalid_REEX), .stall(stall_bits[`REG_PHASE]), .clk(clk));

  // phase 2: Exec
  condchecker cchecker (.codein(instr_REEX[`FLAGS_START +: `FLAGS_W]),
    .cpsrin(cpsr_out[`FLAGS_START +: `FLAGS_W]),
    .shouldexecout(should_exec)
  );

  wire should_exec;
  wire is_ex_valid = should_exec & ~invalid_REEX;

  shifterdec sdec (.optype(instr_REEX[`OP_TYPE_START +: `OP_TYPE_W]),
    .in(instr_REEX[0+:`SHIFTER_OPERAND_W]),
    .bypass_rm(bypass_rm), .should_bypass_rm(imm_should_bypass_rm),
    .shiftcode(shiftcode), .shiftby(shiftby));

  wire [`FULLW-1 : 0] bypass_rm;
  wire imm_should_bypass_rm;
  wire [`SHIFTCODEW-1:0] shiftcode;
  wire [`WIDTH-1:0] shiftby;

  wire [`REGAW-1 : 0] rn_a_EX = instr_REEX[`RN_START_i +: `REGAW];
  wire [`REGAW-1 : 0] rm_a_EX = instr_REEX[`RM_START_i +: `REGAW];
  wire [`REGAW-1 : 0] rd_a_EX = instr_REEX[`RD_START_i +: `REGAW];

  // hazard from ME stage should take precedence i.e. muxed last

  simplemux #(.WIDTH(`FULLW)) pc_wb_hazard (.in1(instr_addr_FD), .in2(prev_reg_wd_REEX),
    .sel(prev_pc_we_REEX), .out(curr_pc_val)
  );
  wire [`FULLW-1 : 0] curr_pc_val;

  // rm hazard processing
  // rm wb hazard
  simplemux #(.WIDTH(`FULLW)) rm_wb_hazard_mux (.in1(rm_from_reg_REEX), .in2(prev_reg_wd_REEX),
    .sel( prev_reg_we_REEX & rm_a_EX == prev_reg_wa_REEX), .out(rm_wb_hazard_nopc)
  );

  wire [`FULLW-1 : 0] rm_wb_hazard_nopc;

  simplemux #(.WIDTH(`FULLW)) rm_is_pc (.in1(rm_wb_hazard_nopc), .in2(curr_pc_val),
    .sel(rm_a_EX == `PC_i), .out(rm_wb_hazard)
  );

  wire [`FULLW-1 : 0] rm_wb_hazard;

  // rm load hazard  
  simplemux #(.WIDTH(`FULLW)) rm_mem_hazard_mux(.in1(rm_wb_hazard), .in2(mem_out_MEWB),
    .sel(rm_has_mem_hazard_MEWB),
    .out(rm_mem_hazard)
  );

  wire [`FULLW-1 : 0] rm_mem_hazard;

  // rm hazard from ME stage
  aluhazard rm_alu_hazard_detector_ME (
    .prev_alu_opcode(instr_EXME[`ALU_START +: `ALUAW]),
    .curr_reg(instr_REEX[`RM_START_i +: `REGAW]),
    .prev_reg(instr_EXME[`RD_START_i +: `REGAW]),
    .should_bypass(rm_has_alu_hazard_ME)
  );

  wire rm_has_alu_hazard_ME;

  simplemux #(.WIDTH(`FULLW)) rm_alu_hazard_mux_ME(.in1(rm_mem_hazard), .in2(alu_out_EXME),
    .sel(rm_has_alu_hazard_ME & instr_EXME[`OP_TYPE_START+1 +: `OP_TYPE_W-1] == `OP_DATA & ~invalid_EXME),
    .out(rm_EX)
  );
  
  wire [`FULLW-1 : 0] rm_EX;

  // shifter and bypass
  simplemux #(.WIDTH(`FULLW)) rm_bypass_mux (.in1(rm_EX), .in2(bypass_rm),
    .sel(imm_should_bypass_rm),
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

  // rn hazard processing
  // rn wb hazard
  simplemux #(.WIDTH(`FULLW)) rn_wb_hazard_mux (.in1(rn_from_reg_REEX), .in2(prev_reg_wd_REEX),
    .sel( prev_reg_we_REEX & rn_a_EX == prev_reg_wa_REEX), .out(rn_wb_hazard_nopc)
  );

  wire [`FULLW-1 : 0] rn_wb_hazard_nopc;

  simplemux #(.WIDTH(`FULLW)) rn_is_pc (.in1(rn_wb_hazard_nopc), .in2(curr_pc_val),
    .sel(rn_a_EX == `PC_i), .out(rn_wb_hazard)
  );

  wire [`FULLW-1 : 0] rn_wb_hazard;

  // rn load hazard
  simplemux #(.WIDTH(`FULLW)) rn_mem_hazard_mux(.in1(rn_wb_hazard), .in2(mem_out_MEWB),
    .sel(rn_has_mem_hazard_MEWB),
    .out(rn_mem_hazard)
  );

  wire [`FULLW-1 : 0] rn_mem_hazard;

  // rn hazard from ME stage
  aluhazard rn_alu_hazard_detector_ME (
    .prev_alu_opcode(instr_EXME[`ALU_START +: `ALUAW]),
    .curr_reg(instr_REEX[`RN_START_i +: `REGAW]),
    .prev_reg(instr_EXME[`RD_START_i +: `REGAW]),
    .should_bypass(rn_has_alu_hazard_ME)
  );

  wire rn_has_alu_hazard_ME;

  simplemux #(.WIDTH(`FULLW)) rn_alu_hazard_mux_ME(.in1(rn_mem_hazard), .in2(alu_out_EXME),
    .sel(rn_has_alu_hazard_ME & instr_EXME[`OP_TYPE_START+1 +: `OP_TYPE_W-1] == `OP_DATA & ~invalid_EXME),
    .out(rn_EX)
  );

  wire [`FULLW-1 : 0] rn_EX;

  // rd hazard processing
  // rd wb hazard
  simplemux #(.WIDTH(`FULLW)) rd_wb_hazard_mux (.in1(rd_from_reg_REEX), .in2(prev_reg_wd_REEX),
    .sel( prev_reg_we_REEX & rd_a_EX == prev_reg_wa_REEX), .out(rd_wb_hazard_nopc)
  );

  wire [`FULLW-1 : 0] rd_wb_hazard_nopc;

  simplemux #(.WIDTH(`FULLW)) rd_is_pc (.in1(rd_wb_hazard_nopc), .in2(curr_pc_val),
    .sel(rd_a_EX == `PC_i), .out(rd_wb_hazard)
  );

  wire [`FULLW-1 : 0] rd_wb_hazard;

  // rd load hazard
  simplemux #(.WIDTH(`FULLW)) rd_mem_hazard_mux(.in1(rd_wb_hazard), .in2(mem_out_MEWB),
    .sel(rd_has_mem_hazard_MEWB),
    .out(rd_mem_hazard)
  );

  wire [`FULLW-1 : 0] rd_mem_hazard;

  // rd hazard from ME stage
  aluhazard rd_alu_hazard_detector_ME (
    .prev_alu_opcode(instr_EXME[`ALU_START +: `ALUAW]),
    .curr_reg(instr_REEX[`RD_START_i +: `REGAW]),
    .prev_reg(instr_EXME[`RD_START_i +: `REGAW]),
    .should_bypass(rd_has_alu_hazard_ME)
  );

  wire rd_has_alu_hazard_ME;

  simplemux #(.WIDTH(`FULLW)) rd_alu_hazard_mux_ME(.in1(rd_mem_hazard), .in2(alu_out_EXME),
    .sel(rd_has_alu_hazard_ME & instr_EXME[`OP_TYPE_START+1 +: `OP_TYPE_W-1] == `OP_DATA & ~invalid_EXME),
    .out(rd_EX)
  );

  wire [`FULLW-1 : 0] rd_EX;

  // the ALU
  alu32 alu (.codein(alu_opcode), .Rn(rn_EX), .shifter(shifter_out),
    .shiftercarryout(shifter_carry_out), .out(alu_out_EX), .flagsout(alu_flags_write));

  wire [`FULLW-1 : 0] alu_out_EX, alu_out_EXME;
  wire [`FLAGS_W-1 : 0] alu_flags_write;
  
  cpsr32 cpsr (.should_set_cpsr(
      should_set_cpsr & {`FLAGS_W{is_ex_valid}}
    ),
    .cpsrwd(alu_flags_write), .out(cpsr_out), .clk(clk));
  
  wire [`FULLW-1 : 0] cpsr_out;

  branchdec bdec (.instr(instr_REEX),
    .ib_out(ib_nocond), .bv_out(bv), .pc_we_out(pc_we_nocond));

  wire ib_nocond;
  wire ib = ib_nocond & is_ex_valid; // goes back to PC
  wire [`FULLW-1 : 0] bv;
  wire pc_we_nocond;
  wire pc_we_final = pc_we_nocond & is_ex_valid;

  wire [`FULLW-1 : 0] rd_EXME;

  wire bl_EXME;

  wire [`FULLW-1 : 0] instr_EXME, instr_addr_EXME;
  wire set_EX_invalid = ~is_ex_valid;
  wire invalid_EXME;

  preg #(.WIDTH(`FULLW)) alu_out_EXME_reg (.d(alu_out_EX), .q(alu_out_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) rd_EXME_reg (.d(rd_EX), .q(rd_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) bl_EXME_reg (.d(ib & instr_REEX[`BL_i]), .q(bl_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_EXME_reg (.d(instr_REEX), .q(instr_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_addr_EXME_reg (.d(instr_addr_REEX), .q(instr_addr_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) EX_invalid_reg (.d(set_EX_invalid | invalid_REEX), .q(invalid_EXME), .stall(stall_bits[`EXE_PHASE]), .clk(clk));

  // phase 3: mem access
  wire [`OP_TYPE_W-1 : 0] optype_ME = instr_EXME[`OP_TYPE_START +: `OP_TYPE_W];

  ram #(.IS_INSTR(0)) data_mem(.wd(rd_EXME), .wa(alu_out_EXME),
    .we(
      optype_ME[2:1] == `OP_LDSTR & ~instr_EXME[`LD_OR_STR_i] & ~invalid_EXME
    ),
    .ra(alu_out_EXME), .out(mem_out_MEWB),
    .clk(clk));
  wire [`FULLW-1 : 0] mem_out_MEWB;
  
  wire [`FULLW-1 : 0] alu_out_MEWB;


  // load hazard stalling and forwarding
  wire invalid_ME = invalid_EXME
    | rm_has_mem_hazard_MEWB | rn_has_mem_hazard_MEWB | rd_has_mem_hazard_MEWB; // stall has happened already
  wire is_valid_load_ME = instr_EXME[`LD_OR_STR_i] 
    & instr_EXME[`OP_TYPE_START+1 +: `OP_TYPE_W-1] == `OP_LDSTR
    & ~invalid_ME;

  wire rm_has_mem_hazard_ME = is_valid_load_ME 
    & instr_EXME[`RD_START_i +: `REGAW] == instr_REEX[`RM_START_i +: `REGAW]
    & ~imm_should_bypass_rm;
  wire rm_has_mem_hazard_MEWB;
  wire rn_has_mem_hazard_ME = is_valid_load_ME 
    & instr_EXME[`RD_START_i +: `REGAW] == instr_REEX[`RN_START_i +: `REGAW];
  wire rn_has_mem_hazard_MEWB;
  wire rd_has_mem_hazard_ME = is_valid_load_ME 
    & instr_EXME[`RD_START_i +: `REGAW] == instr_REEX[`RD_START_i +: `REGAW];
  wire rd_has_mem_hazard_MEWB;
  
  wire has_mem_hazard = rm_has_mem_hazard_ME | rn_has_mem_hazard_ME | rd_has_mem_hazard_ME;
  assign stall_bits[`FETCH_PHASE] = has_mem_hazard;
  assign stall_bits[`REG_PHASE] = has_mem_hazard;
  assign stall_bits[`EXE_PHASE] = has_mem_hazard;

  wire bl_MEWB;

  wire [`FULLW-1 : 0] instr_MEWB, instr_addr_MEWB;
  wire invalid_MEWB;

  preg #(.WIDTH(`FULLW)) alu_out_MEWB_reg (.d(alu_out_EXME), .q(alu_out_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) bl_MEWB_reg (.d(bl_EXME), .q(bl_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) rm_has_mem_hazard_MEWB_reg (.d(rm_has_mem_hazard_ME), .q(rm_has_mem_hazard_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) rn_has_mem_hazard_MEWB_reg (.d(rn_has_mem_hazard_ME), .q(rn_has_mem_hazard_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) rd_has_mem_hazard_MEWB_reg (.d(rd_has_mem_hazard_ME), .q(rd_has_mem_hazard_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_MEWB_reg (.d(instr_EXME), .q(instr_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(`FULLW)) instr_addr_MEWB_reg (.d(instr_addr_EXME), .q(instr_addr_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));
  preg #(.WIDTH(1)) ME_invalid_reg (.d(invalid_ME), .q(invalid_MEWB), .stall(stall_bits[`MEM_PHASE]), .clk(clk));

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

  wire reg_we_final = reg_we & (reg_wa != `PC_i) & ~invalid_MEWB;

  // Note: cant do this in synthesis  
  initial begin
    if (`IS_SIM) begin
      $readmemh("../../testcode/hexcode_tests/lab2_instr.mem", instr_mem.mem);
    end
  end
endmodule
