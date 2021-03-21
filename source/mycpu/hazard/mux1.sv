module mux1(
    input logic [4:0] re, rm, rW,
    input logic [31:0] aluoutm, vW, ve,
    output logic [31:0] vHe
);
    always_comb begin
        if(re == 0)
            vHe = 0;
        else if(re == rm) 
            vHe = aluoutm;
        else if(re == rW) 
            vHe = vW;
        else
            vHe = ve;       
    end 
endmodule