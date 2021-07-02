`include "common.svh"

module MyCore (
    input logic clk, resetn,
    input i6 ext_int, 

    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp
);
    logic [31:0] pcD, pcE, pcM, pcF, instrF, pcN;
    logic [31:0] pcW /* verilator public_flat_rd */;
    logic [31:0] BadVaddrF;
    logic AddrErrorF, InsoltF;

    fetch Fetch(
        .pc(pcD), .pcN(pcN), .instr(instrD), .vs(vsHD),
        .j(jD), .clk(clk), .resetn(resetn),
        .flush(flush), .stall(stall),
        .iresp(iresp),
        .ireq(ireq),
        .insolt(InsoltF), .AddrError(AddrErrorF),
        .pcF(pcF), .instrF(instrF),
        .BadVaddr(BadVaddrF)
    );

    logic [31:0] vsD, vtD, immD;
    logic [31:0] instrD, BadVaddrD, BadVaddrd;
    logic [4:0] rsD, rtD, rdD, shamtD, rd0D;
    logic jD, AddrErrord, Insoltd;
    logic [11:0] errorD;
    logic [15:0] controlD;
    regfile Regfile(
        .clk(clk),
        .ra1(rsD), .ra2(rtD), .wa3(rdW),
        .write_enable(write_enableW),
        .wd3(vW),
        .rd1(vsD), .rd2(vtD)
    );

    logic [31:0] hiD, loD;
    hilo Hilo(
        .clk(clk), .resetn(resetn),
        .hi_data(hiW), .lo_data(loW),
        .hi_write(hi_writeW), 
        .lo_write(lo_writeW),
        .hi(hiD), .lo(loD)
    );

    logic [31:0] cpe, cpm;
    cp0 Cp0(
        .clk(clk), .resetn(resetn),
        .ext_int(ext_int),
        .ra(rd0e), .wa(rdM),
        .error(errorM),
        .BadVaddr(BadVaddrM),
        .cp_wdata(cp_wdataM),
        .pcM(pcM),
        .flush(flush),
        .cp_rdata(cpe), .pcN(pcN)
    );

    decode Decode(
        .instr(instrD), .pc(pcD), 
        .AddrError(AddrErrord),
        .Insolt(Insoltd),
        .vs(vsHD), .vt(vtHD),
        .j(jD),
        .error(errorD),
        .controlD(controlD),
        .rsD(rsD), .rtD(rtD), .rdD(rdD), .rd0D(rd0D),
        .shamtD(shamtD), .immD(immD)
    );

    logic [4:0] rde, rdE, shamte, rse, rte, rd0e;
    logic [31:0] aluoutE, vtE, imme, vse, vte;
    logic [31:0] hiE, loE, hie, loe, BadVaddrE;
    logic [15:0] controlE;
    logic [11:0] errorE, errore;

    execute Execute(
        .control(controlE),
        .rd(rde), .shamt(shamte),
        .error(errore),
        .vs(vsHe), .vt(vtHe), .imm(imme), .cpe(cpe),
        .hie(hiHe), .loe(loHe),
        .rdE(rdE), .errorE(errorE),
        .outE(aluoutE), .vtE(vtE), .hiE(hiE), .loE(loE)
    );

    logic [31:0] dataoutM, aluoutM, aluoutm, vtm;
    logic [31:0] hiM, loM, BadVaddrm, BadVaddrM;
    logic [4:0] rdM, rdm;
    logic [15:0] controlM;
    logic [11:0] errorm, errorM;
    memory Memory(
        .control(controlM),
        .rdE(rdm), .errorm(errorm),
        .WriteData(vtm), .addr(aluoutm), 
        .BadVaddrm(BadVaddrm),
        .resp(dresp), .req(dreq),
        .rdM(rdM), .errorM(errorM),
        .ReadData(dataoutM), .ALUoutM(aluoutM),
        .BadVaddrM(BadVaddrM)
    );

    logic [31:0] aluoutw, dataoutw;
    logic [31:0] hiw, low, hiW, loW;
    logic hi_writeW, lo_writeW;
    logic [4:0] rdw;
    logic [31:0] vW /* verilator public_flat_rd */;
    logic [4:0] rdW /* verilator public_flat_rd */;
    logic write_enableW /* verilator public_flat_rd */;
    logic [15:0] controlW;
    writeback WriteBack(
        .control(controlW),
        .rdM(rdw),
        .ReadDataM(dataoutw), .ALUoutM(aluoutw),
        .hiw(hiw), .low(low),
        .write_enable(write_enableW),
        .hi_writeW(hi_writeW), .lo_writeW(lo_writeW),
        .rdW(rdW),
        .ResultW(vW), .hiW(hiW), .loW(loW)
    );

    logic [31:0] vsHD, vtHD, vsHe, vtHe, hiHe, loHe;
    logic stall, stallM;
    hazard Hazard(
        .ireq(ireq), .iresp(iresp),
        .dreq(dreq), .dresp(dresp),
        .op(instrD[31:26]), .funct(instrD[5:0]),
        .loadE(controlE[1]), .loadM(controlM[1]),
        .regWriteE(controlE[15]),
        .rde(rde), .rsD(rsD), .rtD(rtD),
        .rdm(rdm), .rdW(rdW), .rse(rse), .rte(rte),
        .vsD(vsD), .vtD(vtD), .vse(vse), .vte(vte),
        .aluoutm(aluoutm), .vW(vW),
        .hi_writeM(controlM[13]), .hi_writeW(controlW[13]),
        .lo_writeM(controlM[11]), .lo_writeW(controlW[11]),
        .hiM(hiM), .hiW(hiW), .loM(loM), .loW(loW),
        .hie(hie), .loe(loe),
        .hiHe(hiHe), .loHe(loHe),
        .vsHD(vsHD), .vtHD(vtHD), .vsHe(vsHe), .vtHe(vtHe),
        .stallM(stallM), .stall(stall)
    );

    always_ff @(posedge clk) begin
        if (~resetn) begin
            {controlE, controlM, controlW} <= '0;
            {vse, vte, imme, vtm, aluoutm, aluoutw, dataoutw} <= '0;
            {errore, errorm, cpe, cpm} <= '0;
            {hiw, low, hiM, loM} <= '0;
            {rde, rse, rte, rd0e, shamte, rdm, rdw} <= '0;
            {BadVaddrD, instrD} <= '0;
        end 
        else begin
            if(flush) begin
                {controlE, controlM, controlW} <= '0;
                {vse, vte, imme, vtm, aluoutm, aluoutw, dataoutw} <= '0;
                {errore, errorm, cpe, cpm} <= '0;
                {hiw, low, hiM, loM} <= '0;
                {rde, rse, rte, rd0e, shamte, rdm, rdw} <= '0;
                instrD <= '0;
                {BadVaddrd, AddrErrord} <= '0;
            end else begin
                if(~stallM) begin
                    controlW <= controlM;
                    pcW <= pcM;
                    rdw <= rdM;
                    aluoutw <= aluoutM;
                    dataoutw <= dataoutM;
                    hiw <= hiM;
                    low <= loM;

                    controlM <= controlE;
                    BadVaddrm <= BadVaddrE;
                    pcM <= pcE;
                    rdm <= rdE;
                    vtm <= vtE;
                    cpm <= cpe;
                    errorm <= errorE;
                    hiM <= hiE;
                    loM <= loE;
                    aluoutm <= aluoutE;
                end
                if(stall) begin
                    controlE <= '0;
                    {vse, vte, imme, hie, loe} <= '0;
                    {rde, rse, rte, shamte, cpe} <= '0;
                    {errore, cpe, rd0e} <= '0;
                    {BadVaddrE} <= '0;
                end
                else begin
                    controlE <= controlD;
                    pcE <= pcD;
                    rde <= rdD;
                    rse <= rsD;
                    rte <= rtD;
                    vse <= vsD;
                    vte <= vtD;
                    hie <= hiD;
                    loe <= loD;
                    rd0e <= rd0D;
                    imme <= immD;
                    shamte <= shamtD;
                    errore <= errorD;
                    BadVaddrE <= BadVaddrD;

                    pcD <= pcF;
                    instrD <= instrF;
                    Insoltd <= InsoltF;
                    BadVaddrD <= BadVaddrF;
                    AddrErrord <= AddrErrorF;
                end
            end
        end
    end

    // remove following lines when you start
    /*assign ireq = '0;
    assign dreq = '0;*/
    logic _unused_ok = &{pcW, controlW};
endmodule
