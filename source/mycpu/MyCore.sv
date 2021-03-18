`include "common.svh"

module MyCore (
    input logic clk, resetn,

    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp
);
    logic [31:0] instr, vsD, vtD, immD, prbranch;
    logic [4:0] rsD, rtD, rdD, shamtD;
    logic j;
    logic [8:0] controlD;
    regfile Regfile(
        .clk(clk),
        .ra1(rsD), .ra2(rtD), .wa3(),
        .write_enable(),
        .wd3(ResultW),
        .rd1(vsD), .rd2(vtD)
    );

    decode Decode(
        .instr(instr), .pc(pc),
        .vs(vsD), vt(vtD),
        .j(jD),
        .controlD,
        .rsD, .rtD, .rdD, shamtD,
        .immD, .prbranch
    );

    logic [3:0] rdE;
    logic [31:0] outE, vtE;
    execute Execute(
        .control(controlD[7:2]),
        .rd(rdD), .shamt(shamtD),
        .vs(vsD), .vt(vtD), .imm(immD),
        .rdE(rdE), .outE(outE), .vt(vtE)
    );

    logic [31:0] ResultW;
    writeback WriteBack(
        .memtoreg(controlM[9]),
        .ReadDataW(outM), .ALUoutW(aluoutE),
        .ResultW
    );


    always_ff @(posedge clk)
    if (resetn) begin
        // AHA!
    end else begin
        // reset
        // NOTE: if resetn is X, it will be evaluated to false.
    end

    // remove following lines when you start
    /*assign ireq = '0;
    assign dreq = '0;
    logic _unused_ok = &{iresp, dresp};*/
endmodule
