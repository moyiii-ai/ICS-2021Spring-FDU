`include "common.svh"

module MyCore (
    input logic clk, resetn,

    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp
);
    logic [31:0] pcD, pcE, pcM, pcW;
    logic [31:0] pcF, instrF;

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
    logic [11:0] controlD;
    regfile Regfile(
        .clk(clk),
        .ra1(rsD), .ra2(rtD), .wa3(rdW),
        .write_enable(write_enableW),
        .wd3(vW),
        .rd1(vsD), .rd2(vtD)
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
    logic [11:0] controlE;
    execute Execute(
        .control(controlE[7:2]),
        .rd(rde), .shamt(shamte),
        .vs(vsHe), .vt(vtHe), .imm(imme),
        .rdE(rdE), .outE(aluoutE), .vtE(vtE)
    );

    logic [31:0] dataoutM, aluoutM, aluoutm, vtm;
    logic [4:0] rdM, rdm;
    logic [11:0] controlM;
    memory Memory(
        .control(controlM),
        .rdE(rdm),
        .WriteData(vtm), .addr(aluoutm),
        .resp(dresp),
        .req(dreq),
        .rdM(rdM),
        .ReadData(dataoutM), .ALUoutM(aluoutM)
    );

    logic [31:0] vW, aluoutw, dataoutw;
    logic [4:0] rdW, rdw;
    logic write_enableW;
    logic [11:0] controlW;
    writeback WriteBack(
        .memtoreg(controlW[1]), .reg_write(controlW[11]),
        .rdM(rdw),
        .ReadDataM(dataoutw), .ALUoutM(aluoutw),
        .write_enable(write_enableW),
        .rdW(rdW),
        .ResultW(vW)
    );

    logic [31:0] vsHD, vtHD, vsHe, vtHe;
    logic stall, stallM;
    hazard Hazard(
        .ireq(ireq), .iresp(iresp),
        .dreq(dreq), .dresp(dresp),
        .op(instrD[31:26]), .funct(instrD[5:0]),
        .loadE(controlE[1]), .loadM(controlM[1]),
        .regWriteE(controlE[11]),
        .rde(rde), .rsD(rsD), .rtD(rtD),
        .rdm(rdm), .rdW(rdW), .rse(rse), .rte(rte),
        .vsD(vsD), .vtD(vtD), .vse(vse), .vte(vte),
        .aluoutm(aluoutm), .vW(vW),
        .vsHD(vsHD), .vtHD(vtHD), .vsHe(vsHe), .vtHe(vtHe),
        .stallM(stallM), .stall(stall)
    );

    always_ff @(posedge clk) begin
        if (~resetn) begin
            {controlE, controlM, controlW} <= 36'b0;
            {vse, vte, imme, vtm, aluoutm, aluoutw, dataoutw} <= 224'b0;
            {rde, rse, rte, shamte, rdm, rdw} <= 30'b0;
        end 
        else begin
            if(~stallM) begin
                controlW <= controlM;
                pcW <= pcM;
                rdw <= rdM;
                aluoutw <= aluoutM;
                dataoutw <= dataoutM;

                controlM <= controlE;
                pcM <= pcE;
                rdm <= rdE;
                vtm <= vtE;
                aluoutm <= aluoutE;
            end
            if(stall) begin
                controlE <= 12'b0;
                {vse, vte, imme} <= 96'b0;
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
