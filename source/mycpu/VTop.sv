`include "access.svh"
`include "common.svh"

module VTop (
    input logic clk, resetn,

    output cbus_req_t  oreq,
    input  cbus_resp_t oresp,

    input i6 ext_int
);
    `include "bus_decl"

    ibus_req_t  ireq;
    ibus_resp_t iresp;
    dbus_req_t  dreq;
    dbus_resp_t dresp;
    cbus_req_t  icreq,  dcreq;
    cbus_resp_t icresp, dcresp;

    ibus_req_t myireq;
    dbus_req_t mydreq;

    MyCore core(
        .clk(clk), .resetn(resetn),
        .ireq(myireq), .iresp(iresp),
        .dreq(mydreq), .dresp(dresp)
    );
    IBusToCBus icvt(.*);
    DBusToCBus dcvt(.*);

    /**
     * TODO (Lab2) replace mux with your own arbiter :)
     */
    CBusMultiplexer mux(
        .ireqs({icreq, dcreq}),
        .iresps({icresp, dcresp}),
        .*
    );

    /**
     * TODO (optional) add address translation for oreq.addr :)
     */


    translation translation1(myireq.addr, ireq.addr);
    translation translation2(mydreq.addr, dreq.addr);

    assign ireq.valid = myireq.valid;
    assign ireq.size = myireq.size;
    assign ireq.strobe = myireq.strobe;
    assign ireq.data = myireq.data;

    assign dreq.valid = mydreq.valid;
    assign dreq.size = mydreq.size;
    assign dreq.strobe = mydreq.strobe;
    assign dreq.data = mydreq.data;

    `UNUSED_OK({ext_int});
endmodule
