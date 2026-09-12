module instruction_register #(
    parameter IR_WIDTH = 4
)(
    input  logic TCK,
    input  logic TRST_n,
    input  logic TDI,
    input  logic shift_ir,
    input  logic capture_ir,
    input  logic update_ir,

    output logic [IR_WIDTH-1:0] instruction,
    output logic tdo
);

logic [IR_WIDTH-1:0] shift_reg;

always_ff @(posedge TCK or negedge TRST_n) begin
    if (!TRST_n)
        shift_reg <= 4'b0001;   // reset pattern
    else if (capture_ir)
        shift_reg <= 4'b0001;   // ...01 pattern (IEEE)
    else if (shift_ir)
        shift_reg <= {TDI, shift_reg[IR_WIDTH-1:1]};
end

// TDO from LSB
assign tdo = shift_reg[0];

// Update
always_ff @(negedge TCK or negedge TRST_n) begin
    if (!TRST_n)
        instruction <= 4'b0001;
    else if (update_ir)
        instruction <= shift_reg;
end

endmodule
