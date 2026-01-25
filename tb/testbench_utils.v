`timescale 1ns/1ps

package testbench_utils;
    
    // Global parameters
    parameter CLK_PERIOD = 10;
    parameter RESET_TIME = 100;
    
    // Task: Apply reset
    task automatic apply_reset;
        input reg reset_signal;
        begin
            reset_signal = 0;
            #RESET_TIME;
            reset_signal = 1;
            #100;
        end
    endtask
    
    // Task: Wait for clock cycles
    task automatic wait_clocks;
        input integer num_cycles;
        begin
            repeat(num_cycles) @(posedge tb.clk);
        end
    endtask
    
    // Task: Check value with error reporting
    task automatic check_value;
        input [31:0] actual;
        input [31:0] expected;
        input string message;
        begin
            if (actual !== expected) begin
                $error("%s: Expected 0x%h, Got 0x%h", message, expected, actual);
            end else begin
                $display("%s: PASS (0x%h)", message, actual);
            end
        end
    endtask
    
    // Function: Calculate baud divisor
    function automatic [15:0] calculate_baud_divisor;
        input integer clk_freq;
        input integer baud_rate;
        begin
            calculate_baud_divisor = clk_freq / (baud_rate * 16);
        end
    endfunction
    
    // Task: Generate random byte
    task automatic random_byte;
        output [7:0] byte_out;
        begin
            byte_out = $random;
        end
    endtask
    
    // Task: UART frame checker
    task automatic check_uart_frame;
        input reg tx_signal;
        input [7:0] expected_data;
        input integer baud_period;
        integer i;
        reg [7:0] received_data;
        begin
            // Wait for start bit
            wait(tx_signal == 0);
            #(baud_period * 1.5); // Sample at middle of start bit
            
            // Receive data bits (LSB first)
            received_data = 0;
            for (i = 0; i < 8; i = i + 1) begin
                received_data[i] = tx_signal;
                #(baud_period);
            end
            
            // Check stop bit
            #(baud_period/2);
            if (tx_signal !== 1'b1) begin
                $error("Stop bit error!");
            end
            
            // Compare data
            check_value(received_data, expected_data, "UART frame check");
        end
    endtask
    
endpackage