`timescale 1ns/1ps

module uart_rx #(
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1,
    parameter PARITY    = 0  // 0: None, 1: Odd, 2: Even
)(
    input  wire              clk,
    input  wire              reset_n,
    
    // UART RX input
    input  wire              rx,
    
    // Control signals
    output reg               rx_valid,
    output reg [7:0]         rx_data,
    output reg               rx_error,
    output reg               rx_busy,
    
    // Configuration
    input  wire              baud_tick,
    input  wire              parity_en,
    
    // Status
    output reg               frame_error,
    output reg               parity_error
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
    reg       rx_sync;
    reg [1:0] rx_sync_reg;
    reg       parity_calc;
    
    // Double synchronizer for meta-stability
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rx_sync_reg <= 2'b11;
            rx_sync <= 1'b1;
        end else begin
            rx_sync_reg <= {rx_sync_reg[0], rx};
            rx_sync <= rx_sync_reg[1];
        end
    end
    
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IDLE;
            bit_count <= 0;
            shift_reg <= 0;
            rx_valid <= 0;
            rx_error <= 0;
            rx_busy <= 0;
            frame_error <= 0;
            parity_error <= 0;
            parity_calc <= 0;
        end else begin
            rx_valid <= 0;
            rx_error <= 0;
            frame_error <= 0;
            parity_error <= 0;
            
            case (state)
                IDLE: begin
                    rx_busy <= 0;
                    if (!rx_sync) begin  // Start bit detected
                        state <= START_BIT;
                        rx_busy <= 1;
                        bit_count <= 0;
                        shift_reg <= 0;
                        parity_calc <= 0;
                    end
                end
                
                START_BIT: begin
                    if (baud_tick) begin
                        // Sample at middle of start bit
                        state <= DATA_BITS;
                    end
                end
                
                DATA_BITS: begin
                    if (baud_tick) begin
                        shift_reg <= {rx_sync, shift_reg[7:1]};
                        parity_calc <= parity_calc ^ rx_sync;
                        bit_count <= bit_count + 1;
                        
                        if (bit_count == DATA_BITS-1) begin
                            if (PARITY != 0) begin
                                state <= PARITY_BIT;
                            end else begin
                                state <= STOP_BIT;
                            end
                        end
                    end
                end
                
                PARITY_BIT: begin
                    if (baud_tick) begin
                        // Check parity
                        if (PARITY == 1) begin // Odd parity
                            parity_error <= (parity_calc ^ rx_sync) != 1;
                        end else begin        // Even parity
                            parity_error <= (parity_calc ^ rx_sync) != 0;
                        end
                        state <= STOP_BIT;
                    end
                end
                
                STOP_BIT: begin
                    if (baud_tick) begin
                        // Check stop bit
                        frame_error <= !rx_sync;
                        
                        if (bit_count == STOP_BITS-1) begin
                            state <= IDLE;
                            rx_busy <= 0;
                            rx_valid <= 1;
                            rx_data <= shift_reg;
                            rx_error <= frame_error || parity_error;
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