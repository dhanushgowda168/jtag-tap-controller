module data_reg #(
    parameter DR_WIDTH = 8
)(
    input  logic TCK,
    input  logic TRST_n,
    input  logic TDI,
    input  logic shift_dr,
    input  logic capture_dr,
    input  logic update_dr,

    output logic [DR_WIDTH-1:0] data_out,
    output logic tdo
);

logic [DR_WIDTH-1:0] shift_reg;

// STANDARD: MSB-first
always_ff @(posedge TCK or negedge TRST_n) begin
    if (!TRST_n)
        shift_reg <= 0;
    else if (capture_dr)
        shift_reg <= 8'hA5;
    else if (shift_dr)
        shift_reg <= {TDI, shift_reg[DR_WIDTH-1:1]};
end

// TDO from LSB
assign tdo = shift_reg[0];

// Update
always_ff @(negedge TCK or negedge TRST_n) begin
    if (!TRST_n)
        data_out <= 0;
    else if (update_dr)
        data_out <= shift_reg;
end

endmodule
