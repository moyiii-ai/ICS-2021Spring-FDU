`include "common.svh"
`include "mycpu/icode.svh"

module fetch (
    input logic [31:0] pc, instr, vs,
    input logic j, clk, stall, resetn,
    input  ibus_resp_t iresp,
    output ibus_req_t  ireq,
    output logic inslot, AddrError,
    output logic [31:0] pcF, instrF, BadVaddr
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
        insolt = 0;
        case(op)
            `RTYPE:
                if((funct == `JR) | (funct == `JALR))
                    pcc = vs;
                    insolt = 1;
                else
                    pcc = pcplusF;
            `J: begin
                pcc = jpc;
                insolt = 1;
            end
            `JAL: begin
                pcc = jpc;
                insolt = 1;
            end
            default:
                if(j) begin
                    pcc = bpc;
                    insolt = 1;
                end
                else
                    pcc = pcplusF;
        endcase
    end

    logic [31:0] tempc;
    always_ff @(posedge clk) begin
        if(~resetn) begin
            pcF <= 32'hbfc0_0000;
            tempc <= 32'hbfc0_0000;
        end
        else if(~stall) begin
            pcF <= pcc;
            tempc <= pcc;
        end
        else begin
            tempc <= pcF;
        end
    end

    always_comb begin
        if((tempc[1:0] & 3) != 2'b00) begin
            ireq.valid = 0;
            ireq.addr = 32'b0;
            AddrError = 1;
            BadVaddr = tempc;
        end else begin
            ireq.valid = 1;
            ireq.addr = tempc;
            AddrError = 0;
            BadVaddr = 32'b0;
        end
    end

    assign instrF = iresp.data;

    logic _unused_ok = &{iresp};
    
endmodule