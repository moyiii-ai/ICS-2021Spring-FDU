module mux2(
    input logic [4:0] rD, rm, 
    input logic [31:0] aluoutm, vD,
    output logic [31:0] vHD
);
    always_comb begin
        if(rm == rD)
            vHD = aluoutm;
        else 
            vHD = vD;
    end
endmodule