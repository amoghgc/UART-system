# UART-system
This project implements a complete UART (Universal Asynchronous Receiver/Transmitter) core using Verilog HDL
Baud rate generator using mod-M counter

Configurable parameters:

    Data bits (DBIT, default: 8)

    Baud rate divisor (DVSR, default: 163 for 19200 @ 50 MHz)

    Stop bit duration (SB_TICK, default: 16)

    FIFO depth (FIFO_W, default: 2 → 4 entries)

Separate RX and TX FIFOs

Clean modular design
