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

  wire [31:0] instr_bus;
  wire [31:0] instr_addr_bus;

  wire [31:0] data_bus;
  wire [31:0] data_addr_bus;

  ram instr_mem(.d({32{dummy}}), .ad(instr_addr_bus), .we(dummy), .q(instr_bus), .clk(clk));
  //ram data_mem(.d(data_addr_bus), .ad(), .we(), .q(), .clk(clk));
    
endmodule
