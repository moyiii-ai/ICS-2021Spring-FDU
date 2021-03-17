`include "common.svh"

module execute (
    input logic [5:0] control, 
    input logic [4:0] rd, shamt,
    input logic [31:0] vs, vt, imm,
    output logic [4:0] rdE,
    output logic [31:0] outE, vtE
);

    logic [31:0] srcA, srcB;
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