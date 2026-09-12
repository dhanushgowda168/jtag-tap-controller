`timescale 1ns/1ps

module jtag_tb;

logic TCK, TMS, TDI, TRST_n;
logic TDO;

// DUT
jtag_top dut (
    .TCK(TCK),
    .TMS(TMS),
    .TDI(TDI),
    .TRST_n(TRST_n),
    .TDO(TDO)
);

// Clock
always #5 TCK = ~TCK;


// ================= DUMP =================
initial begin
    $dumpfile("jtag.vcd");
    $dumpvars(0, jtag_tb);
end


// ================= MONITOR =================
initial begin
    $display("Time | TCK TMS TDI | SHIFT_IR SHIFT_DR | TDO");

    $monitor("%4t |  %b   %b   %b  |    %b        %b   |  %b",
        $time, TCK, TMS, TDI,
        dut.shift_ir, dut.shift_dr, TDO);
end


// ================= TASKS =================

// Reset
task jtag_reset();
begin
    $display("\n--- RESETTING TAP ---");
    TMS = 1;
    repeat(5) @(posedge TCK);
end
endtask


// Go to Idle
task goto_idle();
begin
    $display("\n--- GO TO IDLE ---");
    TMS = 0;
    @(posedge TCK);
end
endtask


// Go to SHIFT-IR
task goto_shift_ir();
begin
    $display("\n--- ENTER SHIFT-IR ---");

    TMS = 1; @(posedge TCK); // Select-DR
    TMS = 1; @(posedge TCK); // Select-IR
    TMS = 0; @(posedge TCK); // Capture-IR
    @(posedge TCK);  // ensures clean capture
    TMS = 0; @(posedge TCK); // Shift-IR
end
endtask


// Go to SHIFT-DR
task goto_shift_dr();
begin
    $display("\n--- ENTER SHIFT-DR ---");
    TMS = 1; @(posedge TCK); // Select-DR
    TMS = 0; @(posedge TCK); // Capture-DR
    TMS = 0; @(posedge TCK); // Shift-DR
end
endtask


//SHIFT TASK
task shift_bits(input [31:0] data, input int nbits);
    int i;
begin
    for (i = 0; i < nbits-1; i++) begin
        TMS = 0;
        TDI = data[i];   // LSB first
        @(posedge TCK);
        $display("SHIFT BIT %0d | TDI=%b -> TDO=%b", i, TDI, TDO);
    end

    // last bit
    TMS = 1;
    TDI = data[nbits-1];
    @(posedge TCK);
    $display("SHIFT BIT %0d (LAST) | TDI=%b -> TDO=%b", nbits-1, TDI, TDO);
end
endtask


// ================= FIXED EXIT =================
task exit_shift();
begin
    // Already moved to EXIT1 during last bit
    // So directly go to UPDATE

    @(posedge TCK); // UPDATE
    TMS = 0;        // prepare for IDLE
end
endtask


// ================= MAIN TEST =================
initial begin

    TCK = 0;
    TMS = 1;
    TDI = 0;
    TRST_n = 0;

    #20;
    TRST_n = 1;

    // RESET
    jtag_reset();
    goto_idle();

    // ================= LOAD DATA INSTRUCTION =================
    $display("\n=== LOAD DATA INSTRUCTION (0001) ===");
    goto_shift_ir();
    shift_bits(5'b11111, 5);
    exit_shift();

    $display("Instruction Loaded = %b", dut.instruction);

    // ================= SHIFT DATA =================
    $display("\n=== SHIFT DATA (10101010) ===");
    goto_shift_dr();
    shift_bits(8'b10101010, 8);
    exit_shift();

    $display("Data Register Output = %h", dut.data_out);

    // ================= LOAD BYPASS =================
    $display("\n=== LOAD BYPASS INSTRUCTION (1111) ===");
    goto_shift_ir();
    shift_bits(4'b1111, 4);
    exit_shift();

    $display("Instruction Loaded = %b", dut.instruction);

    // ================= TEST BYPASS =================
    $display("\n=== TEST BYPASS ===");
    goto_shift_dr();
    shift_bits(8'b11110000, 8);
    exit_shift();

    #50;
    $display("\n==== TEST COMPLETE ====");
    $finish;
end

endmodule
