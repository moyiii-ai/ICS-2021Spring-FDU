`include "common.svh"

module MyCore (
    input logic clk, resetn,

    output ibus_req_t  ireq,
    input  ibus_resp_t iresp,
    output dbus_req_t  dreq,
    input  dbus_resp_t dresp
);
    logic [3:0] rdE;
    logic [31:0] outE, vtE;
    execute Execute(
        .control(controlD[5:0]),
        .rd(rdD), .shamt(shamtD),
        .vs(vsD), .vt(vtD), .imm(immD),
        .rdE(rdE), .outE(outE), .vt(vtE)
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
