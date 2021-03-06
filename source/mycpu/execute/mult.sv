module mult (
    input logic [31:0] hie, loe,
    input logic [31:0] in1, in2,
    input logic [3:0] funct,
    output logic [31:0] hiE, loE
);
    logic [63:0] ans;
    always_comb begin
        case (funct)
            4'b1011: begin
                ans = signed'({{32{in1[31]}}, in1}) * signed'({{32{in2[31]}}, in2});
                hiE = ans[63:32]; loE = ans[31:0];
                
            end
            4'b1100: begin
                ans = {32'b0, in1} * {32'b0, in2};
                hiE = ans[63:32]; loE = ans[31:0];
            end
            4'b1101: begin
                ans = 64'b0;
                loE = signed'(in1) / signed'(in2);
                hiE = signed'(in1) % signed'(in2);
            end
            4'b1110: begin
                ans = 64'b0;
                loE = in1 / in2;
                hiE = in1 % in2;
            end
            default: begin
                ans = 64'b0;
                hiE = hie;
                loE = loe;
            end
        endcase
    end
endmodule
