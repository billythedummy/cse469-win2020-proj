`ifndef _defines_v_
`define _defines_v_

`define IS_SIM 1
`define WORD 4 // how many bytes in word
`define WIDTH 8 // how many bit in byte
`define FULLW (`WORD * `WIDTH) // how many bits in word
`define REGAW 4 // register address width
`define ALUAW 4 // alu 'address' width
`define FLAGSW 4 // how many flags
// shifter
`define SHIFTCODEW 2 // how many bits to encode barrel shifter code
`define LSL 2'b00 // code for LOGICAL SHIFT LEFT
`define LSR 2'b01 // code for LOGICAL SHIFT RIGHT
`define ASR 2'b10 // code for ARITHMETIC SHIFT RIGHT
`define ROR 2'b11 // code for ROTATE RIGHT, RRX is just checking for extra bit
// ZCNV flag indices
`define V_i 0
`define C_i 1
`define Z_i 2
`define N_i 3

`endif