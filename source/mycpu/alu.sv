`include "common.svh"

module alu (
    input logic i4 funct,
    input logic i32 in1, in2,
    output logic i32 out
);
    always_comb begin
        case(funct)
            4'b0000: out = in1 + in2;
            4'b0001: out = in1 - in2;
            4'b0010: out = in1 & in2;
            4'b0011: out = in1 | in2;
            4'b0100: out = ~ (in1 | in2);
            4'b0101: out = in1 ^ in2;
            
            4'b0110: out = $signed(in1) >>> in2; //arithmetic
            4'b0111: out = in1 >> in2;  //logical
            4'b1000: out = {31'b0, in1 < in2}; //unsigned
            4'b1001: out = {31'b0, $signed(in1) < $signed(in2)} //signed
            
            4'b1111: out = in2;
            default: out = 32'b0;
    end
endmodule