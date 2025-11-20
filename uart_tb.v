`timescale 1ns/1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2025 15:54:42
// Design Name: 
// Module Name: uart_tb
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
//////////////////////////////////////////////////////////////////////////////////`timescale 1ns/1ps

module uart_tb;

    reg clk = 0;
    reg reset = 1;
    reg [7:0] data_in = 8'hA5;
    reg send = 0;

    wire [7:0] data_out;
    wire done_tx;
    wire done_rx;

    UART_TOP dut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .send(send),
        .data_out(data_out),
        .done_tx(done_tx),
        .done_rx(done_rx)
    );

    always #10 clk = ~clk;

    initial begin
        #100 reset = 0;

        // FIXED valid send pulse
        #200000 send = 1;
        #200000 send = 0;

        #2000000;
        $stop;
    end

endmodule

