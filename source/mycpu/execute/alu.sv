`include "common.svh"

module alu (
    input logic [3:0] funct,
    input logic [31:0] in1, in2,
    output logic [31:0] out,
    output logic over
);
    always_comb begin
        case(funct)
            4'b0000: out = in1 + in2;
            4'b0001: out = in1 - in2;
            4'b0010: out = in1 & in2;
            4'b0011: out = in1 | in2;
            4'b0100: out = ~ (in1 | in2);
            4'b0101: out = in1 ^ in2;
            
            4'b0110: out = in2 << in1;
            4'b0111: out = $signed(in2) >>> in1; //arithmetic
            4'b1000: out = in2 >> in1;  //logical
            4'b1001: out = {31'b0, $signed(in1) < $signed(in2)}; //signed
            4'b1010: out = {31'b0, in1 < in2}; //unsigned
            
            4'b1111: out = in2;
            default: out = 32'b0;
        endcase
    end
    
    logic [32:0] temp1, temp2, temp;
    assign temp1 = {in1[31], in1};
    assign temp2 = {in2[31], in2};
    assign temp = (funct == 4'b0000) ? temp1 + temp2 : temp1 - temp2;
    assign over = (temp[32] != temp[31]);

    logic _unused_ok = &{temp};

endmodule