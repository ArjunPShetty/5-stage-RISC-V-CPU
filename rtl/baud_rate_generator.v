`timescale 1ns/1ps

module baud_rate_generator #(
    parameter CLK_FREQ = 100_000_000,  // 100 MHz
    parameter BAUD_RATE = 115200
)(
    input  wire        clk,
    input  wire        reset_n,
    input  wire [15:0] baud_divisor,   // For dynamic baud rate
    
    output reg         baud_tick_tx,
    output reg         baud_tick_rx,
    output wire        baud_clock      // For debug
);

    // Calculate baud divisor for given frequency
    localparam BAUD_DIVISOR = CLK_FREQ / (BAUD_RATE * 16);
    
    reg [15:0] counter_tx;
    reg [15:0] counter_rx;
    reg [3:0]  oversample_counter;
    
    // Use input divisor if non-zero, otherwise use default
    wire [15:0] divisor = (baud_divisor != 0) ? baud_divisor : BAUD_DIVISOR;
    
    // TX baud generator (16x oversampling)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter_tx <= 0;
            baud_tick_tx <= 0;
        end else begin
            baud_tick_tx <= 0;
            if (counter_tx == divisor) begin
                counter_tx <= 0;
                baud_tick_tx <= 1;
            end else begin
                counter_tx <= counter_tx + 1;
            end
        end
    end
    
    // RX baud generator with 16x oversampling
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter_rx <= 0;
            oversample_counter <= 0;
            baud_tick_rx <= 0;
        end else begin
            baud_tick_rx <= 0;
            
            if (counter_rx == (divisor >> 2)) begin  // 4x oversampling for RX
                counter_rx <= 0;
                oversample_counter <= oversample_counter + 1;
                
                if (oversample_counter == 3) begin
                    baud_tick_rx <= 1;
                    oversample_counter <= 0;
                end
            end else begin
                counter_rx <= counter_rx + 1;
            end
        end
    end
    
    // Debug baud clock
    reg baud_clk_reg;
    reg [15:0] debug_counter;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            debug_counter <= 0;
            baud_clk_reg <= 0;
        end else begin
            if (debug_counter == (divisor * 8)) begin
                debug_counter <= 0;
                baud_clk_reg <= ~baud_clk_reg;
            end else begin
                debug_counter <= debug_counter + 1;
            end
        end
    end
    
    assign baud_clock = baud_clk_reg;
    
endmodule