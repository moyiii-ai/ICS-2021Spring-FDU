`include "common.svh"

module memory(
    input logic [15:0] control,
    input logic [4:0] rdE,
    input logic [31:0] WriteData, addr,
    input logic [31:0] him, lom,
    input  dbus_resp_t resp,
    output dbus_req_t  req,
    output logic [4:0] rdM,
    output logic [31:0] ReadData, ALUoutM,
    output logic [31:0] hiM, loM
);
    //strobe_type: 00:wholeword  01:halfword  10:byte
    logic mem_write, memtoreg, mem_extend;
    logic [1:0] strobe_type;
    assign memtoreg = control[1];
    assign mem_write = control[0];
    assign mem_extend = control[8];
    assign strobe_type = control[10:9];
    
    assign req.valid = mem_write | memtoreg;
    assign req.addr = addr;
    always_comb begin
        case(strobe_type)
            2'b00: req.size = MSIZE4;
            2'b01: req.size = MSIZE2;
            default: req.size = MSIZE1;
        endcase
    end
    
    mem_input mem_in(
        .strobe_type(strobe_type),
        .tail(addr[1:0]),
        .mem_write(mem_write),
        .in(WriteData),
        .strobe(req.strobe),
        .out(req.data)
    );
    
    mem_extension mem_ext(
        .strobe_type(strobe_type),
        .mem_extend(mem_extend),
        .tail(addr[1:0]), 
        .in(resp.data),
        .out(ReadData)
    );

    assign ALUoutM = addr;
    assign rdM = rdE;
    assign loM = lom;
    assign hiM = him;

    logic _unused_ok = &{resp, control};

endmodule