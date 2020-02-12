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
  assign debug_port1 = instr_addr_bus[7:0];// 8'h01;
  assign debug_port2 = instr_bus[7:0]; //8'h02;
  assign debug_port3 = r1_out[7:0]; //8'h03;
  assign debug_port4 = r2_out[7:0]; //8'h04;
  assign debug_port5 = {4'b0, rd_bus};//8'h05;
  assign debug_port6 = {4'b0, rn_bus};//8'h06;
  assign debug_port7 = {7'b0, nreset};//{4'b0, cpsr_bus[31:28]};//8'h07;

  // BIG ENDIAN
  wire dummy;
  assign dummy = 1'b0;

  wire dummy1;
  assign dummy1 = 1'b1;

  wire [`FULLW-1 : 0] instr_bus, instr_addr_bus;

  wire [`FULLW-1 : 0] data_bus, data_addr_bus;

  wire [`FULLW-1 : 0] cpsr_bus;
  wire [`FLAGSW-1 : 0] should_set_cpsr, alu_flags_write;

  wire [`FULLW-1 : 0] r1_out, r2_out, reg_wd, bv;
  wire [`REGAW-1 : 0] rd_bus, rn_bus, reg_wa;

  wire reg_we;
  wire ib, bl;

  wire [`ALUAW-1 : 0] alu_opcode;

  wire ispb_q;

  wire [`PHASES-1 : 0] curr_phase;
  phaser #(.PHASES(`PHASES)) phaser
    (.out(curr_phase), .clk(clk), .reset(`IS_SIM ? 1'b0 : ~nreset));

  ram instr_mem(.d({32{dummy}}),
    .ad(instr_addr_bus), .we(dummy), .q(instr_bus), .en(dummy1), .clk(clk));
  //ram data_mem(.d(data_addr_bus), .ad(data_addr_bus), .we(), .q(), .clk(clk));

  cpsr32 cpsr(.shouldsetcpsr(should_set_cpsr),
    .cpsrwd(alu_flags_write), .out(cpsr_bus), .clk(clk));

  dff #(.WIDTH(1)) ispb(.d(ib), .q(ispb_q), .clk(clk));

  wire ispc_write;
  assign ispc_write = reg_we & (reg_wa == `PC_IND);

  wire isreg_write;
  assign isreg_write = reg_we & (reg_wa != `PC_IND);

  pc32 pc (.ib(ib), .bv(bv), .we(ispc_write), .wd(reg_wd),
    .iaddrout(instr_addr_bus), .reset(`IS_SIM ? 1'b0 : ~nreset),
    .en(curr_phase == 0),
    .clk(clk)
  );

  idec32 idec(.iin(instr_bus), .cpsrin(cpsr_bus[31:28]), .ispb(ispb_q),
    .alu_out(alu_opcode), .rn_out(rn_bus), .rd_out(rd_bus),
    .cpsrs_out(should_set_cpsr), .reg_we(reg_we), .mem_we(dummy),
    .ib(ib), .bv(bv), .bl(bl));
  
  reg32 registers(.in1(rn_bus), .in2(rd_bus),
    .we(isreg_write), .wd(reg_wd), .wa(reg_wa),
    .out1(r1_out), .out2(r2_out),
    .clk(clk));
  
  // Note: cant do this in synthesis  
  initial begin
    if (`IS_SIM) begin
      $readmemh("../../testcode/hexcode_tests/lab1_instr.mem", instr_mem.mem);
      $readmemh("../../testcode/hexcode_tests/lab1_reg.mem", registers.mem);
      $readmemh("../../testcode/hexcode_tests/lab1_cpsr.mem", cpsr.mem);
    end
  end
endmodule
