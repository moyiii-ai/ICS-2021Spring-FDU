`include "common.svh"

module memory(
    input logic memtoreg, mem_write,
    input logic [4:0] rdE,
    input logic [31:0] WriteData, addr,
    input  dbus_resp_t resp,
    output dbus_req_t  req,
    output logic [4:0] rdM,
    output logic [31:0] ReadData, ALUoutM
);
    assign req.valid = mem_write | memtoreg;
    assign req.addr = addr;
    assign req.size = MSIZE4;
    assign req.strobe = {4{mem_write}};
    assign req.data = WriteData;
    assign ReadData = resp.data;
    assign ALUoutM = addr;
    assign rdM = rdE;
endmodule