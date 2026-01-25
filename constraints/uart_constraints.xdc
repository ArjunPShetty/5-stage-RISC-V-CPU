# Xilinx Design Constraints for UART Controller
# Target: Artix-7 FPGA (XC7A35T)

######################## Clock Definitions ########################
# Primary clock: 100 MHz
create_clock -name clk -period 10.000 [get_ports clk]

# Clock uncertainty
set_clock_uncertainty -setup 0.500 [get_clocks clk]
set_clock_uncertainty -hold 0.200 [get_clocks clk]

# Clock groups
set_clock_groups -asynchronous -group [get_clocks clk]

######################## Input Delays ########################
# Reset input
set_input_delay -clock clk -max 2.000 [get_ports reset_n]
set_input_delay -clock clk -min 0.500 [get_ports reset_n]

# UART RX input
set_input_delay -clock clk -max 5.000 [get_ports rx]
set_input_delay -clock clk -min 1.000 [get_ports rx]

# Control inputs
set_input_delay -clock clk -max 2.000 [get_ports {wr_en rd_en}]
set_input_delay -clock clk -min 0.500 [get_ports {wr_en rd_en}]

set_input_delay -clock clk -max 2.000 [get_ports {data_in[7:0]}]
set_input_delay -clock clk -min 0.500 [get_ports {data_in[7:0]}]

set_input_delay -clock clk -max 2.000 [get_ports {baud_divisor[15:0]}]
set_input_delay -clock clk -min 0.500 [get_ports {baud_divisor[15:0]}]

set_input_delay -clock clk -max 2.000 [get_ports {parity_config[1:0]}]
set_input_delay -clock clk -min 0.500 [get_ports {parity_config[1:0]}]

set_input_delay -clock clk -max 2.000 [get_ports loopback_en]
set_input_delay -clock clk -min 0.500 [get_ports loopback_en]

######################## Output Delays ########################
# UART TX output
set_output_delay -clock clk -max 3.000 [get_ports tx]
set_output_delay -clock clk -min 1.000 [get_ports tx]

# Status outputs
set_output_delay -clock clk -max 3.000 [get_ports {tx_full tx_busy}]
set_output_delay -clock clk -min 1.000 [get_ports {tx_full tx_busy}]

set_output_delay -clock clk -max 3.000 [get_ports {rx_empty rx_valid}]
set_output_delay -clock clk -min 1.000 [get_ports {rx_empty rx_valid}]

set_output_delay -clock clk -max 3.000 [get_ports {data_out[7:0]}]
set_output_delay -clock clk -min 1.000 [get_ports {data_out[7:0]}]

set_output_delay -clock clk -max 3.000 [get_ports {frame_error parity_error overflow_error}]
set_output_delay -clock clk -min 1.000 [get_ports {frame_error parity_error overflow_error}]

######################## False Paths ########################
# Asynchronous signals
set_false_path -from [get_ports rx]
set_false_path -to [get_ports tx]

######################## Physical Constraints ########################
# Pin assignments for Nexys A7 board
# Clock
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# Reset
set_property PACKAGE_PIN C12 [get_ports reset_n]
set_property IOSTANDARD LVCMOS33 [get_ports reset_n]
set_property PULLUP true [get_ports reset_n]

# UART
set_property PACKAGE_PIN D4 [get_ports tx]  # UART_TXD_IN
set_property IOSTANDARD LVCMOS33 [get_ports tx]
set_property PACKAGE_PIN D3 [get_ports rx]  # UART_RXD_OUT
set_property IOSTANDARD LVCMOS33 [get_ports rx]

# LEDs for status (optional)
set_property PACKAGE_PIN H17 [get_ports tx_busy]
set_property IOSTANDARD LVCMOS33 [get_ports tx_busy]
set_property PACKAGE_PIN K15 [get_ports rx_valid]
set_property IOSTANDARD LVCMOS33 [get_ports rx_valid]
set_property PACKAGE_PIN J13 [get_ports frame_error]
set_property IOSTANDARD LVCMOS33 [get_ports frame_error]

######################## Timing Constraints ########################
# Max delay constraints
set_max_delay 8.000 -from [get_clocks clk] -to [get_ports tx]
set_max_delay 5.000 -from [get_ports rx] -to [get_registers *]

# Multi-cycle paths
set_multicycle_path 2 -setup -from [get_clocks clk] -to [get_ports tx]
set_multicycle_path 1 -hold -from [get_clocks clk] -to [get_ports tx]

######################## Optimization Constraints ########################
# Prevent shift register optimization
set_property KEEP_HIERARCHY yes [get_cells uart_top_inst]
set_property DONT_TOUCH true [get_cells uart_top_inst/*fifo*]

# ROM/ROM inference
set_property ROM_STYLE distributed [get_cells *state_reg*]

# FIFO implementation
set_property RAM_STYLE block [get_cells *fifo_inst/mem*]