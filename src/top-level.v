// Listing 8.4 UART Top-Level Description
module uart
#(
    // Default settings:
    // 19,200 baud, 8 data bits, 1 stop bit, 2^2 = 4-word FIFO
    parameter DBIT = 8,           // # data bits
    parameter SB_TICK = 16,       // # ticks for stop bits (16/24/32 for 1/1.5/2 stop bits)
    parameter DVSR = 163,         // baud rate divisor (e.g., 50M / (16 * baud_rate))
    parameter DVSR_BIT = 8,       // # bits of DVSR
    parameter FIFO_W = 2          // # address bits of FIFO (2^FIFO_W = depth)
)
(
    input  wire clk, reset,
    input  wire rd_uart, wr_uart, rx,
    input  wire [7:0] w_data,
    output wire tx_full, rx_empty,
    output wire tx,
    output wire [7:0] r_data
);

    // Signal declarations
    wire tick, rx_done_tick, tx_done_tick;
    wire tx_empty, tx_fifo_not_empty;
    wire [7:0] tx_fifo_out, rx_data_out;

    // Baud rate generator
    mod_m_counter #(
        .M(DVSR),
        .N(DVSR_BIT) 
) baud_gen_unit (
        .clk(clk),
        .reset(reset),
        .q(),              // Unused output
        .max_tick(tick)
    );

    // UART Receiver
    uart_rx #(
        .DBIT(DBIT),
        .SB_TICK(SB_TICK)
    ) uart_rx_unit (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .s_tick(tick),
        .rx_done_tick(rx_done_tick),
        .dout(rx_data_out)
    );

    // UART Transmit FIFO
    fifo #(
        .B(DBIT),
        .W(FIFO_W)
    ) fifo_tx_unit (
        .clk(clk),
        .reset(reset),
        .rd(tx_done_tick),
        .wr(wr_uart),
        .w_data(w_data),
        .empty(tx_empty),
        .full(tx_full),
        .r_data(tx_fifo_out)
    );

    // UART Receiver FIFO
    fifo #(
        .B(DBIT),
        .W(FIFO_W)
    ) fifo_rx_unit (
        .clk(clk),
        .reset(reset),
        .rd(rd_uart),
        .wr(rx_done_tick),
        .w_data(rx_data_out),
        .empty(rx_empty),
        .full(),               // Not connected
        .r_data(r_data)
    );

    // UART Transmitter
    uart_tx #(
        .DBIT(DBIT),
        .SB_TICK(SB_TICK)
    ) uart_tx_unit (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_fifo_not_empty),
        .s_tick(tick),
        .din(tx_fifo_out),
        .tx_done_tick(tx_done_tick),
        .tx(tx)
    );

    // tx_fifo_not_empty = NOT tx_empty
    assign tx_fifo_not_empty = ~tx_empty;

endmodule
