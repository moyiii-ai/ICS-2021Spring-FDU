`include "common.svh"

module memory(
    input logic [15:0] control,
    input logic [4:0] rdE,
    input logic [11:0] errorm,
    input logic [31:0] WriteData, addr, BadVaddrm,
    input  dbus_resp_t resp,
    output dbus_req_t  req,
    output logic [4:0] rdM,
    output logic [11:0] errorM,
    output logic [31:0] ReadData, ALUoutM, BadVaddrM
);
    //strobe_type: 00:wholeword  01:halfword  10:byte
    logic mem_write, memtoreg, mem_extend;
    logic [1:0] strobe_type;
    logic adel, ades;
    assign memtoreg = control[1];
    assign mem_write = control[0];
    assign mem_extend = control[8];
    assign strobe_type = control[10:9];
    
    assign req.valid = (mem_write & (~ades)) | (memtoreg & (~adel));
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

    mem_check mem_check(
        .strobe_type(strobe_type),
        .addr(addr),
        .BadVaddrm(BadVaddrm),
        .adei(errorm[6]),
        .mem_write(mem_write),
        .memtoreg(memtoreg),
        .adel(adel), .ades(ades),
        .BadVaddrM(BadVaddrM)
    );

    assign errorM[11:6] = errorm[11:6];
    assign errorM[5] = adel;
    assign errorM[4] = ades;
    assign errorM[3:0] = errorm[3:0];

    assign ALUoutM = addr;
    assign rdM = rdE;

    logic _unused_ok = &{resp, control, errorm};

endmodule