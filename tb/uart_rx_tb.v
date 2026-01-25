`timescale 1ns/1ps

module uart_rx_tb;
    
    // Parameters
    parameter CLK_PERIOD = 10; // 100 MHz
    parameter BAUD_RATE = 115200;
    parameter BIT_PERIOD = 1000000000 / BAUD_RATE; // ~8.68 us
    
    // DUT signals
    reg clk;
    reg reset_n;
    reg rx;
    wire rx_valid;
    wire [7:0] rx_data;
    wire rx_error;
    wire rx_busy;
    
    reg baud_tick;
    reg parity_en;
    wire frame_error;
    wire parity_error;
    
    // Testbench variables
    integer i;
    reg [9:0] test_frame; // 1 start + 8 data + 1 stop
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Baud tick generation (16x oversampling)
    initial begin
        baud_tick = 0;
        forever #(BIT_PERIOD/16) baud_tick = ~baud_tick;
    end
    
    // Instantiate DUT
    uart_rx #(
        .DATA_BITS(8),
        .STOP_BITS(1),
        .PARITY(0)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .rx(rx),
        .rx_valid(rx_valid),
        .rx_data(rx_data),
        .rx_error(rx_error),
        .rx_busy(rx_busy),
        .baud_tick(baud_tick),
        .parity_en(parity_en),
        .frame_error(frame_error),
        .parity_error(parity_error)
    );
    
    // Task to send UART frame
    task send_uart_frame;
        input [7:0] data;
        integer j;
        begin
            // Start bit
            rx = 0;
            #(BIT_PERIOD);
            
            // Data bits (LSB first)
            for (j = 0; j < 8; j = j + 1) begin
                rx = data[j];
                #(BIT_PERIOD);
            end
            
            // Stop bit
            rx = 1;
            #(BIT_PERIOD);
        end
    endtask
    
    // Test procedure
    initial begin
        // Initialize
        reset_n = 0;
        rx = 1;
        parity_en = 0;
        
        // Reset sequence
        #100;
        reset_n = 1;
        #100;
        
        $display("Starting UART RX Testbench");
        
        // Test 1: Receive byte 0x55
        $display("Test 1: Receiving 0x55");
        send_uart_frame(8'h55);
        #100;
        
        // Test 2: Receive byte 0xAA
        $display("Test 2: Receiving 0xAA");
        send_uart_frame(8'hAA);
        #100;
        
        // Test 3: Multiple bytes
        $display("Test 3: Receiving multiple bytes");
        for (i = 0; i < 8; i = i + 1) begin
            send_uart_frame(i);
            #100;
        end
        
        // Test 4: Frame error (missing stop bit)
        $display("Test 4: Frame error test");
        rx = 0; // Start bit
        #(BIT_PERIOD);
        rx = 1; // Data (only 1 bit)
        #(BIT_PERIOD * 7); // Skip remaining bits
        rx = 0; // Invalid stop bit
        #(BIT_PERIOD);
        rx = 1;
        #100;
        
        // Test 5: Parity test
        $display("Test 5: Parity test");
        parity_en = 1;
        // Note: Parity checking would need to be implemented
        
        #1000;
        
        $display("All tests completed!");
        $finish;
    end
    
    // Monitor
    initial begin
        $monitor("Time = %0t, RX = %b, Valid = %b, Data = 0x%h, Error = %b", 
                 $time, rx, rx_valid, rx_data, rx_error);
    end
    
    // Waveform dump
    initial begin
        $dumpfile("uart_rx_tb.vcd");
        $dumpvars(0, uart_rx_tb);
    end
    
endmodule