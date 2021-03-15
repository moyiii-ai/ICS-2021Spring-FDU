`include "common.svh"

module alu (
    input logic i4 func,
    input logic i32 in1, in2,
    output logic i32 out
);
    always_comb begin
        case(func)
            4'b0000: out = ~ (in1 | in2);
            4'b0001: out = in1 >>> in2;
            4'b0010: out = in1 >> in2; //logic
            4'b0011: out = in1 + in2;
            4'b0100: out = in1 - in2;
            4'b0101: out = {31'b0, in1 < in2};
            4'b0110: out = in1 & in2;
            4'b0111: out = in1 | in2;
            4'b1000: out = in1 ^ in2;
    end
endmodule