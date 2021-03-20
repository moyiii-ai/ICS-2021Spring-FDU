`include "common.svh"

module writeback(
    input logic memtoreg, reg_write,
    input logic [4:0] rdM,
    input logic [31:0] ReadDataM, ALUoutM,
    output logic write_enable,
    output logic [4:0] rdW,
    output logic [31:0] ResultW
);
    assign write_enable = reg_write;
    assign rdW = rdM;
    always_comb begin
        if(memtoreg)
            ResultW = ReadDataM;
        else 
            ResultW = ALUoutM;
    end
endmodule