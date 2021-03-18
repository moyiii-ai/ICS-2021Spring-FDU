`include "common.svh"
`include "icode.svh"

module decode (
    input logic [31:0] instr,
    output logic [13:0] control,
    output logic [4:0] rd, shamt,
    output logic [31:0] vs, vt, imm
);
    /*control :
    branch(1) + sign_exetend(1) + imm_left(1) +
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