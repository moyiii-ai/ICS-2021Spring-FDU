`include "common.svh"

module fetch (
    input logic [31:0] pc, instr, vs,
    input j;
    input  ibus_resp_t iresp,
    output ibus_req_t  ireq,
    output logic [31:0] pcF, instrF
);
    //pcc: selectpc  pcF: Fetch  pc:decode
    logic [31:0] pcplus, pcc;
    assign pcplus = pc + 4;

    logic [25:0] instr_index;
    logic [15:0] imm;
    logic [31:0] jpc, bpc, sign_imm;
    assign instr_index = instr[25:0];
    assign imm = instr[15:0];
    assign sign_imm = {16{imm[15]}, imm};

    assign jpc = {pcplus[31:28], instr_index, 2'b00};
    assign bpc = pcplus + (sign_imm << 2);

    logic [5:0] op, funct;
    assign op = instr[31:26];
    assign funct = instr[5:0];

    always_comb begin
        case(op)
            `RTYPE:
                if(funct == `JR)
                    pcc = vs;
                else
                    pcc = pcplus;
            `BNE:
                if(j)
                    pcc = bpc;
                else
                    pcc = pcplus;
            `BEQ:
                if(j)
                    pcc = bpc;
                else
                    pcc = pcplus;
            `J:   pcc = jpc;
            `JAL: pcc = jpc;
            default: pcc = pcplus;
        endcase
    end

    always_ff @(posedge clk) begin
        pcF <= pcc;
    end
    assign ireq.valid = 1;
    assign ireq.addr = pcF;
    assign instrF = iresp.data;
    
endmodule