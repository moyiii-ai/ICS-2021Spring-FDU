`include "common.svh"
`include "icode.svh"

module decode (
    input logic [31:0] instr,
    output logic [12:0] control,
    output logic [4:0] rd, shamt,
    output logic [31:0] vs, vt, imm
);
    /*control :
    sign_exetend(1) + imm_left(1) +
    reg_dst(2) + reg_write(1) + 
    alu_shamt(1) + alu_imm(1) + alu_funct(4) +
    memtoreg(1) + mem_write(1)*/
    logic [5:0] op, funct;
    assign op = instr[31:26];
    assign funct = instr[5:0];
    always_comb begin
        if(op == `RTYPE) begin
            case(funct)
                `ADDU: control = 
            endcase
        end
        else begin

        end
    end
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
            imm = {16'b0, imm1};
    end
endmodule