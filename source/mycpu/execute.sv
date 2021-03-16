`include "common.svh"

module execute (
    input logic i6 control, 
    input logic i5 rd, shamt,
    input logic i32 vs, vt, imm,
    output logic i5 rdE,
    output logic i32 outE, vtE
);

    logic i32 srcA, srcB;
    assign srcA = vs;
    
    always_comb begin
        if(control[4]) 
            srcB = imm;
        if(control[5])
            srcB = {27'b0, shamt};
    end

    alu ALU(.funct(control[3:0]), .in1(srcA), .in2(srcB), .out(outE));

    assign rdE = rd;
    assign vtE = vt;

endmodule