# JTAG TAP Controller

SystemVerilog implementation of a JTAG Test Access Port (TAP) controller based on the IEEE 1149.1 architecture.

## Overview

This project implements a JTAG TAP controller and associated instruction and data registers using SystemVerilog.

The design includes the 16-state JTAG TAP state machine, instruction register, data register, bypass register, instruction decoding, and TDI/TDO data paths.

## Design Features

- 16-state JTAG TAP controller
- Test-Logic-Reset and Run-Test/Idle states
- Capture-DR, Shift-DR, and Update-DR operations
- Capture-IR, Shift-IR, and Update-IR operations
- Instruction Register (IR)
- Data Register (DR)
- Bypass Register
- TDI/TDO serial data path
- Instruction decoding
- Parameterized instruction and data register widths
- Asynchronous active-low reset

## Verification

A SystemVerilog testbench is provided to verify the JTAG operation.

The testbench exercises:

- TAP reset
- Transition to Run-Test/Idle
- Instruction shifting
- Data register shifting
- BYPASS instruction
- TDI/TDO operation
- TAP state transitions

The testbench also generates a VCD waveform dump for simulation analysis.

## Repository Structure

```text
jtag-tap-controller/
│
├── rtl/
│   ├── bypass_reg.sv
│   ├── data_reg.sv
│   ├── instruction_register.sv
│   ├── jtag_top.sv
│   └── tap_controller.sv
│
├── tb/
│   └── jtag_tb.sv
│
└── README.md
