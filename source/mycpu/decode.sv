`include "common.svh"
`include "icode.svh"

module decode (
    input logic [31:0] instr, pc,
    output logic j,
    output logic [8:0] controlD,
    output logic [4:0] rdD, shamtD,
    output logic [31:0] immD, pcbranch

);
    /*control :
    sign_extend(1) +
    reg_dst(2) + reg_write(1) + 
    alu_shamt(1) + alu_imm(1) + alu_funct(4) +
    memtoreg(1) + mem_write(1)*/
    logic [5:0] op, funct;
    logic [11:0] control;
    assign op = instr[31:26];
    assign funct = instr[5:0];
    always_comb begin
        if(op == `RTYPE) begin
            case(funct)
                `ADDU: control = 12'b0_0_0_01
            endcase
        end
        else begin

        end
    end

    logic [4:0] rt, rs;
    logic [] st_imm;

    logic sign_extend;
    logic [1:0] reg_dst;
    // 00: 0  01: rd 10: rt 11:31 and imm = pc + 8
    assign sign_extend = control[11];
    assign reg_dst = control[10:9];
    always_comb begin
        case(reg_dst)
            2'b00: rdD = 0;
            2'b01: rdD = rd;
            2'b10: rdD = rt;
            2'b11: rdD = 31;
        endcase
    end
    assign controlD = control[8:0];
endmodule

module extension (
    input logic sign_extend,
    input logic [15:0] immI,
    output logic [31:0] imm
);
    always_comb begin
        if(sign_extend)
            imm = {16{immI[15]}, immI};
        else
            imm = {16'b0, immI};
    end
endmodule