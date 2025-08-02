module uart_tx
#(
    parameter DBIT = 8,         // Number of data bits
    parameter SB_TICK = 16      // Number of ticks for stop bit duration (1 stop bit = 16 ticks if 16x oversampling)
)
(
    input  wire clk, reset,
    input  wire tx_start, s_tick,         // tx_start initiates transmission, s_tick comes from baudrate generator
    input  wire [7:0] din,                // Data to be transmitted
    output reg  tx_done_tick,             // Signals end of transmission
    output wire tx                        // UART transmit line
);

    // State encoding
    localparam [1:0]
        idle  = 2'b00,
        start = 2'b01,
        data  = 2'b10,
        stop  = 2'b11;

    // Internal signals
    reg [1:0] state_reg, state_next;
    reg [3:0] s_reg, s_next;             // 4-bit sample counter (0 to 15)
    reg [2:0] n_reg, n_next;             // Bit index for DBIT
    reg [7:0] b_reg, b_next;             // Data buffer
    reg       tx_reg, tx_next;           // Output register

    // State and data registers
    always @(posedge clk, posedge reset)
        if (reset) begin
            state_reg <= idle;
            s_reg     <= 0;
            n_reg     <= 0;
            b_reg     <= 0;
            tx_reg    <= 1'b1;           // Idle line is high
        end else begin
            state_reg <= state_next;
            s_reg     <= s_next;
            n_reg     <= n_next;
            b_reg     <= b_next;
            tx_reg    <= tx_next;
        end

    // Next-state logic and output logic
    always @* begin
        // Default assignments
        state_next     = state_reg;
        tx_done_tick   = 1'b0;
        s_next         = s_reg;
        n_next         = n_reg;
        b_next         = b_reg;
        tx_next        = tx_reg;

        case (state_reg)
            idle: begin
                tx_next = 1'b1;
                if (tx_start) begin
                    state_next = start;
                    s_next     = 0;
                    b_next     = din;
                end
            end

            start: begin
                tx_next = 1'b0; // Start bit
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next     = 0;
                        state_next = data;
                        n_next     = 0;
                    end else
                        s_next = s_reg + 1;
                end
            end

            data: begin
                tx_next = b_reg[0];
                if (s_tick) begin
                    if (s_reg == 15) begin
                        s_next = 0;
                        b_next = b_reg >> 1;
                        if (n_reg == (DBIT - 1))
                            state_next = stop;
                        else
                            n_next = n_reg + 1;
                    end else
                        s_next = s_reg + 1;
                end
            end

            stop: begin
                tx_next = 1'b1;
                if (s_tick) begin
                    if (s_reg == (SB_TICK - 1)) begin
                        state_next   = idle;
                        tx_done_tick = 1'b1;
                    end else
                        s_next = s_reg + 1;
                end
            end
        endcase
    end

    // Output assignment
    assign tx = tx_reg;

endmodule
