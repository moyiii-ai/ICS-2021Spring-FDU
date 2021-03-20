`include "common.svh"

module hazard(
    input logic [5:0] op,
    input logic [31:0] vsD, vtD, aluoutE, vW,
    input logic [4:0] rdE, rdW, rsD, rtD, 
    output logic [31:0] vsH, vtH,
    output logic stall
);
    logic 
    always_comb begin
        if(rdE == rsD && op != `LW) 
            vsH = aluoutE;
        else if(rdW == rsD) 
            vsH = vW;
        else
            vsH = vsD;       
    end 
    always_comb begin
        if(rdE == rtD && op != `LW) 
            vtH = aluoutE;
        else if(rdW == rtD) 
            vtH = vW;
        else
            vsH = vtD;       
    end 
endmodule