`include "common.svh"

module hazard(
    input logic [5:0] op, funct,  
    input logic loadE, loadM, regWriteE, 
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
    assign stallb2 = br & (loadE | loadM) & ((rdm == rsD) | (rdm == rtD));
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