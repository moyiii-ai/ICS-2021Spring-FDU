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