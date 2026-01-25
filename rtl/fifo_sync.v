`timescale 1ns/1ps

module fifo_sync #(
    parameter WIDTH = 8,
    parameter DEPTH = 16,
    parameter ADDR_WIDTH = 4  // log2(DEPTH)
)(
    input  wire                 clk,
    input  wire                 reset_n,
    
    // Write interface
    input  wire                 wr_en,
    input  wire [WIDTH-1:0]     data_in,
    output wire                 full,
    
    // Read interface
    input  wire                 rd_en,
    output wire [WIDTH-1:0]     data_out,
    output wire                 empty,
    
    // Status
    output wire [ADDR_WIDTH:0]  count
);

    reg [WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0] wr_ptr, rd_ptr;
    reg [ADDR_WIDTH:0] fifo_count;
    
    // Write pointer logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            wr_ptr <= 0;
        end else if (wr_en && !full) begin
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= data_in;
            wr_ptr <= wr_ptr + 1;
        end
    end
    
    // Read pointer logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            rd_ptr <= 0;
        end else if (rd_en && !empty) begin
            rd_ptr <= rd_ptr + 1;
        end
    end
    
    // FIFO counter logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            fifo_count <= 0;
        end else begin
            case ({wr_en && !full, rd_en && !empty})
                2'b01: fifo_count <= fifo_count - 1;
                2'b10: fifo_count <= fifo_count + 1;
                2'b11: fifo_count <= fifo_count; // Simultaneous read/write
                default: fifo_count <= fifo_count;
            endcase
        end
    end
    
    // Status signals
    assign full  = (fifo_count == DEPTH);
    assign empty = (fifo_count == 0);
    assign count = fifo_count;
    
    // Data output (registered for better timing)
    reg [WIDTH-1:0] data_out_reg;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            data_out_reg <= 0;
        end else if (rd_en && !empty) begin
            data_out_reg <= mem[rd_ptr[ADDR_WIDTH-1:0]];
        end
    end
    
    assign data_out = data_out_reg;
    
endmodule