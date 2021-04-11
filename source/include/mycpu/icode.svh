`ifndef __ICODE_SVH__
`define __ICODE_SVH__

`define RTYPE 6'b000000
`define ADDU 6'b100001
`define SUBU 6'b100011
`define AND 6'b100100
`define OR 6'b100101
`define NOR 6'b100111
`define XOR 6'b100110
`define SLL 6'b000000
`define SRA 6'b000011
`define SRL 6'b000010
`define SLT 6'b101010
`define SLTU 6'b101011
`define JR 6'b001000
`define MFHI 6'b010000
`define MFLO 6'b010010 
`define MTHI 6'b010001 
`define MTLO 6'b010011 
`define MULT 6'b011000 
`define MULTU 6'b011001 
`define DIV 6'b011010 
`define DIVU 6'b011011 
`define SLLV 6'b000100 
`define SRAV 6'b000111 
`define SRLV 6'b000110 

`define ADDIU 6'b001001
`define ANDI 6'b001100
`define ORI 6'b001101
`define XORI 6'b001110
`define SLTI 6'b001010
`define SLTIU 6'b001011
`define LUI 6'b001111
`define BEQ 6'b000100
`define BNE 6'b000101
`define LW 6'b100011
`define SW 6'b101011
`define BGTZ 6'b000111
`define BLEZ 6'b000110
`define REGIMM 6'b000001
`define LB 6'b100000  
`define LBU 6'b100100 
`define LH 6'b100001 
`define LHU 6'b100101
`define SB 6'b101000 
`define SH 6'b101001 

`define BGEZ 5'b00001 
`define BGEZAL 5'b10001 
`define BLTZ 5'b00000 
`define BLTZAL 5'b10000 

`define J 6'b000010
`define JAL 6'b000011
`define JALR 6'b001001

`endif