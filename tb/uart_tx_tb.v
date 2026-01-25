`timescale 1ns/1ps

module uart_tx_tb;
    
    // Parameters
    parameter CLK_PERIOD = 10; // 100 MHz
    parameter BAUD_RATE = 115200;
    parameter BIT_PERIOD = 1000000000 / BAUD_RATE; // ~8.68 us
    
    // DUT signals
    reg clk;
    reg reset_n;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx_busy;
    wire tx_done;
    wire tx;
    
    reg baud_tick;
    reg parity_en;
    reg odd_even_n;
    
    // Testbench variables
    integer i;
    reg [7:0] test_data;
    reg [9:0] expected_frame; // 1 start + 8 data + 1 stop
    
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
    uart_tx #(
        .DATA_BITS(8),
        .STOP_BITS(1),
        .PARITY(0)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .baud_tick(baud_tick),
        .parity_en(parity_en),
        .odd_even_n(odd_even_n),
        .tx(tx)
    );
    
    // Test procedure
    initial begin
        // Initialize
        reset_n = 0;
        tx_start = 0;
        tx_data = 0;
        parity_en = 0;
        odd_even_n = 0;
        
        // Reset sequence
        #100;
        reset_n = 1;
        #100;
        
        $display("Starting UART TX Testbench");
        
        // Test 1: Send byte 0x55 (01010101)
        test_data = 8'h55;
        expected_frame = {1'b1, test_data, 1'b0}; // LSB first
        $display("Test 1: Sending 0x%h", test_data);
        
        tx_data = test_data;
        @(posedge clk);
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;
        
        // Wait for transmission to complete
        wait(tx_done);
        #100;
        
        // Test 2: Send byte 0xAA (10101010)
        test_data = 8'hAA;
        expected_frame = {1'b1, test_data, 1'b0};
        $display("Test 2: Sending 0x%h", test_data);
        
        tx_data = test_data;
        @(posedge clk);
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;
        
        wait(tx_done);
        #100;
        
        // Test 3: Continuous transmission
        $display("Test 3: Continuous transmission");
        for (i = 0; i < 10; i = i + 1) begin
            test_data = i;
            tx_data = test_data;
            
            @(posedge clk);
            tx_start = 1;
            @(posedge clk);
            tx_start = 0;
            
            wait(tx_done);
            #100;
        end
        
        // Test 4: Parity test
        $display("Test 4: Parity test");
        parity_en = 1;
        odd_even_n = 0; // Odd parity
        
        test_data = 8'h55; // 01010101, odd parity bit should be 1
        tx_data = test_data;
        
        @(posedge clk);
        tx_start = 1;
        @(posedge clk);
        tx_start = 0;
        
        wait(tx_done);
        #100;
        
        $display("All tests completed!");
        $finish;
    end
    
    // Monitor
    initial begin
        $monitor("Time = %0t, TX = %b, Busy = %b, Done = %b", 
                 $time, tx, tx_busy, tx_done);
    end
    
    // Waveform dump
    initial begin
        $dumpfile("uart_tx_tb.vcd");
        $dumpvars(0, uart_tx_tb);
    end
    
endmodule