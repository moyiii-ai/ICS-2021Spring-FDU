`include "common.svh"

module execute (
    input logic [7:2] control, 
    input logic [4:0] rd, shamt,
    input logic [11:0] error,
    input logic [31:0] vs, vt, imm,
    input logic [31:0] hie, loe,
    output logic [4:0] rdE,
    output logic [11:0] errorE,
    output logic [31:0] outE, vtE, hiE, loE
);

    logic alu_imm, alu_shamt;
    logic [31:0] srcA, srcB;
    logic [3:0] alu_funct;
    logic over;

    assign errorE[11:8] = error[11:8];
    assign errorE[6:0] = error[6:0];
    assign errorE[7] = error[8] & Over; 

    assign alu_imm = control[6];
    assign alu_shamt = control[7];
    assign alu_funct = control[5:2];

    always_comb begin
        if(alu_imm) 
            srcB = imm;
        else 
            srcB = vt;
    end
    always_comb begin
        if(alu_shamt) 
            srcA = {27'b0, shamt};
        else 
            srcA = vs;
    end

    alu ALU(
        .funct(alu_funct), 
        .in1(srcA), .in2(srcB), 
        .out(outE), .over(over)
    );

    mult MULT(
        .hie(hie), .loe(loe),
        .in1(srcA), .in2(srcB),
        .funct(alu_funct),
        .hiE(hiE), .loE(loE)
    );

    assign rdE = rd;
    assign vtE = vt;

    logic _unused_ok = &{error};

endmodule