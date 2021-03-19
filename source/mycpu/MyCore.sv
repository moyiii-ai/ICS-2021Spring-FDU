`include "common.svh"

module MyCore (
    input logic clk, resetn,

    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp
);
    logic [31:0] pc, pcbranch;
    logic [31:0] instr, vsD, vtD, immD;
    logic [4:0] rsD, rtD, rdD, shamtD;
    logic j;
    logic [8:0] controlD;
    regfile Regfile(
        .clk(clk),
        .ra1(rsD), .ra2(rtD), .wa3(rdW),
        .write_enable(write_enable),
        .wd3(vW),
        .rd1(vsD), .rd2(vtD)
    );

    decode Decode(
        .instr(instr), .pc(pc),
        .vs(vsD), vt(vtD),
        .j(jD),
        .controlD(controlD),
        .rsD(rsD), .rtD(rtD), .rdD(rdD), shamtD(shamtD),
        .immD(immD), .pcbranch(pcbranch)
    );

    logic [4:0] rdE;
    logic [31:0] outE, vtE;
    logic [8:0] controlE;
    execute Execute(
        .control(controlE[7:2]),
        .rd(rdD), .shamt(shamtD),
        .vs(vsD), .vt(vtD), .imm(immD),
        .rdE(rdE), .outE(outE), .vt(vtE)
    );

    logic [31:0] rdM, dataoutM, aluoutM;
    logic [4:0] rdM;
    logic [8:0] controlM;
    memory Memory(
        .memtoreg(controlM[1]), .mem_write(controlM[0]);
        .rdE(rdE),
        .WriteData(outE), .addr(vtE),
        .rdM(rdM),
        .ReadData(dataoutM), .aluoutM(ALUoutM)
    );

    logic [31:0] vW;
    logic [4:0] rdW;
    logic write_enable;
    logic [8:0] controlW;
    writeback WriteBack(
        .memtoreg(controlW[1]), .reg_write(controlW[9]),
        .rdM(rdM),
        .ReadDataM(dataoutM), .ALUoutM(aluoutM),
        .write_enable(write_enable),
        .rdW(rdW),
        .ResultW(vW)
    );


    always_ff @(posedge clk)
    if (resetn) begin
        pc <= 32'hbfc0_0000;
        instr <= 0;
    end else begin
        if(stall) begin

        end
        else begin
            pc <= pcF;
            instr <= instrF;
        end
    end

    // remove following lines when you start
    /*assign ireq = '0;
    assign dreq = '0;
    logic _unused_ok = &{iresp, dresp};*/
endmodule
