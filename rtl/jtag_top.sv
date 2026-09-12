module jtag_top (
    input  logic TCK,
    input  logic TMS,
    input  logic TDI,
    input  logic TRST_n,
    output logic TDO
);

// Control signals
logic shift_dr, capture_dr, update_dr;
logic shift_ir, capture_ir, update_ir;

// TAP
tap_controller u_tap (
    .TCK(TCK),
    .TMS(TMS),
    .TRST_n(TRST_n),
    .shift_dr(shift_dr),
    .capture_dr(capture_dr),
    .update_dr(update_dr),
    .shift_ir(shift_ir),
    .capture_ir(capture_ir),
    .update_ir(update_ir)
);

// IR
logic [3:0] instruction;
logic tdo_ir;

instruction_register u_ir (
    .TCK(TCK),
    .TRST_n(TRST_n),
    .TDI(TDI),
    .shift_ir(shift_ir),
    .capture_ir(capture_ir),
    .update_ir(update_ir),
    .instruction(instruction),
    .tdo(tdo_ir)
);

// Instruction decode
localparam BYPASS = 4'b1111;
localparam DATA   = 4'b0001;

logic sel_bypass, sel_data;

assign sel_bypass = (instruction == BYPASS);
assign sel_data   = (instruction == DATA);

// DRs
logic tdo_bypass, tdo_data;
logic [7:0] data_out;

bypass_reg u_bypass (
    .TCK(TCK),
    .TRST_n(TRST_n),
    .TDI(TDI),
    .shift_dr(shift_dr),
    .capture_dr(capture_dr),
    .tdo(tdo_bypass)
);

data_reg u_data (
    .TCK(TCK),
    .TRST_n(TRST_n),
    .TDI(TDI),
    .shift_dr(shift_dr),
    .capture_dr(capture_dr),
    .update_dr(update_dr),
    .data_out(data_out),
    .tdo(tdo_data)
);

// MUX
logic tdo_mux;

always_comb begin
    if (shift_ir)
        tdo_mux = tdo_ir;
    else if (shift_dr) begin
        if (sel_bypass)
            tdo_mux = tdo_bypass;
        else if (sel_data)
            tdo_mux = tdo_data;
        else
            tdo_mux = 0;
    end else
        tdo_mux = 0;
end

// TDO (negedge)
always_ff @(negedge TCK or negedge TRST_n) begin
    if (!TRST_n)
        TDO <= 1'bz;
    else if (shift_ir || shift_dr)
        TDO <= tdo_mux;
    else
        TDO <= 1'bz;
end

endmodule
