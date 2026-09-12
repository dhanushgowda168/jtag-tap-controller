module bypass_reg (
    input  logic TCK,
    input  logic TRST_n,
    input  logic TDI,
    input  logic shift_dr,
    input  logic capture_dr,
    output logic tdo
);

logic bypass_ff;

always_ff @(posedge TCK or negedge TRST_n) begin
    if (!TRST_n)
        bypass_ff <= 0;
    else if (capture_dr)
        bypass_ff <= 0;
    else if (shift_dr)
        bypass_ff <= TDI;
end

assign tdo = bypass_ff;

endmodule
