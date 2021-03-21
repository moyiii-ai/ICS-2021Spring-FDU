`include "common.svh"
`include "mycpu/icode.svh"

module decode (
    input logic [31:0] instr, pc,
    input logic [31:0] vs, vt,
    output logic j,
    output logic [8:0] controlD,
    output logic [4:0] rsD, rtD, rdD, shamtD,
    output logic [31:0] immD

);
    /*control :
    sign_extend(1) + imm_type(2)
    reg_dst(2) + reg_write(1) + 
    alu_shamt(1) + alu_imm(1) + alu_funct(4) +
    memtoreg(1) + mem_write(1)*/
    logic [5:0] op, funct;
    logic [13:0] control;
    assign op = instr[31:26];
    assign funct = instr[5:0];
    always_comb begin
        if(op == `RTYPE) begin
            case(funct)
                `ADDU:  control = 14'b0_00_01_1_0_0_0000_0_0;
                `SUBU:  control = 14'b0_00_01_1_0_0_0001_0_0;
                `AND:   control = 14'b0_00_01_1_0_0_0010_0_0;
                `OR:    control = 14'b0_00_01_1_0_0_0011_0_0;
                `NOR:   control = 14'b0_00_01_1_0_0_0100_0_0;
                `XOR:   control = 14'b0_00_01_1_0_0_0101_0_0;
                `SLL:   control = 14'b0_00_01_1_1_0_0110_0_0;
                `SRA:   control = 14'b0_00_01_1_1_0_0111_0_0;
                `SRL:   control = 14'b0_00_01_1_1_0_1000_0_0;
                `SLT:   control = 14'b0_00_01_1_0_0_1001_0_0;
                `SLTU:  control = 14'b0_00_01_1_0_0_1010_0_0;
                `JR:    control = 14'b0_00_00_0_0_0_0000_0_0;
                default: control = 0;
            endcase
        end
        else begin
            case(op)
                `ADDIU: control = 14'b1_00_10_1_0_1_0000_0_0;
                `ANDI:  control = 14'b0_00_10_1_0_1_0010_0_0;
                `ORI:   control = 14'b0_00_10_1_0_1_0011_0_0;
                `XORI:  control = 14'b0_00_10_1_0_1_0101_0_0;
                `SLTI:  control = 14'b1_00_10_1_0_1_1001_0_0;
                `SLTIU: control = 14'b1_00_10_1_0_1_1010_0_0;
                `LUI:   control = 14'b0_01_10_1_0_1_1111_0_0;
                `BEQ:   control = 14'b1_10_00_0_0_1_1110_0_0;
                `BNE:   control = 14'b1_10_00_0_0_1_1110_0_0;
                `LW:    control = 14'b1_00_10_1_0_1_0000_1_0;
                `SW:    control = 14'b1_00_00_0_0_1_0000_0_1;
                `J:     control = 14'b0_00_00_0_0_0_0000_0_0;
                `JAL:   control = 14'b0_11_11_1_0_1_1111_0_0;
                default: control = 0;
            endcase
        end
    end

    logic [15:0] st_imm;
    logic [4:0] rd;
    assign rsD = instr[25:21];
    assign rtD = instr[20:16];
    assign rd = instr[15:11];
    assign st_imm = instr[15:0];
    assign shamtD = instr[10:6];

    logic sign_extend;
    logic [1:0] reg_dst, imm_type;
    // reg_dst: 00:0  01:rd 10:rt 11:31
    //imm_tpye: 00:ext_imm 01:imm<<16 10:imm<<2 11:pc+4
    assign sign_extend = control[13];
    assign imm_type = control[12:11];
    assign reg_dst = control[10:9];

    always_comb begin
        case(reg_dst)
            2'b00: rdD = 0;
            2'b01: rdD = rd;
            2'b10: rdD = rtD;
            2'b11: rdD = 31;
            default: rdD = 0;
        endcase
    end

    logic [31:0] ext_imm;
    extension Extension(
        .sign_extend, 
        .immI(st_imm),
        .imm(ext_imm)
    );

    always_comb begin
        case(imm_type)
            2'b00: immD = ext_imm;
            2'b01: immD = ext_imm << 16;
            2'b10: immD = ext_imm << 2;
            2'b11: immD = pc + 8;
            default: immD = ext_imm;
        endcase 
    end
    
    assign j = ((op == `BEQ) & (vs == vt)) | ((op == `BNE) & (vs != vt));
    assign controlD = control[8:0];
endmodule

module extension (
    input logic sign_extend,
    input logic [15:0] immI,
    output logic [31:0] imm
);
    always_comb begin
        if(sign_extend)
            imm = {{16{immI[15]}}, immI};
        else
            imm = {16'b0, immI};
    end
endmodule