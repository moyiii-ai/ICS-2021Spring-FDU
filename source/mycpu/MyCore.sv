`include "common.svh"

module MyCore (
    input logic clk, resetn,
    input i6 ext_int, 

    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp
);
    logic [31:0] pcD, pcE, pcM, pcF, instrF;
    logic [31:0] pcW /* verilator public_flat_rd */;
    logic [31:0] BadVaddrF;
    logic AddrErrorF, inslotF;

    fetch Fetch(
        .pc(pcD), .instr(instrD), .vs(vsHD),
        .j(jD), .clk(clk), .stall(stall), .resetn(resetn),
        .iresp(iresp),
        .ireq(ireq),
        .insolt(inslotF), .AddrError(AddrErrorF)
        .pcF(pcF), .instrF(instrF),
        .BadVaddr(BadVaddrF)
    );

    logic [31:0] vsD, vtD, immD;
    logic [31:0] instrD, BadVaddrD;
    logic [4:0] rsD, rtD, rdD, shamtD;
    logic jD, cp_readD, cp_writeD, AddrErrorD, inslotD;
    logic [6:0] errorD;
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
        .AddrError(AddErrorD),
        .vs(vsHD), .vt(vtHD),
        .j(jD), .cp_read(cp_readD), .cp_write(cp_writeD),
        .error(errorD),
        .controlD(controlD),
        .rsD(rsD), .rtD(rtD), .rdD(rdD), .shamtD(shamtD),
        .immD(immD)
    );

    logic [4:0] rde, rdE, shamte, rse, rte;
    logic [31:0] aluoutE, vtE, imme, vse, vte;
    logic [31:0] hiE, loE, hie, loe, BadVaddrE;
    logic [15:0] controlE;
    logic [6:0] errorE, errore;
    logic cp_readE, cp_writeE, inslotE;
    execute Execute(
        .control(controlE[7:2]),
        .rd(rde), .shamt(shamte),
        .error(errore),
        .vs(vsHe), .vt(vtHe), .imm(imme),
        .hie(hiHe), .loe(loHe),
        .rdE(rdE), .errorE(errorE),
        .outE(aluoutE), .vtE(vtE), .hiE(hiE), .loE(loE)
    );

    logic [31:0] dataoutM, aluoutM, aluoutm, vtm;
    logic [31:0] hiM, loM, BadVaddrM;
    logic [4:0] rdM, rdm;
    logic [15:0] controlM;
    logic [6:0] errorm;
    logic cp_readM, cp_writeM, inslotM;
    memory Memory(
        .control(controlM),
        .rdE(rdm),
        .WriteData(vtm), .addr(aluoutm),
        .resp(dresp), .req(dreq),
        .rdM(rdM),
        .ReadData(dataoutM), .ALUoutM(aluoutM),
    );

    logic [31:0] aluoutw, dataoutw;
    logic [31:0] hiw, low, hiW, loW;
    logic hi_writeW, lo_writeW, cp_writeW;
    logic [4:0] rdw;
    logic [31:0] vW /* verilator public_flat_rd */;
    logic [4:0] rdW /* verilator public_flat_rd */;
    logic write_enableW /* verilator public_flat_rd */;
    logic [15:0] controlW;
    writeback WriteBack(
        .control(controlW),
        .rdM(rdw),
        .ReadDataM(dataoutw), .ALUoutM(aluoutw),
        .hiw(hiw), .low(low), .cpw(cpw),
        .cp_writeW(cp_writeW), .cp_readW(cp_readW),
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
            {errore, cp_readE, cp_writeE} <= '0;
            {cp_readM, cp_writeM} <= '0;
            {hiw, low, hiM, loM} <= '0;
            {rde, rse, rte, shamte, rdm, rdw} <= '0;
            instrD <= '0;
            {BadVaddrD, AddrErrorD, inslotD} <= '0;
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
                cp_writeM <= cp_writeE;
                cp_readM <= cp_writeM;
                BadVaddrM <= BadVaddrE;
                inslotM <= inslotE;
                pcM <= pcE;
                rdm <= rdE;
                vtm <= vtE;
                hiM <= hiE;
                loM <= loE;
                aluoutm <= aluoutE;
            end
            if(stall) begin
                controlE <= '0;
                {vse, vte, imme, hie, loe} <= '0;
                {rde, rse, rte, shamte} <= '0;
                {cp_readE, cp_writeE, errore} <= '0;
                {BadVaddrE, inslotE} <= '0;
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
                errore <= errorE;
                inslotE <= inslotD:
                BadVaddrE <= BadVaddrD;
                cp_readE <= cp_readD;
                cp_writeE <= cp_writeD;

                pcD <= pcF;
                instrD <= instrF;
                inslotD <= inslotF;
                BadVaddrD <= BadVaddrF;
                AddrErrorD <= AddrErrorF;
            end
        end
    end

    // remove following lines when you start
    /*assign ireq = '0;
    assign dreq = '0;*/
    logic _unused_ok = &{pcW, controlW};
endmodule
