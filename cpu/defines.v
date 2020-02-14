`ifndef _defines_v_
`define _defines_v_

`define IS_SIM 1
`define WORD 4 // how many bytes in word
`define WIDTH 8 // how many bit in byte
`define FULLW (`WORD * `WIDTH) // how many bits in word
`define REGAW 4 // register address width
`define FLAGSW 4 // how many flags
`define SHIFTER_OPERAND_W 12

// 3 bit optype codes (bits 25-27)
`define OP_TYPE_W 3 
`define OP_TYPE_START 25 // start index of OP_TYPE
`define OP_DATA_SHIFT 3'b000
`define OP_DATA_ROR 3'b001
`define OP_LDSTR_IMM 3'b010
`define OP_LDSTR_REG 3'b011
`define OP_BRANCH 3'b101

// 4 bit ALU opcode (bits 21-24)
`define ALUAW 4 // alu 'address' width
`define ALU_START 21 // start index of ALU opcode
`define AND 4'b0000 
`define EOR 4'b0001 
`define SUB 4'b0010
`define RSB 4'b0011  
`define ADD 4'b0100
`define ADC 4'b0101 // ADD but add +1 if C flag is set, unsupported for now
`define SBC 4'b0110 // SUB but another -1 if C flag NOT set, unsupported for now
`define RSC 4'b0111 // shifter - Rn instead of Rn - shifter and another -1 f C flag, unsupported for now
`define TST 4'b1000 // just AND
`define TEQ 4'b1001 // just EOR
`define CMP 4'b1010 // just SUB
`define CMN 4'b1011 // just ADD
`define ORR 4'b1100 
`define PASS 4'b1101 // passes shifter operand. Use this for MOV, etc
`define BIC 4'b1110 // Rd  Rn AND NOT(shifter)
`define MVN 4'b1111 // Rd  NOT shifter

// shifter codes
`define SHIFTCODEW 2 // how many bits to encode barrel shifter code
`define SHIFTCODE_START 5 // start index of shift code
`define SHIFTIMM_START 7 // start index of shift immediate
`define SHIFTIMM_W 5
`define RORIMM_START 8 // start index of rotate immediate
`define RORIMM_W 4
`define LSL 2'b00 // code for LOGICAL SHIFT LEFT
`define LSR 2'b01 // code for LOGICAL SHIFT RIGHT
`define ASR 2'b10 // code for ARITHMETIC SHIFT RIGHT
`define ROR 2'b11 // code for ROTATE RIGHT, RRX is just checking if immed is 0

// ZCNV flag indices
`define FLAGS_START 28
`define V_i 0
`define C_i 1
`define Z_i 2
`define N_i 3

// Reg
`define PC_IND 15

// Phases just for lab 2
`define PHASES 5
`endif