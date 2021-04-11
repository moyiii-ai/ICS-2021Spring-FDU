`include "common.svh"

module writeback(
    input logic [15:0] control,
    input logic [4:0] rdM,
    input logic [31:0] ReadDataM, ALUoutM,
    input logic [31:0] hiw, low,
    output logic write_enable,
    output logic hi_writeW, lo_writeW,
    output logic [4:0] rdW,
    output logic [31:0] ResultW, hiW, loW
);
    logic memtoreg, hi_read, lo_read;
    logic [3:0] funct;
    assign write_enable = control[15];
    assign memtoreg = control[1];
    assign hi_read = control[14];
    assign hi_writeW = control[13];
    assign lo_read = control[12];
    assign lo_writeW = control[11];
    assign funct = control[5:2];
    
    assign rdW = rdM;
    always_comb begin
        if(memtoreg)
            ResultW = ReadDataM;
        else if(hi_read)
            ResultW = hiw;
        else if(lo_read)
            ResultW = low;
        else
            ResultW = ALUoutM;
    end

    always_comb begin
        if(funct == 4'b0) begin
            hiW = ALUoutM;
            loW = ALUoutM;
        end else begin
            hiW = hiw;
            loW = low;
        end
    end
        
    logic _unused_ok = &{control};

endmodule