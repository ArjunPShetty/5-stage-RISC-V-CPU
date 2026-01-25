`timescale 1ns/1ps

module uart_loopback_tb;
    
    // Parameters
    parameter CLK_PERIOD = 10; // 100 MHz
    parameter BAUD_RATE = 115200;
    
    // DUT signals
    reg clk;
    reg reset_n;
    wire tx;
    wire rx;
    reg wr_en;
    reg [7:0] data_in;
    wire tx_full;
    wire tx_busy;
    reg rd_en;
    wire [7:0] data_out;
    wire rx_empty;
    wire rx_valid;
    
    reg [15:0] baud_divisor;
    reg [1:0] parity_config;
    reg loopback_en;
    wire frame_error;
    wire parity_error;
    wire overflow_error;
    
    // Testbench variables
    integer i, error_count;
    reg [7:0] expected_data;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // Connect RX to TX for loopback
    assign rx = tx;
    
    // Instantiate DUT
    uart_top #(
        .CLK_FREQ(100_000_000),
        .BAUD_RATE(BAUD_RATE),
        .DATA_BITS(8),
        .STOP_BITS(1),
        .PARITY(0),
        .FIFO_DEPTH(16)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .tx(tx),
        .rx(rx),
        .wr_en(wr_en),
        .data_in(data_in),
        .tx_full(tx_full),
        .tx_busy(tx_busy),
        .rd_en(rd_en),
        .data_out(data_out),
        .rx_empty(rx_empty),
        .rx_valid(rx_valid),
        .baud_divisor(baud_divisor),
        .parity_config(parity_config),
        .loopback_en(loopback_en),
        .frame_error(frame_error),
        .parity_error(parity_error),
        .overflow_error(overflow_error)
    );
    
    // Test procedure
    initial begin
        // Initialize
        error_count = 0;
        reset_n = 0;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;
        baud_divisor = 0; // Use default
        parity_config = 0;
        loopback_en = 0; // Use external loopback
        
        // Reset sequence
        #100;
        reset_n = 1;
        #100;
        
        $display("Starting UART Loopback Testbench");
        
        // Test 1: Single byte loopback
        $display("Test 1: Single byte loopback");
        data_in = 8'h55;
        expected_data = 8'h55;
        
        @(posedge clk);
        wr_en = 1;
        @(posedge clk);
        wr_en = 0;
        
        // Wait for transmission
        #10000;
        
        // Read received data
        wait(!rx_empty);
        @(posedge clk);
        rd_en = 1;
        @(posedge clk);
        rd_en = 0;
        
        if (data_out !== expected_data) begin
            $error("Mismatch! Expected 0x%h, Got 0x%h", expected_data, data_out);
            error_count = error_count + 1;
        end
        
        #100;
        
        // Test 2: Multiple bytes
        $display("Test 2: Multiple bytes loopback");
        for (i = 0; i < 10; i = i + 1) begin
            data_in = i;
            expected_data = i;
            
            @(posedge clk);
            wr_en = 1;
            @(posedge clk);
            wr_en = 0;
            
            // Wait for transmission
            #10000;
            
            // Read
            wait(!rx_empty);
            @(posedge clk);
            rd_en = 1;
            @(posedge clk);
            rd_en = 0;
            
            if (data_out !== expected_data) begin
                $error("Mismatch at byte %0d! Expected 0x%h, Got 0x%h", 
                       i, expected_data, data_out);
                error_count = error_count + 1;
            end
            
            #100;
        end
        
        // Test 3: FIFO full test
        $display("Test 3: FIFO full test");
        for (i = 0; i < 20; i = i + 1) begin
            data_in = i;
            
            @(posedge clk);
            wr_en = 1;
            @(posedge clk);
            wr_en = 0;
            
            #1000;
        end
        
        // Read all data
        for (i = 0; i < 20; i = i + 1) begin
            if (!rx_empty) begin
                @(posedge clk);
                rd_en = 1;
                @(posedge clk);
                rd_en = 0;
                $display("Read data: 0x%h", data_out);
            end
            #1000;
        end
        
        // Summary
        $display("Test completed with %0d errors", error_count);
        if (error_count == 0) begin
            $display("SUCCESS: All tests passed!");
        end else begin
            $display("FAIL: %0d tests failed", error_count);
        end
        
        $finish;
    end
    
    // Monitor
    initial begin
        $monitor("Time = %0t, TX Full = %b, RX Empty = %b, Data Out = 0x%h", 
                 $time, tx_full, rx_empty, data_out);
    end
    
    // Waveform dump
    initial begin
        $dumpfile("uart_loopback_tb.vcd");
        $dumpvars(0, uart_loopback_tb);
    end
    
endmodule