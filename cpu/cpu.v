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
  assign debug_port1 = 8'h01;
  assign debug_port2 = 8'h02;
  assign debug_port3 = 8'h03;
  assign debug_port4 = 8'h04;
  assign debug_port5 = 8'h05;
  assign debug_port6 = 8'h06;
  assign debug_port7 = 8'h07;

  // my shit
  wire dummy;
  assign dummy = 1'b0;

  wire [31:0] instr_bus, instr_addr_bus;

  wire [31:0] data_bus, data_addr_bus;

  wire [31:0] cpsr_bus;
  wire should_set_cpsr;

  wire [31:0] r1_out, r2_out, reg_wd, bv;
  wire [3:0] rd_bus, rn_bus, reg_wa;
  wire reg_we;
  wire ib, bl;

  wire [3:0] alu_opcode;

  ram instr_mem(.d({32{dummy}}), .ad(instr_addr_bus), .we(dummy), .q(instr_bus), .clk(clk));
  //ram data_mem(.d(data_addr_bus), .ad(), .we(), .q(), .clk(clk));

  cpsr32 cpsr(.we(should_set_cpsr), .flagsin({4{dummy}}), .out(cpsr_bus), .clk(clk));

  idec32 idec(.iin(instr_bus), .cpsrin(cpsr_bus[31:28]),
    .alu_out(alu_opcode), .rn_out(rn_bus), .rd_out(rd_bus),
    .cpsrs_out(should_set_cpsr), .reg_we(reg_we), .mem_we(dummy),
    .ib(ib), .bv(bv), .bl(bl),
    .clk(clk));

  reg32 registers(.in1(rn_bus), .in2(rd_bus),
    .we(reg_we), .wd(reg_wd), .wa(reg_wa),
    .out1(r1_out), .out2(r2_out),
    .ib(ib), .bv(bv), .bl(bl),
    .iout(instr_addr_bus),
    .clk(clk));
    
endmodule
