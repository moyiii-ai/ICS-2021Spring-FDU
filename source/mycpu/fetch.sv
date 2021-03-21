`include "common.svh"

module fetch (
    input logic [31:0] pc, instr, vs,
    input logic j, clk, stall, resetn,
    input  ibus_resp_t iresp,
    output ibus_req_t  ireq,
    output logic [31:0] pcF, instrF
);
    //pcc: selectpc  pcF: Fetch  pc:decode
    logic [31:0] pcplusD, pcc, pcplusF;
    assign pcplusD = pc + 4;
    assign pcplusF = pcF + 4;

    logic [25:0] instr_index;
    logic [15:0] imm;
    logic [31:0] jpc, bpc, sign_imm;
    assign instr_index = instr[25:0];
    assign imm = instr[15:0];
    assign sign_imm = {{16{imm[15]}}, imm};

    assign jpc = {pcplusD[31:28], instr_index, 2'b00};
    assign bpc = pcplusD + (sign_imm << 2);

    logic [5:0] op, funct;
    assign op = instr[31:26];
    assign funct = instr[5:0];

    always_comb begin
        case(op)
            `RTYPE:
                if(funct == `JR)
                    pcc = vs;
                else
                    pcc = pcplusF;
            `BNE:
                if(j)
                    pcc = bpc;
                else
                    pcc = pcplusF;
            `BEQ:
                if(j)
                    pcc = bpc;
                else
                    pcc = pcplusF;
            `J:   pcc = jpc;
            `JAL: pcc = jpc;
            default: pcc = pcplusF;
        endcase
    end

    always_ff @(posedge clk) begin
        if(~resetn)
            pcF <= 32'hbfc0_0000;
        else if(~stall)
            pcF <= pcc;
    end
    assign ireq.valid = resetn & (~stall);
    assign ireq.addr = pcF;
    assign instrF = iresp.data;
    
endmodule