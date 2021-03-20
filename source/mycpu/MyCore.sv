`include "common.svh"

module MyCore (
    input logic clk, resetn,

    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp
);
    logic [31:0] pc, instr;
    logic [31:0] pcF, instrF;
    logic stall;

    fetch Fetch(
        .pc(pc), .instr(instr), .vs(vsD),
        .j(jD),
        .iresp(iresp),
        .ireq(ireq),
        .pcF(pcF), .instrF(instrF)
    );

    logic [31:0] vsD, vtD, immD, vsH, vtH;
    logic [4:0] rsD, rtD, rdD, shamtD;
    logic jD;
    logic [8:0] controlD;
    regfile Regfile(
        .clk(clk),
        .ra1(rsD), .ra2(rtD), .wa3(rdW),
        .write_enable(write_enableW),
        .wd3(vW),
        .rd1(vsD), .rd2(vtD)
    );

    decode Decode(
        .instr(instrF), .pc(pc),
        .vs(vsD), vt(vtD),
        .j(jD),
        .controlD(controlD),
        .rsD(rsD), .rtD(rtD), .rdD(rdD), .shamtD(shamtD),
        .immD(immD)
    );

    logic [4:0] rde, rdE, shamte;
    logic [31:0] aluoutE, vtE, imme, vse, vte;
    logic [8:0] controlE;
    execute Execute(
        .control(controlE[7:2]),
        .rd(rde), .shamt(shamte),
        .vs(vsH), .vt(vtH), .imm(imme),
        .rdE(rdE), .outE(aluoutE), .vt(vtE)
    );

    logic [31:0] rdM, dataoutM, aluoutM, aluoutm, vtm;
    logic [4:0] rdM, rdm;
    logic [8:0] controlM;
    memory Memory(
        .memtoreg(controlM[1]), .mem_write(controlM[0]);
        .rdE(rdm),
        .WriteData(vtm), .addr(aluoutm),
        .resp(dresp),
        .req(dreq),
        .rdM(rdM),
        .ReadData(dataoutM), .aluoutM(aluoutM)
    );

    logic [31:0] vW, dataoutw, aluoutw;
    logic [4:0] rdW, rdw;
    logic write_enableW;
    logic [8:0] controlW;
    writeback WriteBack(
        .memtoreg(controlW[1]), .reg_write(controlW[8]),
        .rdM(rdw),
        .ReadDataM(dataoutM), .ALUoutM(aluoutw),
        .write_enable(write_enableW),
        .rdW(rdW),
        .ResultW(vW)
    );

    hazard Hazard(
        .op(instr[31:26]),
        .vsD(vsD), .vtD(vtD), .aluoutE(aluoutE), .vW(vW),
        .rdE(rdE), .rdW(rdW), .rsD(rsD), .rtD(rtD),
        .vsH(vsH), .vtH(vtH),
        .stall(stall)
    );

    always_ff @(posedge clk)
    if (resetn) begin
        pc <= 32'hbfc0_0000;
        pcF <= 32'hbfc0_0000;
        instr <= 0;
        instrF <= 0;
        {controlD, immD, rdD, vtD, vsD, rsD, rtD, jD, shamtD, vsH, vtH} <= 0;
        {controlE, rde, vse, vte, imme, shamte, vtE, rdE, aluoutE} <= 0;
        {controlM, rdm, vtm, aluoutm, rdM, dataoutM, aluoutM} <= 0;
        {controlW, rdw, dataoutw, aluoutw, vW, rdW, write_enableW} <= 0;
    end 
    else begin
        controlW <= controlM;
        rdw <= rdM;
        dataoutw <= dataoutM;
        aluoutw <= aluoutM;

        controlM <= controlE;
        rdm <= rdE;
        vtm <= vtE;
        aluoutm <= aluoutE;
        if(stall) begin
            {controlE, rde, vse, vte, imme, shamte, vtE, rdE, aluoutE} <= 0;
        end
        else begin
            controlE <= controlD;
            rde <= rdD;
            vse <= vsD;
            vte <= vtD;
            imme <= immE;
            shamte <= shamtD;
            pc <= pcF;
            instr <= instrF;
        end
    end

    // remove following lines when you start
    /*assign ireq = '0;
    assign dreq = '0;
    logic _unused_ok = &{iresp, dresp};*/
endmodule
