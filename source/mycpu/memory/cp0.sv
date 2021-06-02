`include "common.svh"

module cp0(
    input logic clk, resetn,
    input logic [4:0] ra, wa,
    input logic [6:0] error,
    input logic cp_write,
    input logic [31:0] cp_wdata,
    output logic [31:0] cp_rdata
);
    word_t [31:0] cp0, cp0_nxt, mask;
    logic valid, valid_nxt;

    word_t [31:0] mask;
    assign mask[8] = 32'b0;
    assign mask[9] = 32'hffffffff;
    assign mask[11] = 32'hffffffff;
    assign mask[14] = 32'hffffffff;
    alwasy_comb begin
        assign mask[12] = 32'hffffffff;
        mask[12][24] = 0;
        mask[12][23] = 0;
        mask[12][18] = 0;
        mask[12][17] = 0;
        mask[12][16] = 0;
        mask[12][7] = 0;
        mask[12][6] = 0;
        mask[12][5] = 0;
        mask[12][3] = 0;
    end
    always_comb begin
        mask[13] = 32'b0;
        mask[13][27] = 1;
        mask[13][23] = 1;
        mask[13][22] = 1;
        mask[13][9] = 1;
        mask[13][8] = 1;
    end
    

    always_ff @(posedge clk) begin
        if(~resetn)
            cp0 <= '0;
        else
            cp0 <= cp0_nxt;
    end

    always_comb begin
        cp0_nxt = cp0;
        if(cp_write)
            cp0_nxt[wa] = (cp0[wa] & (~mask)) | (cp_wdata & mask);
    end
    assign cp_rdata = cp0_nxt[ra];
endmodule

/*
Status.EXL [12][1]
Status.IE  [12][0]
Status.IM  [12][15:8]
Cause.IP   [13][15:8]
Cause.Exccode
Cause.BD
*/