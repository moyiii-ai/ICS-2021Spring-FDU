`include "common.svh"

module cp0(
    input logic clk, resetn,
    input logic [5:0] ext_int,
    input logic [4:0] ra, wa,
    input logic [11:0] error,
    input logic [31:0] BadVaddr, cp_wdata, pcM,
    output logic flush,
    output logic [31:0] cp_rdata, pcN
);
    word_t [14:8] cp0, cp0_pre;
    logic time_count, comp_valid;

    word_t [31:0] mask12, mask13;
    always_comb begin
        assign mask12 = 32'b0;
        mask12[15:8] = 8'hff;
        mask12[1] = 1;
        mask12[0] = 1;
    end
    always_comb begin
        mask13 = 32'b0;
        mask13[9] = 1;
        mask13[8] = 1;
    end

    logic [7:0] time_int, int_info;

    always_ff @(posedge clk) begin
        if(~resetn) begin
            cp0_pre[11:8] <= '0;
            cp0_pre[14:13] <= '0;
            cp0_pre[12] <= 32'h00400000;
            time_count <= 0;
            comp_valid <= 0;
            time_int <= '0;
        end
        else begin
            cp0_pre <= cp0;
            time_count <= ~time_count;
            comp_valid <= comp_valid | (wa == 5'b01011);
            if(time_int[8] == 1) begin
                if(wa == 5'b01011)
                    time_int <= '0;
                else 
                    time_int <= {1'b1, 7'b0};
            end 
            else begin 
                if(cp0[9] == cp0[11] & comp_valid)
                    time_int <= {1'b1, 7'b0};
                else
                    time_int <= '0;
            end
        end
    end

    assign int_info = {{ext_int, 2'b00} | cp0[13][15:8] | time_int} & cp0[12][15:8];

    always_comb begin
        cp0 = cp0_pre;
        flush = 0;
        pcN = 32'hbfc00380;
        cp0[9] = cp0[9] + (time_count == 1); 
        if(error[11]) begin
            if(wa == 5'b01001)
                cp0[9] = cp_wdata;
            if(wa == 5'b01011)
                cp0[11] = cp_wdata;
            if(wa == 5'b01100)
                cp0[12] = (cp_wdata & mask12) | (cp0_pre[12] & (~mask12));
            if(wa == 5'b01101)
                cp0[13] = (cp_wdata & mask13) | (cp0_pre[13] & (~mask13));
            if(wa == 5'b01110)
                cp0[14] = cp_wdata;
        end

        if(cp0[12][0] == 1 & cp0[12][1] == 0 & int_info != 8'h00) begin
            flush = 1;
            cp0[13][6:2] = 5'b00000;
        end 
        else if(error[6]) begin
            flush = 1;
            cp0[13][6:2] = 5'b00100;
            cp0[8] = BadVaddr;
        end
        else if(error[0]) begin
            flush = 1;
            cp0[13][6:2] = 5'b01010;
        end
        else if(error[7]) begin
            flush = 1;
            cp0[13][6:2] = 5'b01100;
        end
        else if(error[2]) begin
            flush = 1;
            cp0[13][6:2] = 5'b01001;
        end
        else if(error[1]) begin
            flush = 1;
            cp0[13][6:2] = 5'b01000;
        end
        else if(error[5]) begin
            flush = 1;
            cp0[13][6:2] = 5'b00100;
            cp0[8] = BadVaddr;
        end 
        else if(error[4]) begin
            flush = 1;
            cp0[13][6:2] = 5'b00101;
            cp0[8] = BadVaddr;
        end 
        else if(error[3]) begin
            flush = 1;
            pcN = cp0[14];
            cp0[12][1] = 0;
        end

        if(flush & (cp0[13][1] == 0)) begin
            if(error[8]) begin
                cp0[14] = pcM - 4;
                cp0[13][31] = 1;
            end
            else begin  
                cp0[14] = pcM;
                cp0[13][31] = 0;
            end
            cp0[12][1] = 1;
        end 
    end
    assign cp_rdata = cp0[ra];
endmodule

/*
Status.EXL [12][1]
Status.IE  [12][0]
Status.IM  [12][15:8]
Cause.IP   [13][15:8]
    15~10 Hardware  9~8 Software
Cause.ExcCode [13][6:2]
    Int 00  AdEL 04  AdES 05
    Sys 08  BP 09  RI 0a  Ov 0c
Cause.BD   [13][31]
    insolt 1  notinslot 0
*/