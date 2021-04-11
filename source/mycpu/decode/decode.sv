`include "common.svh"
`include "mycpu/icode.svh"

module decode (
    input logic [31:0] instr, pc,
    input logic [31:0] vs, vt,
    output logic j,
    output logic [15:0] controlD,
    output logic [4:0] rsD, rtD, rdD, shamtD,
    output logic [31:0] immD

);
    /*control :
    sign_extend(1) + imm_type(2)
    reg_dst(2) + reg_write(1) + 
    hi_read(1) + hi_write(1) + 
    lo_read(1) + lo_write(1) + 
    strobe_type(2) + mem_extend(1) + 
    alu_shamt(1) + alu_imm(1) + alu_funct(4) +
    memtoreg(1) + mem_write(1)*/
    logic [5:0] op, funct;
    logic [20:0] control;
    assign op = instr[31:26];
    assign funct = instr[5:0];
    assign rsD = instr[25:21];
    assign rtD = instr[20:16];
    always_comb begin
        if(op == `RTYPE) begin
            case(funct)
                `ADDU:  control = 21'b0_00_01_1_0000_00_0_0_0_0000_0_0;
                `SUBU:  control = 21'b0_00_01_1_0000_00_0_0_0_0001_0_0;
                `AND:   control = 21'b0_00_01_1_0000_00_0_0_0_0010_0_0;
                `OR:    control = 21'b0_00_01_1_0000_00_0_0_0_0011_0_0;
                `NOR:   control = 21'b0_00_01_1_0000_00_0_0_0_0100_0_0;
                `XOR:   control = 21'b0_00_01_1_0000_00_0_0_0_0101_0_0;
                `SLL:   begin
                    if(instr == 32'b0)
                        control = 21'b0;
                    else
                        control = 21'b0_00_01_1_0000_00_0_1_0_0110_0_0;
                end
                `SRA:   control = 21'b0_00_01_1_0000_00_0_1_0_0111_0_0;
                `SRL:   control = 21'b0_00_01_1_0000_00_0_1_0_1000_0_0;
                `SLLV:  control = 21'b0_00_01_1_0000_00_0_1_0_0110_0_0;
                `SRAV:  control = 21'b0_00_01_1_0000_00_0_1_0_0111_0_0;
                `SRLV:  control = 21'b0_00_01_1_0000_00_0_1_0_1000_0_0;
                `SLT:   control = 21'b0_00_01_1_0000_00_0_0_0_1001_0_0;
                `SLTU:  control = 21'b0_00_01_1_0000_00_0_0_0_1010_0_0;
                `MFHI:  control = 21'b0_00_01_1_1000_00_0_0_0_0000_0_0;
                `MFLO:  control = 21'b0_00_01_1_0010_00_0_0_0_0000_0_0;
                `MTHI:  control = 21'b0_00_00_0_0100_00_0_0_0_0000_0_0;
                `MTLO:  control = 21'b0_00_00_0_0001_00_0_0_0_0000_0_0;
                `MULT:  control = 21'b0_00_00_0_0101_00_0_0_0_1011_0_0;                
                `MULTU: control = 21'b0_00_00_0_0101_00_0_0_0_1100_0_0;
                `DIV:   control = 21'b0_00_00_0_0101_00_0_0_0_1101_0_0;
                `DIVU:  control = 21'b0_00_00_0_0101_00_0_0_0_1110_0_0;
                `JR:    control = 21'b0_00_00_0_0000_00_0_0_0_0000_0_0;
                `JALR:  control = 21'b0_11_01_1_0000_00_0_0_1_1111_0_0;
                default: control = 21'b0;
            endcase
        end
        else begin
            case(op)
                `ADDIU: control = 21'b1_00_10_1_0000_00_0_0_1_0000_0_0;
                `ANDI:  control = 21'b0_00_10_1_0000_00_0_0_1_0010_0_0;
                `ORI:   control = 21'b0_00_10_1_0000_00_0_0_1_0011_0_0;
                `XORI:  control = 21'b0_00_10_1_0000_00_0_0_1_0101_0_0;
                `SLTI:  control = 21'b1_00_10_1_0000_00_0_0_1_1001_0_0;
                `SLTIU: control = 21'b1_00_10_1_0000_00_0_0_1_1010_0_0;
                `LUI:   control = 21'b0_01_10_1_0000_00_0_0_1_1111_0_0;
                `LW:    control = 21'b1_00_10_1_0000_00_0_0_1_0000_1_0;
                `LH:    control = 21'b1_00_10_1_0000_01_1_0_1_0000_1_0;
                `LHU:   control = 21'b1_00_10_1_0000_01_0_0_1_0000_1_0;
                `LB:    control = 21'b1_00_10_1_0000_10_1_0_1_0000_1_0;
                `LBU:   control = 21'b1_00_10_1_0000_10_0_0_1_0000_1_0;
                `SW:    control = 21'b1_00_00_0_0000_00_0_0_1_0000_0_1;
                `SH:    control = 21'b1_00_00_0_0000_01_0_0_1_0000_0_1;
                `SB:    control = 21'b1_00_00_0_0000_10_0_0_1_0000_0_1;
                `J:     control = 21'b0_00_00_0_0000_00_0_0_0_0000_0_0;
                `JAL:   control = 21'b0_11_11_1_0000_00_0_0_1_1111_0_0;
                `REGIMM:
                    if((rtD == `BLTZAL) | (rtD == `BGEZAL))
                        control = 21'b0_11_11_1_0000_00_0_0_1_1111_0_0;
                    else
                        control = 21'b0;
                default: control = 21'b0;
            endcase
        end
    end

    logic [15:0] st_imm;
    logic [4:0] rd;
    assign rd = instr[15:11];
    assign st_imm = instr[15:0];

    logic [4:0] shamt;
    logic shamt_op;
    assign shamt_op = (funct == `SLLV) | (funct == `SRAV) | (funct == `SRLV);
    assign shamt = instr[10:6];
    always_comb begin
        if((op == `RTYPE) & shamt_op)
            shamtD = vs[4:0];
        else
            shamtD = shamt;
    end

    logic sign_extend;
    logic [1:0] reg_dst, imm_type;
    // reg_dst: 00:0  01:rd  10:rt  11:31
    //imm_tpye: 00:ext_imm 01:imm<<16 10:imm<<2 11:pc+8
    assign sign_extend = control[20];
    assign imm_type = control[19:18];
    assign reg_dst = control[17:16];

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
    
    logic beq, bne, bgtz, blez, bgez, bgezal, bltz, bltzal, regimm;
    assign beq = (op == `BEQ) & (vs == vt);
    assign bne = (op == `BNE) & (vs != vt);
    assign bgtz = (op == `BGTZ) & ($signed(vs) > 0);
    assign blez = (op == `BLEZ) & ($signed(vs) <= 0);
    assign bgez = (rtD == `BGEZ) & ($signed(vs) >= 0);
    assign bgezal = (rtD == `BGEZAL) & ($signed(vs) >= 0);
    assign bltz = (rtD == `BLTZ) & ($signed(vs) < 0);
    assign bltzal = (rtD == `BLTZAL) & ($signed(vs) < 0);
    assign regimm = (op == `REGIMM) & (bltz | bltzal | bgez | bgezal);
    assign j = beq | bne | bgtz | blez | regimm;
    assign controlD = control[15:0];
endmodule