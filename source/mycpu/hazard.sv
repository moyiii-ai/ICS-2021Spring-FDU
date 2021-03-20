`include "common.svh"

module hazard(
    input logic [31:0] vsD, vtD, aluoutm, vW,
    input logic [4:0] rdm, rdw, rsD, rtD, 
    input logic reg_write, write_enableW, 
    output logic [31:0] vsH, vtH,
    output logic stall
);
    if(memtoreg)
endmodule