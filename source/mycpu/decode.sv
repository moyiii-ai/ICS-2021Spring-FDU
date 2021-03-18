`include "common.svh"

module decode (
    input logic clk, reset,
    input logic [31:0] instr,
    output logic [12:0] control,
    output logic [4:0] rd, shamt,
    output logic [31:0] vs, vt, imm
);
    /*control :
    reg_dst(2) +   
    alu_shamt(1) + alu_imm(1) + alu_funct(4)*/
endmodule