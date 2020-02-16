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
  assign debug_port1 = instr_addr_bus[7:0];
  assign debug_port2 = instr_bus[7:0]; 
  assign debug_port3 = {4'b0, rd_a_bus}; 
  assign debug_port4 = {4'b0, rn_a_bus}; 
  assign debug_port5 = rd_out_bus[7:0];
  assign debug_port6 = rn_out_bus[7:0];
  assign debug_port7 = {7'b0, nreset};

  // BIG ENDIAN
  wire dummy0 = 1'b0;
  wire dummy1 = 1'b1;

  wire [$clog2(`PHASES)-1 : 0] curr_phase;
  phaser #(.PHASES(`PHASES)) phaser
    (.out(curr_phase), .clk(clk), .reset(`IS_SIM ? 1'b0 : ~nreset));

  // pc
  wire pc_we_final = reg_we & (reg_wa_bus == `PC_i) & (curr_phase == `WB_PHASE);

  pc32 pc (.ib(ib), .bv(bv_bus), .we(pc_we_final), .wd(reg_wd_bus),
    .iaddrout(instr_addr_bus), .reset(`IS_SIM ? 1'b0 : ~nreset),
    .r_en(curr_phase == `FETCH_PHASE), .mod_en(curr_phase == `WB_PHASE),
    .clk(clk)
  );

  // phase 0: Instr Fetch and decode
  wire [`FULLW-1 : 0] instr_bus, instr_addr_bus;
  wire [`FULLW-1 : 0] cpsr_bus, bypass_rm_d_bus, bypass_rm_q_bus;
  wire [`FLAGSW-1 : 0] should_set_cpsr_d_bus, should_set_cpsr_q_bus;
  wire [`REGAW-1 : 0] rd_a_bus, rn_a_bus, rm_a_bus, reg_wa_bus;
  wire should_bypass_rm_d, should_bypass_rm_q;
  wire should_bypass_data;
  wire [`ALUAW-1 : 0] alu_opcode_bus;

  ram instr_mem(.d({32{dummy0}}),
    .ad(instr_addr_bus), .we(dummy0), .q(instr_bus), .clk(clk));

  idec32 idec(.i_in(instr_bus), .cpsr_in(cpsr_bus[`FLAGS_START +: `FLAGSW]),
    .alu_opcode_out(alu_opcode_bus),
    .rm_a_out(rm_a_bus), .rn_a_out(rn_a_bus), .rd_a_out(reg_wa_bus), 
    .bypass_rm_out(bypass_rm_d_bus), .should_bypass_rm_out(should_bypass_rm_d),
    .should_set_cpsr_out(should_set_cpsr_d_bus),
    .reg_we_out(reg_we), .mem_we_out(data_we),
    .shiftcode_out(shiftcode_bus), .shiftby_out(shiftby_bus),
    .should_bypass_data_out(should_bypass_data),
    .ib_out(ib), .bv_out(bv_bus), .bl_out(bl));

  dff #(.WIDTH(1)) should_bypass_rm_dff (.d(should_bypass_rm_d), .q(should_bypass_rm_q), .clk(clk));

  dff #(.WIDTH(`FULLW)) bypass_rm_dff (.d(bypass_rm_d_bus), .q(bypass_rm_q_bus), .clk(clk));

  dff #(.WIDTH(`FLAGSW)) should_set_cpsr_dff (.d(should_set_cpsr_d_bus), .q(should_set_cpsr_q_bus), .clk(clk));

  // phase 1: Register access
  wire [`FULLW-1 : 0] rd_out_bus, rn_out_bus, rm_out_bus, bv_bus;
  wire [`FULLW-1 : 0] shifter_in_bus, shifter_out_bus;
  wire [`SHIFTCODEW-1 : 0] shiftcode_bus;
  wire [`WIDTH-1 : 0] shiftby_bus;
  wire shifter_carry_out;
  wire [`FLAGSW-1 : 0] alu_flags_write;
  wire ib, bl;
  wire reg_we_final = reg_we & (reg_wa_bus != `PC_i) & (curr_phase == `WB_PHASE);

  reg32 registers(.rn_a(rn_a_bus), .rm_a(rm_a_bus),
    .we(reg_we_final), .wd(reg_wd_bus), .wa(reg_wa_bus),
    .rn_out(rn_out_bus), .rm_out(rm_out_bus), .rd_out(rd_out_bus),
    .clk(clk));

  // phase 2: Exec
  wire [`FULLW-1 : 0] alu_out_d_bus, alu_out_q_bus;

  simplemux #(.WIDTH(`FULLW)) rm_bypass_mux (.in1(rm_out_bus), .in2(bypass_rm_q_bus),
    .sel(should_bypass_rm_q),
    .out(shifter_in_bus));
  
  shifter32 shifter (.shiftby(shiftby_bus), .shiftin(shifter_in_bus),
    .shiftcode(shiftcode_bus),
    .cflag(cpsr_bus[`FLAGS_START + `C_i]),
    .out(shifter_out_bus), .carryout(shifter_carry_out));

  alu32 alu (.codein(alu_opcode_bus), .Rn(rn_out_bus), .shifter(shifter_out_bus),
    .shiftercarryout(shifter_carry_out), .out(alu_out_d_bus), .flagsout(alu_flags_write));
  
  cpsr32 cpsr(.should_set_cpsr(should_set_cpsr_q_bus),
    .cpsrwd(alu_flags_write), .out(cpsr_bus), .clk(clk));

  dff #(.WIDTH(`FULLW)) alu_out_dff (.d(alu_out_d_bus), .q(alu_out_q_bus), .clk(clk));

  // phase 3: mem access
  wire data_we;
  wire [`FULLW-1 : 0] data_out_bus;

  ram data_mem(.d(rd_out_bus), .ad(alu_out_d_bus),
    .we((curr_phase == `MEM_PHASE) & data_we),
    .q(data_out_bus),
    .clk(clk));

  // phase 4: reg writeback
  wire reg_we;
  wire [`FULLW-1 : 0] mem_or_bypass_bus, reg_wd_bus;

  simplemux #(.WIDTH(`FULLW)) data_bypass_mux (.in1(data_out_bus), .in2(alu_out_q_bus),
    .sel(should_bypass_data),
    .out(mem_or_bypass_bus));
  // change data to curr instruction address + 4 if BL
  simplemux #(.WIDTH(`FULLW)) bl_data_mux (.in1(mem_or_bypass_bus), .in2(instr_addr_bus + 4),
    .sel(bl),
    .out(reg_wd_bus));
  
  // Note: cant do this in synthesis  
  initial begin
    if (`IS_SIM) begin
      $readmemh("../../testcode/hexcode_tests/lab2_instr.mem", instr_mem.mem);
    end
  end
endmodule
