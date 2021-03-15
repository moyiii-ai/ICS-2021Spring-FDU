`include "common.svh"

module fetch (
    input logic i32 pc,
    output logic i32 pcplus4
);
    assign pcplus4 = pc + 32'b4;
endmodule