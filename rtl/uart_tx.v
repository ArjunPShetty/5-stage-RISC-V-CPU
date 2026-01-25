module UART_TX #(
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input  wire       clk,
    input  wire       reset,
    input  wire [7:0] tx_data,
    input  wire       tx_start,
    output reg        tx,
    output reg        tx_done
);

    localparam BAUD_TICK = CLK_FREQ / BAUD_RATE;

    reg [15:0] baud_cnt;
    reg        baud_en;
    reg [3:0]  bit_index;
    reg [9:0]  tx_shift;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            baud_cnt  <= 0;
            baud_en   <= 0;
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
            tx       <= 1'b1;
            tx_done  <= 0;
            bit_index <= 0;
            tx_shift <= 10'b1111111111;
        end else begin
            tx_done <= 0;

            if (tx_start) begin
                tx_shift  <= {1'b1, tx_data, 1'b0};
                bit_index <= 0;
            end

            if (baud_en) begin
                tx <= tx_shift[0];
                tx_shift <= {1'b1, tx_shift[9:1]};

                if (bit_index == 9)
                    tx_done <= 1;
                else
                    bit_index <= bit_index + 1;
            end
        end
    end
endmodule
