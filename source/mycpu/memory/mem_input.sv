module mem_input (
    input logic [1:0] strobe_type,
    input logic [1:0] tail,
    input logic mem_write,
    input logic [31:0] in,
    output logic [3:0] strobe,
    output logic [31:0] out
);
    always_comb begin
        if(strobe_type == 2'b00) begin
            strobe = {4{mem_write}};
            out = in;
        end 
        else if(strobe_type == 2'b01) begin
            if(tail[1] == 0) begin
                strobe = {2'b0, {2{mem_write}}};
                out[15:0] = in[15:0];
            end
            else begin
                strobe = {{2{mem_write}}, 2'b0};
                out[31:16] = in[15:0];
            end
        end
        else begin
            case(tail) 
                2'b00: begin
                    strobe = {3'b0, mem_write};
                    out[7:0] = in[7:0];
                end
                2'b01: begin 
                    strobe = {2'b0, mem_write, 1'b0};
                    out[15:8] = in[7:0];
                end
                2'b10: begin
                    strobe = {1'b0, mem_write, 2'b0};
                    out[23:16] = in[7:0];
                end
                default: begin
                    strobe = {mem_write, 3'b0};
                    out[31:24] = in[7:0];
                end
            endcase
        end
    end
endmodule