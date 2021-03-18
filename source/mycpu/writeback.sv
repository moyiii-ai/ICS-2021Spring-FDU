`include "common.svh"

module writeback(
    intput logic memtoreg,
    input logic [31:0] ReadDataW, ALUoutW,
    output logic [31:0] ResultW
);
    always_comb begin
        if(memtoreg)
            ResultW = ReadDataW;
        else 
            ResultW = ALUoutW;
        end
    end
endmodule