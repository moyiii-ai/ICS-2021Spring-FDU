`include "common.svh"

module hazard(
    input logic [5:0] op, funct,  
    input logic loadE, regWriteE, 
    input logic [4:0] rde, rsD, rtD,
    input logic [4:0] rdm, rdW, rse, rte, 
    input logic [31:0] vsD, vtD, vse, vte,
    input logic [31:0] aluoutm, vW,
    output logic [31:0] vsHD, vtHD, vsHe, vtHe,
    output logic stall
);
    logic br;
    logic stallb1, stallb2, stallw, stallj;
    assign br = (op == `BEQ) | (op == `BNE);
    assign stallb1 = br & regWriteE & ((rde == rsD) | (rde == rtD));
    assign stallb2 = br & loadE & ((rdm == rsD) | (rdm == rtD));
    assign stallw = loadE & ((rde == rsD) | (rde == rtD));
    assign stallj = (op == `RTYPE) & (funct == `JR) & regWriteE & (rde == rsD);
    assign stall = stallb1 | stallb2 | stallw | stallj;

    mux1 muxs1(
        .re(rse), .rm(rdm), .rW(rdW),
        .aluoutm(aluoutm), .vW(vW), .ve(vse),
        .vHe(vsHe)
    );
    mux1 muxt1(
        .re(rte), .rm(rdm), .rW(rdW),
        .aluoutm(aluoutm), .vW(vW), .ve(vte),
        .vHe(vtHe)
    );

    mux2 muxs2(
        .rD(rsD), .rm(rdm),
        .aluoutm(aluoutm), .vD(vsD),
        .vHD(vsHD)
    );
    mux2 muxt2(
        .rD(rtD), .rm(rdm),
        .aluoutm(aluoutm), .vD(vtD),
        .vHD(vtHD)
    );
    
endmodule

module mux1(
    input logic [4:0] re, rm, rW,
    input logic [31:0] aluoutm, vW, ve,
    output logic [31:0] vHe
);
    always_comb begin
        if(re == 0)
            vHe = 0;
        else if(re == rm) 
            vHe = aluoutm;
        else if(re == rW) 
            vHe = vW;
        else
            vHe = ve;       
    end 
endmodule

module mux2(
    input logic [4:0] rD, rm, 
    input logic [31:0] aluoutm, vD,
    output logic [31:0] vHD
);
    always_comb begin
        if(rm == rD)
            vHD = aluoutm;
        else 
            vHD = vD;
    end
endmodule