module mod_m_counter
#(
    parameter N = 4,       // number of bits in the counter
    parameter M = 10       // Mod-M: counter rolls over after M-1
)
(
    input  wire clk,       // clock signal
    input  wire reset,     // synchronous reset
    output wire max_tick,  // high when counter reaches M-1
    output wire [N-1:0] q  // counter value
);

    // internal register to hold counter value
    reg [N-1:0] r_reg;
    wire [N-1:0] r_next;

    // register update logic
    always @(posedge clk or posedge reset) begin
        if (reset)
            r_reg <= 0;
        else
            r_reg <= r_next;
    end

    // next-state logic
    assign r_next = (r_reg == (M-1)) ? 0 : r_reg + 1;

    // output logic
    assign q = r_reg;
    assign max_tick = (r_reg == (M-1)) ? 1'b1 : 1'b0;

endmodule
