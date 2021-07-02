module hilo (
    input logic clk, resetn,
    input logic[31:0] hi_data, lo_data,
    input logic hi_write, lo_write,
    output logic[31:0] hi, lo
);
    i32 hi_new, lo_new, hi_save, lo_save;
    always_ff @(posedge clk) begin
        if(~resetn)
            {hi_save, lo_save} <= '0;
        else
            {hi_save, lo_save} <= {hi_new, lo_new};
    end
    always_comb begin
        {hi_new, lo_new} = {hi_save, lo_save};
        if (hi_write) begin
            hi_new = hi_data;
        end
        if (lo_write) begin
            lo_new = lo_data;
        end
    end
    assign hi = hi_new;
    assign lo = lo_new;
endmodule
