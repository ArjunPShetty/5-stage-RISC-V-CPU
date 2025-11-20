module UART_TOP (
    input  wire clk,
    input  wire reset,
    input  wire [7:0] data_in,
    input  wire send,
    output wire [7:0] data_out,
    output wire done_tx,
    output wire done_rx
);

    wire tx_line;

    UART_TX #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(9600)
    ) tx_inst (
        .clk(clk),
        .reset(reset),
        .tx_data(data_in),
        .tx_start(send),
        .tx(tx_line),
        .tx_done(done_tx)
    );

    UART_RX #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(9600)
    ) rx_inst (
        .clk(clk),
        .reset(reset),
        .rx(tx_line),
        .rx_data(data_out),
        .rx_done(done_rx)
    );

endmodule
