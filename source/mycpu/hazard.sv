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
        if(rsD == 0)
            vsH = 0;
        else if(rdE == rsD) 
            vsH = aluoutE;
        else if(rdW == rsD) 
            vsH = vW;
        else
            vsH = vsD;       
    end 
    always_comb begin
        if(rtD == 0)
            vtH = 0;
        else if(rdE == rtD) 
            vtH = aluoutE;
        else if(rdW == rtD) 
            vtH = vW;
        else
            vtH = vtD;       
    end 
endmodule