`include "common.svh"

module fetch (
    input logic [31:0] pc, instr, vs,
    input  ibus_resp_t iresp,
    output ibus_req_t  ireq,
    output logic [31:0] pcF, instrF
);
    logic [31:0] pcplus;
    assign pcplus = pc + 4;
    
    assign ireq.valid = 1;
    assign ireq.addr = pcF;
    assign instrF = iresp.data;
endmodule