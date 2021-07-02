module mem_check (
    input logic [1:0] strobe_type,
    input logic [31:0] addr, BadVaddrm,
    input logic adei,
    input logic mem_write, memtoreg,
    output logic adel, ades,
    output logic [31:0] BadVaddrM
);
    always_comb begin
        adel = 0;
        ades = 0;
        BadVaddrM = BadVaddrm;
        if(~adei) begin
            if(strobe_type == 2'b00 & addr[1:0] != 2'b00) begin
                adel = memtoreg;
                ades = mem_write;
                BadVaddrM = addr;
            end
            if(strobe_type == 2'b01 & addr[0] != 0) begin
                adel = memtoreg;
                ades = mem_write;
                BadVaddrM = addr;
            end
        end
    end
endmodule