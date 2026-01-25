# Modelsim/Questa Waveform Configuration File
# For UART Simulation

# Create a fresh waveform window
onerror {resume}
quietly WaveActivateNextPane {} 0

# Add clocks and reset
add wave -noupdate -divider {Clocks and Reset}
add wave -noupdate -format Logic /uart_top_tb/clk
add wave -noupdate -format Logic /uart_top_tb/reset_n

# Add UART signals
add wave -noupdate -divider {UART Interface}
add wave -noupdate -format Logic /uart_top_tb/tx
add wave -noupdate -format Logic /uart_top_tb/rx
add wave -noupdate -color Yellow -format Logic /uart_top_tb/uart_top_inst/baud_tick_tx
add wave -noupdate -color Yellow -format Logic /uart_top_tb/uart_top_inst/baud_tick_rx

# Add control interface
add wave -noupdate -divider {Control Interface}
add wave -noupdate -format Logic /uart_top_tb/wr_en
add wave -noupdate -format Logic -radix hexadecimal /uart_top_tb/data_in
add wave -noupdate -format Logic /uart_top_tb/tx_full
add wave -noupdate -format Logic /uart_top_tb/tx_busy
add wave -noupdate -format Logic /uart_top_tb/rd_en
add wave -noupdate -format Logic -radix hexadecimal /uart_top_tb/data_out
add wave -noupdate -format Logic /uart_top_tb/rx_empty
add wave -noupdate -format Logic /uart_top_tb/rx_valid

# Add status signals
add wave -noupdate -divider {Status Signals}
add wave -noupdate -format Logic /uart_top_tb/frame_error
add wave -noupdate -format Logic /uart_top_tb/parity_error
add wave -noupdate -format Logic /uart_top_tb/overflow_error

# Add FIFO status
add wave -noupdate -divider {FIFO Status}
add wave -noupdate -format Logic -radix decimal /uart_top_tb/uart_top_inst/tx_fifo_inst/count
add wave -noupdate -format Logic -radix decimal /uart_top_tb/uart_top_inst/rx_fifo_inst/count

# Add internal UART signals
add wave -noupdate -divider {Internal UART TX}
add wave -noupdate -format Logic /uart_top_tb/uart_top_inst/uart_tx_inst/state
add wave -noupdate -format Logic -radix hexadecimal /uart_top_tb/uart_top_inst/uart_tx_inst/shift_reg
add wave -noupdate -format Logic /uart_top_tb/uart_top_inst/uart_tx_inst/bit_count
add wave -noupdate -format Logic /uart_top_tb/uart_top_inst/uart_tx_inst/tx_start
add wave -noupdate -format Logic /uart_top_tb/uart_top_inst/uart_tx_inst/tx_done

add wave -noupdate -divider {Internal UART RX}
add wave -noupdate -format Logic /uart_top_tb/uart_top_inst/uart_rx_inst/state
add wave -noupdate -format Logic -radix hexadecimal /uart_top_tb/uart_top_inst/uart_rx_inst/shift_reg
add wave -noupdate -format Logic /uart_top_tb/uart_top_inst/uart_rx_inst/bit_count
add wave -noupdate -format Logic /uart_top_tb/uart_top_inst/uart_rx_inst/rx_sync
add wave -noupdate -format Logic /uart_top_tb/uart_top_inst/uart_rx_inst/rx_valid

# Configure wave display
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps

# Run simulation
run 1000us
wave zoom full