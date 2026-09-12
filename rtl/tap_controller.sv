module tap_controller (
    input  logic TCK,
    input  logic TMS,
    input  logic TRST_n,

    output logic shift_dr,
    output logic capture_dr,
    output logic update_dr,
    output logic shift_ir,
    output logic capture_ir,
    output logic update_ir
);

typedef enum logic [3:0] {
    TEST_LOGIC_RESET = 4'd0,
    RUN_TEST_IDLE    = 4'd1,
    SELECT_DR_SCAN   = 4'd2,
    CAPTURE_DR       = 4'd3,
    SHIFT_DR         = 4'd4,
    EXIT1_DR         = 4'd5,
    PAUSE_DR         = 4'd6,
    EXIT2_DR         = 4'd7,
    UPDATE_DR        = 4'd8,
    SELECT_IR_SCAN   = 4'd9,
    CAPTURE_IR       = 4'd10,
    SHIFT_IR         = 4'd11,
    EXIT1_IR         = 4'd12,
    PAUSE_IR         = 4'd13,
    EXIT2_IR         = 4'd14,
    UPDATE_IR        = 4'd15
} tap_state_t;

tap_state_t state, next_state;

// State register
always_ff @(posedge TCK or negedge TRST_n) begin
    if (!TRST_n)
        state <= TEST_LOGIC_RESET;
    else
        state <= next_state;
end

// Next state logic
always_comb begin
    next_state = state;
    case (state)
        TEST_LOGIC_RESET: next_state = TMS ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
        RUN_TEST_IDLE:    next_state = TMS ? SELECT_DR_SCAN : RUN_TEST_IDLE;
        SELECT_DR_SCAN:   next_state = TMS ? SELECT_IR_SCAN : CAPTURE_DR;
        CAPTURE_DR:       next_state = TMS ? EXIT1_DR : SHIFT_DR;
        SHIFT_DR:         next_state = TMS ? EXIT1_DR : SHIFT_DR;
        EXIT1_DR:         next_state = TMS ? UPDATE_DR : PAUSE_DR;
        PAUSE_DR:         next_state = TMS ? EXIT2_DR : PAUSE_DR;
        EXIT2_DR:         next_state = TMS ? UPDATE_DR : SHIFT_DR;
        UPDATE_DR:        next_state = TMS ? SELECT_DR_SCAN : RUN_TEST_IDLE;

        SELECT_IR_SCAN:   next_state = TMS ? TEST_LOGIC_RESET : CAPTURE_IR;
        CAPTURE_IR:       next_state = TMS ? EXIT1_IR : SHIFT_IR;
        SHIFT_IR:         next_state = TMS ? EXIT1_IR : SHIFT_IR;
        EXIT1_IR:         next_state = TMS ? UPDATE_IR : PAUSE_IR;
        PAUSE_IR:         next_state = TMS ? EXIT2_IR : PAUSE_IR;
        EXIT2_IR:         next_state = TMS ? UPDATE_IR : SHIFT_IR;
        UPDATE_IR:        next_state = TMS ? SELECT_DR_SCAN : RUN_TEST_IDLE;
    endcase
end

// Output logic
always_comb begin
    shift_dr = 0; capture_dr = 0; update_dr = 0;
    shift_ir = 0; capture_ir = 0; update_ir = 0;

    case (state)
        CAPTURE_DR: capture_dr = 1;
        SHIFT_DR:   shift_dr   = 1;
        UPDATE_DR:  update_dr  = 1;

        CAPTURE_IR: capture_ir = 1;
        SHIFT_IR:   shift_ir   = 1;
        UPDATE_IR:  update_ir  = 1;
    endcase
end

endmodule
