`ifndef _defines_v_
`define _defines_v_

`define IS_SIM 0

`define WORD 4 // how many bytes in word
`define WIDTH 8 // how many bit in byte
`define FULLW (`WORD * `WIDTH) // how many bits in word
`define REGAW 4 // register address width

// 3 bit optype codes (bits 25-27)
`define OP_TYPE_W 3 
`define OP_TYPE_START 25 // start index of OP_TYPE
`define OP_DATA 2'b00
`define OP_DATA_SHIFT 3'b000
`define OP_DATA_ROR 3'b001
`define OP_LDSTR 2'b01
`define OP_LDSTR_IMM 3'b010
`define OP_LDSTR_REG 3'b011
`define OP_BRANCH 3'b101
`define LDSTR_OR_DATA_OFFSET 1
`define LDSTR_OR_DATA_i 26

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
`define SHIFTER_OPERAND_W 12
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

// rd rn rm address bits
`define RD_START_i 12
`define RN_START_i 16
`define RM_START_i 0

// other control bits (20-24)
`define CONTROL_START 20
`define CONTROL_W 5
`define LD_OR_STR_i 20
`define LD_OR_STR_OFFSET 0
`define BL_OFFSET 4

// Branch instruction stuff
`define BRANCHIMM_W 24
`define BL_i 24
`define BRANCH_SHIFT 2

// ZCNV flag indices
`define FLAGS_START 28
`define FLAGS_W 4 // how many flags
`define V_i 0
`define C_i 1
`define Z_i 2
`define N_i 3

// Reg
`define PC_i 15 // prog counter
`define LR_i 14 // link register

// Phases just for lab 2
`define PHASES 5
`define FETCH_PHASE 0
`define REG_PHASE 1
`define EXE_PHASE 2
`define MEM_PHASE 3
`define WB_PHASE 4
`endif