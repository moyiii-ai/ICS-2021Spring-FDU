`include "common.svh"

module memory(
    input logic memtoreg, mem_write,
    input logic [4:0] rdE,
    input logic [31:0] WriteData, ALUoutE, 
    output logic [31:0] ReadData, ALUoutM,
    output logic [4:0] rdM,
);
    
    assign ALUoutM = ALUoutE;
    assign rdM = rdE;
endmodule