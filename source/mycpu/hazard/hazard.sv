`include "common.svh"

module hazard(
    input ibus_req_t  ireq,
    input ibus_resp_t iresp,
    input dbus_req_t  dreq,
    input dbus_resp_t dresp,
    input logic [5:0] op, funct,  
    input logic loadE, loadM, regWriteE, 
    input logic [4:0] rde, rsD, rtD,
    input logic [4:0] rdm, rdW, rse, rte, 
    input logic [31:0] vsD, vtD, vse, vte,
    input logic [31:0] aluoutm, vW,
    input logic hi_writeM, hi_writeW, lo_writeM, lo_writeW,
    input logic [31:0] hiM, hiW, loM, loW, hie, loe,
    output logic [31:0] hiHe, loHe,
    output logic [31:0] vsHD, vtHD, vsHe, vtHe,
    output logic stallM, stall
);
    logic br;
    logic stallb1, stallb2, stallw, stallj, stalli, stallrm, stallwm;
    assign br = (op == `BEQ) | (op == `BNE);
    assign stallb1 = br & regWriteE & ((rde == rsD) | (rde == rtD));
    assign stallb2 = br & (loadE | loadM) & ((rdm == rsD) | (rdm == rtD));
    assign stallw = loadE & ((rde == rsD) | (rde == rtD));
    assign stallj = (op == `RTYPE) & (funct == `JR) & regWriteE & (rde == rsD);

    assign stallrm = dreq.valid & (~dreq.strobe) & (~dresp.data_ok);
    assign stallwm = dreq.valid & dreq.strobe & (~dresp.addr_ok);  
    assign stallM = stallrm | stallwm;
    assign stalli = ireq.valid & (~iresp.data_ok); 
    assign stall = stallb1 | stallb2 | stallw | stallj | stalli | stallM;
    
    always_comb begin
        if(hi_writeM)
            hiHe = hiM;
        else if(hi_writeW)
            hiHe = hiW;
        else hiHe = hie;
    end

    always_comb begin
        if(lo_writeM)
            loHe = loM;
        else if(hi_writeW)
            loHe = loW;
        else loHe = loe;
    end
    
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