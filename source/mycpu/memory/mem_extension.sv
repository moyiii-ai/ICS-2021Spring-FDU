module mem_extension (
    input logic [1:0] strobe_type,
    input logic mem_extend,
    input logic [1:0] tail,
    input logic [31:0] in,
    output logic [31:0] out
);
    logic [31:0] v;
    always_comb begin
        if(strobe_type == 2'b00) 
            v = in;
        else if(strobe_type == 2'b01) begin
            if(tail[1] == 0)
                v = {16'b0, in[15:0]};
            else 
                v = {16'b0, in[31:16]};
        end else begin
            case(tail)
                2'b00: v = {24'b0, in[7:0]};
                2'b01: v = {24'b0, in[15:8]};
                2'b10: v = {24'b0, in[23:16]};
                default: v = {24'b0, in[31:24]};
            endcase
        end
    end
    always_comb begin
        if(strobe_type == 2'b00)
            out = v;
        else if(strobe_type == 2'b01) begin
            if(mem_extend)
                out = {{16{v[15]}}, v[15:0]};
            else
                out = {16'b0, v[15:0]};
        end
        else begin
            if(mem_extend)
                out = {{24{v[7]}}, v[7:0]};
            else
                out = {24'b0, v[7:0]};
        end
    end
endmodule