`include "common.svh"

module execute (
    input logic [5:0] control, 
    input logic [4:0] rd, shamt,
    input logic [31:0] vs, vt, imm,
    output logic [4:0] rdE,
    output logic [31:0] outE, vtE
);

    logic alu_imm, alu_shamt;
    logic [31:0] srcA, srcB;
    logic [3:0] alu_funct;

    assign alu_imm = control[4];
    assign alu_shamt = control[5];
    assign alu_funct = control[3:0];

    always_comb begin
        if(alu_imm) 
            srcB = imm;
        if(alu_shamt)
            srcB = {27'b0, shamt};
    end

    alu ALU(.funct(alu_funct), .in1(srcA), .in2(srcB), .out(outE));

    assign rdE = rd;
    assign vtE = vt;

endmodule