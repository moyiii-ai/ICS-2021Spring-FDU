`include "common.svh"

module DCache #(
    parameter int OFFSET_BITS = 4,
    parameter int INDEX_BITS = 2,
    localparam int TAG_BITS = 32 - OFFSET_BITS - INDEX_BITS,
    localparam int OFFSET_MAX = OFFSET_BITS - 1,
    localparam int INDEX_MAX = INDEX_BITS - 1,
    localparam int TAG_MAX = 31 - OFFSET_BITS - INDEX_BITS,
    localparam int SET_MAX = (2 << INDEX_BITS) - 1,
    localparam int LINE_MAX = (2 << (OFFSET_BITS - 2)) - 1
) (
    input logic clk, resetn,

    input  dbus_req_t  dreq,
    output dbus_resp_t dresp,
    output cbus_req_t  dcreq,
    input  cbus_resp_t dcresp
);
    /**
     * TODO (Lab3) your code here :)
     */

    typedef logic[TAG_MAX:0] tag_t;
    typedef logic[INDEX_MAX:0] index_t;
    typedef logic[OFFSET_MAX:0] offset_t;
    typedef [1:0] position_t;

    typedef struct packed {
        tag_t tag;
        logic valid;
        logic dirty;
    } meta_t;
    typedef meta_t [3:0] meta_set_t;

    typedef enum i3 {
        IDLE,
        SEARCH,
        HIT,
        MISS,
        FETCH,
        FLUSH,
        READY
    } state_t;

    typedef word_t [LINE_MAX:0] cache_line_t;
    typedef cache_line_t [3:0] cache_set_t;

    meta_set_t [SET_MAX:0] meta;
    cache_set_t [SET_MAX:0] data;

    dbus_req_t req;
    tag_t tag;
    state_t state;
    index_t index;
    offset_t offset;

    meta_set_t foo;
    position_t pos;
    
    assign foo = meta[index];

    always_comb begin
        pos = 2'b00;

        unique if (foo[0].tag == tag)
            pos = 2'b00;
        else if (foo[1].tag == tag)
            pos = 2'b01;
        else if (foo[2].tag == tag)
            pos = 2'b10;
        else if (foo[3].tag == tag)
            pos = 2'b11;
        else  pos = tag[1:0] ^ tag[3:2] ^ tag[5:4] ^ tag[7:6];
    end

    
    logic [1:0] offset_in;

    // DBus driver
    assign dresp.addr_ok = state == IDLE;
    assign dresp.data_ok = state == READY;
    assign dresp.data    = data[index][pos][offset[OFFSET_MAX:2]];

    // CBus driver
    assign creq.valid = state == FLUSH || state == FETCH;
    assign creq.is_write = state == FLUSH;
    assign creq.size = MSIZE4;
    assign creq.addr = {meta[index][pos].tag, index, 4'b0000};
    assign creq.strobe = 4'b1111;
    assign creq.data = data[index][pos][offset_in];
    assign creq.len = MLEN4;

    always_ff @(posedge clk)
        if (resetn) begin
            unique case (state)
                IDLE: if(dreq.valid) begin
                    {tag, index, offset} <= dreq.addr;
                    req <= dreq;
                    offset_in <= 2'b00;
                    state <= SEARCH;
                end

                SEARCH: begin
                    if(meta[index][pos].tag == tag)
                        state <= HIT;
                    else
                        state <= MISS;
                end

                HIT: begin
                    if (req.strobe) begin
                        data[index][pos][offset[OFFSET_MAX:2]] <= req.data;
                        meta[index][pos].valid <= 0;
                        meta[index][pos].dirty <= 1;
                        state <= IDLE;
                    end
                    else begin
                        if(~(meta[index][pos].valid | meta[index][pos].dirty))
                            state <= FETCH;
                        else
                            state <= READY;
                    end
                end

                MISS: begin
                    state <= (meta[index][pos].dirty) ? FLUSH : HIT;
                    meta[index][pos].tag <= tag;
                    meta[index][pos].valid <= 0;
                    meta[index][pos].dirty <= 0;
                end

                FETCH: if(cresp.ready) begin
                    if(cresp.last) begin
                        state <= READY;
                        meta[index][pos].valid <= 1;
                        meta[index][pos].dirty <= 0;
                    end else begin
                        state <= FETCH;
                        offset_in <= offset_in + 1;
                    end
                end

                FLUSH: if(cresp.ready) begin
                    if(cresp.last) begin
                        state <= HIT;
                        meta[index][pos].valid <= 0;
                        meta[index][pos].dirty <= 0;
                        offset_in <= 2'b00;
                    end else begin
                        state <= FLUSH;
                        offset_in <= offset_in + 1;
                    end
                end

                READY: begin
                    state <= IDLE;
                end

            endcase
        end else begin
            state <= IDLE;
            {req, offset} <= '0;
        end

    // remove following lines when you start
    /*assign {dresp, dcreq} = '0;
    `UNUSED_OK({clk, resetn, dreq, dcresp});*/
endmodule
