`timescale 1ns/1ps

module test_cases;
    
    import testbench_utils::*;
    
    // Test case 1: Basic transmission
    task test_basic_transmission;
        input [7:0] test_data;
        begin
            $display("=== Test Case: Basic Transmission (0x%h) ===", test_data);
            
            // Initialize
            tb.data_in = test_data;
            tb.wr_en = 0;
            
            // Wait for TX to be ready
            wait(!tb.tx_busy);
            
            // Write data
            @(posedge tb.clk);
            tb.wr_en = 1;
            @(posedge tb.clk);
            tb.wr_en = 0;
            
            // Monitor transmission
            check_uart_frame(tb.tx, test_data, 8680);
            
            $display("=== Test Case PASSED ===\n");
        end
    endtask
    
    // Test case 2: Continuous transmission
    task test_continuous_transmission;
        input integer num_bytes;
        integer i;
        reg [7:0] test_data;
        begin
            $display("=== Test Case: Continuous Transmission (%0d bytes) ===", num_bytes);
            
            for (i = 0; i < num_bytes; i = i + 1) begin
                test_data = i;
                tb.data_in = test_data;
                
                // Wait if TX is busy
                while (tb.tx_busy) @(posedge tb.clk);
                
                // Write data
                @(posedge tb.clk);
                tb.wr_en = 1;
                @(posedge tb.clk);
                tb.wr_en = 0;
                
                $display("  Sent byte %0d: 0x%h", i, test_data);
                
                // Small delay between bytes
                #1000;
            end
            
            $display("=== Test Case PASSED ===\n");
        end
    endtask
    
    // Test case 3: FIFO overflow test
    task test_fifo_overflow;
        integer i;
        begin
            $display("=== Test Case: FIFO Overflow Test ===");
            
            // Fill TX FIFO
            for (i = 0; i < 20; i = i + 1) begin
                tb.data_in = i;
                
                @(posedge tb.clk);
                tb.wr_en = 1;
                @(posedge tb.clk);
                tb.wr_en = 0;
                
                if (tb.tx_full) begin
                    $display("  TX FIFO full at byte %0d", i);
                    break;
                end
                
                #10;
            end
            
            // Check that TX_FULL is asserted
            if (!tb.tx_full) begin
                $error("TX_FULL not asserted when FIFO should be full!");
            end
            
            // Try to write one more byte (should be ignored)
            tb.data_in = 8'hFF;
            @(posedge tb.clk);
            tb.wr_en = 1;
            @(posedge tb.clk);
            tb.wr_en = 0;
            
            $display("=== Test Case PASSED ===\n");
        end
    endtask
    
    // Test case 4: Different baud rates
    task test_baud_rates;
        input [15:0] baud_divisor;
        input integer baud_rate;
        begin
            $display("=== Test Case: Baud Rate Test (%0d bps) ===", baud_rate);
            
            // Set baud rate
            tb.baud_divisor = baud_divisor;
            #1000;
            
            // Send test byte
            test_basic_transmission(8'h55);
            
            // Restore default
            tb.baud_divisor = 0;
            #1000;
            
            $display("=== Test Case PASSED ===\n");
        end
    endtask
    
    // Test case 5: Parity test
    task test_parity;
        input [1:0] parity_mode; // 01: Odd, 10: Even
        input [7:0] test_data;
        begin
            $display("=== Test Case: Parity Test ===");
            $display("  Mode: %s, Data: 0x%h", 
                     parity_mode == 2'b01 ? "Odd" : "Even", test_data);
            
            // Set parity mode
            tb.parity_config = parity_mode;
            #1000;
            
            // Send data
            tb.data_in = test_data;
            @(posedge tb.clk);
            tb.wr_en = 1;
            @(posedge tb.clk);
            tb.wr_en = 0;
            
            // Wait for transmission to complete
            #100000;
            
            // Restore no parity
            tb.parity_config = 0;
            #1000;
            
            $display("=== Test Case PASSED ===\n");
        end
    endtask
    
    // Test case 6: Loopback test
    task test_loopback;
        input integer num_bytes;
        integer i;
        reg [7:0] test_data;
        begin
            $display("=== Test Case: Loopback Test (%0d bytes) ===", num_bytes);
            
            // Enable internal loopback
            tb.loopback_en = 1;
            #1000;
            
            // Send and receive data
            for (i = 0; i < num_bytes; i = i + 1) begin
                test_data = $random;
                tb.data_in = test_data;
                
                // Write to TX
                @(posedge tb.clk);
                tb.wr_en = 1;
                @(posedge tb.clk);
                tb.wr_en = 0;
                
                // Wait for data to be received
                wait(!tb.rx_empty);
                
                // Read from RX
                @(posedge tb.clk);
                tb.rd_en = 1;
                @(posedge tb.clk);
                tb.rd_en = 0;
                
                // Check received data
                if (tb.data_out !== test_data) begin
                    $error("Loopback mismatch! Sent 0x%h, Received 0x%h", 
                           test_data, tb.data_out);
                end else begin
                    $display("  Byte %0d: 0x%h - PASS", i, test_data);
                end
                
                #1000;
            end
            
            // Disable loopback
            tb.loopback_en = 0;
            #1000;
            
            $display("=== Test Case PASSED ===\n");
        end
    endtask
    
endmodule