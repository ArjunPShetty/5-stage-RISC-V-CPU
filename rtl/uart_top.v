`timescale 1ns/1ps

module uart_top #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD_RATE = 115200,
    parameter DATA_BITS = 8,
    parameter STOP_BITS = 1,
    parameter PARITY    = 0,
    parameter FIFO_DEPTH = 16
)(
    input  wire        clk,
    input  wire        reset_n,
    
    // UART Interface
    output wire        tx,
    input  wire        rx,
    
    // Control Interface
    input  wire        wr_en,
    input  wire [7:0]  data_in,
    output wire        tx_full,
    output wire        tx_busy,
    
    input  wire        rd_en,
    output wire [7:0]  data_out,
    output wire        rx_empty,
    output wire        rx_valid,
    
    // Configuration
    input  wire [15:0] baud_divisor,
    input  wire [1:0]  parity_config, // 00: None, 01: Odd, 10: Even
    input  wire        loopback_en,
    
    // Status
    output wire        frame_error,
    output wire        parity_error,
    output wire        overflow_error
);

    // Internal signals
    wire baud_tick_tx, baud_tick_rx;
    wire tx_fifo_empty, rx_fifo_full;
    wire tx_start;
    wire [7:0] tx_fifo_out, rx_data;
    wire tx_done, rx_valid_int;
    wire tx_fifo_rd_en, rx_fifo_wr_en;
    
    // Loopback signal
    wire rx_int = loopback_en ? tx : rx;
    
    // Baud rate generator
    baud_rate_generator #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen_inst (
        .clk(clk),
        .reset_n(reset_n),
        .baud_divisor(baud_divisor),
        .baud_tick_tx(baud_tick_tx),
        .baud_tick_rx(baud_tick_rx),
        .baud_clock()
    );
    
    // TX FIFO
    fifo_sync #(
        .WIDTH(8),
        .DEPTH(FIFO_DEPTH)
    ) tx_fifo_inst (
        .clk(clk),
        .reset_n(reset_n),
        .wr_en(wr_en),
        .data_in(data_in),
        .full(tx_full),
        .rd_en(tx_fifo_rd_en),
        .data_out(tx_fifo_out),
        .empty(tx_fifo_empty),
        .count()
    );
    
    // RX FIFO
    fifo_sync #(
        .WIDTH(8),
        .DEPTH(FIFO_DEPTH)
    ) rx_fifo_inst (
        .clk(clk),
        .reset_n(reset_n),
        .wr_en(rx_fifo_wr_en),
        .data_in(rx_data),
        .full(rx_fifo_full),
        .rd_en(rd_en),
        .data_out(data_out),
        .empty(rx_empty),
        .count()
    );
    
    // UART Transmitter
    uart_tx #(
        .DATA_BITS(DATA_BITS),
        .STOP_BITS(STOP_BITS),
        .PARITY(PARITY)
    ) uart_tx_inst (
        .clk(clk),
        .reset_n(reset_n),
        .tx_start(tx_start),
        .tx_data(tx_fifo_out),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .baud_tick(baud_tick_tx),
        .parity_en(parity_config != 0),
        .odd_even_n(parity_config[0]), // 0: odd, 1: even
        .tx(tx)
    );
    
    // UART Receiver
    uart_rx #(
        .DATA_BITS(DATA_BITS),
        .STOP_BITS(STOP_BITS),
        .PARITY(PARITY)
    ) uart_rx_inst (
        .clk(clk),
        .reset_n(reset_n),
        .rx(rx_int),
        .rx_valid(rx_valid_int),
        .rx_data(rx_data),
        .rx_error(),
        .rx_busy(),
        .baud_tick(baud_tick_rx),
        .parity_en(parity_config != 0),
        .frame_error(frame_error),
        .parity_error(parity_error)
    );
    
    // TX Controller
    assign tx_start = !tx_fifo_empty && !tx_busy;
    assign tx_fifo_rd_en = tx_start;
    
    // RX Controller
    assign rx_fifo_wr_en = rx_valid_int && !rx_fifo_full;
    assign rx_valid = !rx_empty;
    assign overflow_error = rx_valid_int && rx_fifo_full;
    
endmodule