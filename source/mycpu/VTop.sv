`include "access.svh"
`include "common.svh"

module VTop (
    input logic clk, resetn,

    output cbus_req_t  oreq,
    input  cbus_resp_t oresp,

    input i6 ext_int
);
    `include "bus_decl"

    ibus_req_t  ireq, cireq;
    ibus_resp_t iresp, ciresp, myiresp;
    dbus_req_t  dreq, cdreq;
    dbus_resp_t dresp, cdresp, mydresp;
    cbus_req_t  icreq,  dcreq, cicreq, cdcreq;
    cbus_resp_t icresp, dcresp, cicresp, cdcresp;

    logic iuncached, duncached;

    ibus_req_t myireq;
    dbus_req_t mydreq;

    MyCore core(
        .clk(clk), .resetn(resetn),
        .ireq(myireq), .iresp(myiresp),
        .dreq(mydreq), .dresp(mydresp)
    );

    assign myiresp = iuncached ? iresp : ciresp;
    assign mydresp = duncached ? dresp : cdresp;

    ICache icvt(.clk(clk), .resetn(resetn), .ireq(cireq), .iresp(ciresp), .icreq(cicreq), .icresp(cicresp));
    DCache dcvt(.clk(clk), .resetn(resetn), .dreq(cdreq), .dresp(cdresp), .dcreq(cdcreq), .dcresp(cdcresp));
    IBusToCBus bicvt(.ireq(ireq), .iresp(iresp), .icreq(icreq), .icresp(icresp));
    DBusToCBus bdcvt(.dreq(dreq), .dresp(dresp), .dcreq(dcreq), .dcresp(dcresp));

    CBusArbiter #(.NUM_INPUTS(4)) mux(
        .ireqs({icreq, cicreq, dcreq, cdcreq}),
        .iresps({icresp, cicresp, dcresp, cdcresp}),
        .*
    );

    translation translation1(.vaddr(myireq.addr), .paddr(ireq.addr), .uncached(iuncached));
    translation translation2(.vaddr(mydreq.addr), .paddr(dreq.addr), .uncached(duncached));

    assign ireq.valid = myireq.valid & iuncached;
    assign cireq.valid = myireq.valid & (~iuncached);
    assign cireq.addr = ireq.addr;

    assign dreq.valid = mydreq.valid & duncached;
    assign cdreq.valid = mydreq.valid & (~duncached);
    assign cdreq.addr = dreq.addr;

    assign dreq.size = mydreq.size;
    assign dreq.strobe = mydreq.strobe;
    assign dreq.data = mydreq.data;
    
    assign cdreq.size = mydreq.size;
    assign cdreq.strobe = mydreq.strobe;
    assign cdreq.data = mydreq.data;

    `UNUSED_OK({ext_int});
endmodule
