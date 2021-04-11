`include "common.svh"

module MyCore (
    input logic clk, resetn,

    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp
);
    logic [31:0] pcD, pcE, pcM;
    logic [31:0] pcF, instrF;
    logic [31:0] pcW /* verilator public_flat_rd */;

    fetch Fetch(
        .pc(pcD), .instr(instrD), .vs(vsHD),
        .j(jD), .clk(clk), .stall(stall), .resetn(resetn),
        .iresp(iresp),
        .ireq(ireq),
        .pcF(pcF), .instrF(instrF)
    );

    logic [31:0] vsD, vtD, immD, instrD;
    logic [4:0] rsD, rtD, rdD, shamtD;
    logic jD;
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
        .clk(clk),
        .hi_data(hiW), .lo_data(loW),
        .hi_write(hi_writeW), 
        .lo_write(lo_writeW),
        .hi(hiD), .lo(loD)
    );

    decode Decode(
        .instr(instrD), .pc(pcD),
        .vs(vsHD), .vt(vtHD),
        .j(jD),
        .controlD(controlD),
        .rsD(rsD), .rtD(rtD), .rdD(rdD), .shamtD(shamtD),
        .immD(immD)
    );

    logic [4:0] rde, rdE, shamte, rse, rte;
    logic [31:0] aluoutE, vtE, imme, vse, vte;
    logic [31:0] hiE, loE, hie, loe;
    logic [15:0] controlE;
    execute Execute(
        .control(controlE[7:2]),
        .rd(rde), .shamt(shamte),
        .vs(vsHe), .vt(vtHe), .imm(imme),
        .hie(hiHe), .loe(loHe),
        .rdE(rdE), .outE(aluoutE), 
        .vtE(vtE), .hiE(hiE), .loE(loE)
    );

    logic [31:0] dataoutM, aluoutM, aluoutm, vtm;
    logic [31:0] hiM, him, loM, lom;
    logic [4:0] rdM, rdm;
    logic [15:0] controlM;
    memory Memory(
        .control(controlM),
        .rdE(rdm),
        .WriteData(vtm), .addr(aluoutm),
        .him(him), .lom(lom),
        .resp(dresp), .req(dreq),
        .rdM(rdM),
        .ReadData(dataoutM), .ALUoutM(aluoutM),
        .hiM(hiM), .loM(loM)
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
            {controlE, controlM, controlW} <= 48'b0;
            {vse, vte, imme, vtm, aluoutm, aluoutw, dataoutw} <= 224'b0;
            {hiw, low, him, hiw} <= 128'b0;
            {rde, rse, rte, shamte, rdm, rdw} <= 30'b0;
            instrD <= 32'hffffffff;
        end 
        else begin
            if(~stallM) begin
                controlW <= controlM;
                pcW <= pcM;
                rdw <= rdM;
                aluoutw <= aluoutM;
                dataoutw <= dataoutM;
                hiw <= hiM;
                low <= loM;

                controlM <= controlE;
                pcM <= pcE;
                rdm <= rdE;
                vtm <= vtE;
                him <= hiE;
                lom <= loE;
                aluoutm <= aluoutE;
            end
            if(stall) begin
                controlE <= 16'b0;
                {vse, vte, imme, hie, loe} <= 160'b0;
                {rde, rse, rte, shamte} <= 20'b0;
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
                imme <= immD;
                shamte <= shamtD;

                pcD <= pcF;
                instrD <= instrF;
            end
        end
    end

    // remove following lines when you start
    /*assign ireq = '0;
    assign dreq = '0;*/
    logic _unused_ok = &{pcW, controlW};
endmodule
