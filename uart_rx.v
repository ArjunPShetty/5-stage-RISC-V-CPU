`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2025 15:53:48
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_RX #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input  wire clk,
    input  wire reset,
    input  wire rx,
    output reg  [7:0] rx_data,
    output reg  rx_done
);

    localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;

    reg [15:0] baud_cnt;
    reg        baud_en;
    reg        rx_sync;
    reg [3:0]  bit_index;
    reg [7:0]  temp_data;
    reg        receiving;

    always @(posedge clk) rx_sync <= rx;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_cnt <= 0;
            baud_en  <= 0;
        end else begin
            if (baud_cnt == BAUD_TICK-1) begin
                baud_cnt <= 0;
                baud_en  <= 1;
            end else begin
                baud_cnt <= baud_cnt + 1;
                baud_en  <= 0;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            receiving <= 0;
            bit_index <= 0;
            rx_done   <= 0;
        end else begin
            rx_done <= 0;

            if (!receiving && !rx_sync) begin
                receiving <= 1;
                bit_index <= 0;
            end

            if (receiving && baud_en) begin
                if (bit_index < 8) begin
                    temp_data[bit_index] <= rx_sync;
                    bit_index <= bit_index + 1;
                end else begin
                    receiving <= 0;
                    rx_data <= temp_data;
                    rx_done <= 1;
                end
            end
        end
    end
endmodule

