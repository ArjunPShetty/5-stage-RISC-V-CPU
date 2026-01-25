`timescale 1ns/1ps

module uart_tx #(
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1,
    parameter PARITY    = 0  // 0: None, 1: Odd, 2: Even
)(
    input  wire              clk,
    input  wire              reset_n,
    
    // Control signals
    input  wire              tx_start,
    input  wire [7:0]        tx_data,
    output reg               tx_busy,
    output reg               tx_done,
    
    // Configuration
    input  wire              baud_tick,
    input  wire              parity_en,
    input  wire              odd_even_n, // 0: odd, 1: even
    
    // UART TX output
    output reg               tx
);

    // State definitions
    localparam IDLE       = 3'b000;
    localparam START_BIT  = 3'b001;
    localparam DATA_BITS  = 3'b010;
    localparam PARITY_BIT = 3'b011;
    localparam STOP_BIT   = 3'b100;
    
    reg [2:0] state, next_state;
    reg [3:0] bit_count;
    reg [7:0] shift_reg;
    reg       parity_bit;
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            bit_count <= 0;
            shift_reg <= 0;
            tx <= 1'b1;
            tx_busy <= 0;
            tx_done <= 0;
        end else begin
            tx_done <= 0;
            
            case (state)
                IDLE: begin
                    tx <= 1'b1;
                    tx_busy <= 0;
                    if (tx_start) begin
                        state <= START_BIT;
                        shift_reg <= tx_data;
                        tx_busy <= 1;
                        bit_count <= 0;
                    end
                end
                
                START_BIT: begin
                    if (baud_tick) begin
                        tx <= 1'b0;
                        state <= DATA_BITS;
                    end
                end
                
                DATA_BITS: begin
                    if (baud_tick) begin
                        tx <= shift_reg[0];
                        shift_reg <= {1'b0, shift_reg[7:1]};
                        bit_count <= bit_count + 1;
                        
                        if (bit_count == DATA_BITS-1) begin
                            if (PARITY != 0) begin
                                state <= PARITY_BIT;
                                // Calculate parity
                                if (PARITY == 1) // Odd parity
                                    parity_bit <= ~^tx_data;
                                else            // Even parity
                                    parity_bit <= ^tx_data;
                            end else begin
                                state <= STOP_BIT;
                            end
                        end
                    end
                end
                
                PARITY_BIT: begin
                    if (baud_tick) begin
                        tx <= parity_bit;
                        state <= STOP_BIT;
                    end
                end
                
                STOP_BIT: begin
                    if (baud_tick) begin
                        tx <= 1'b1;
                        if (bit_count == STOP_BITS) begin
                            state <= IDLE;
                            tx_busy <= 0;
                            tx_done <= 1;
                            bit_count <= 0;
                        end else begin
                            bit_count <= bit_count + 1;
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
endmodule