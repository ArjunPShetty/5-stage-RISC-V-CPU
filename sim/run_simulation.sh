#!/bin/bash

# UART Simulation Script
# Usage: ./run_simulation.sh [test_name]

# Variables
SIMULATOR="iverilog"  # Change to "vcs", "modelsim", etc. as needed
TESTBENCH="uart_loopback_tb.v"
TOP_MODULE="uart_loopback_tb"
VCD_FILE="simulation.vcd"
LOG_FILE="simulation.log"

# Source files
RTL_FILES="\
    ../rtl/uart_tx.v \
    ../rtl/uart_rx.v \
    ../rtl/baud_rate_generator.v \
    ../rtl/fifo_sync.v \
    ../rtl/uart_top.v"

TB_FILES="\
    ../tb/uart_tx_tb.v \
    ../tb/uart_rx_tb.v \
    ../tb/uart_loopback_tb.v \
    ../tb/testbench_utils.v \
    ../tb/test_cases.v"

# Function to run simulation with iverilog
run_iverilog() {
    echo "Compiling with Icarus Verilog..."
    
    # Compile
    iverilog -g2012 -o ${TOP_MODULE}.vvp \
        -I../rtl \
        -I../tb \
        ${RTL_FILES} \
        ${TB_FILES} \
        ${TESTBENCH}
    
    if [ $? -ne 0 ]; then
        echo "Compilation failed!"
        exit 1
    fi
    
    echo "Running simulation..."
    
    # Run simulation
    vvp ${TOP_MODULE}.vvp \
        -lxt2 \
        -vcd ${VCD_FILE} \
        2>&1 | tee ${LOG_FILE}
    
    if [ $? -ne 0 ]; then
        echo "Simulation failed!"
        exit 1
    fi
    
    echo "Simulation completed successfully!"
    echo "Waveform saved to: ${VCD_FILE}"
    echo "Log saved to: ${LOG_FILE}"
}

# Function to run specific test
run_test() {
    local test_name=$1
    
    case $test_name in
        "tx")
            TESTBENCH="uart_tx_tb.v"
            TOP_MODULE="uart_tx_tb"
            ;;
        "rx")
            TESTBENCH="uart_rx_tb.v"
            TOP_MODULE="uart_rx_tb"
            ;;
        "loopback")
            TESTBENCH="uart_loopback_tb.v"
            TOP_MODULE="uart_loopback_tb"
            ;;
        *)
            echo "Unknown test: $test_name"
            echo "Available tests: tx, rx, loopback"
            exit 1
            ;;
    esac
    
    run_iverilog
}

# Main execution
if [ $# -eq 0 ]; then
    # Run all tests
    echo "Running all tests..."
    
    echo "1. Testing UART TX..."
    run_test "tx"
    
    echo "2. Testing UART RX..."
    run_test "rx"
    
    echo "3. Testing UART Loopback..."
    run_test "loopback"
    
    echo "All tests completed!"
else
    # Run specific test
    run_test $1
fi

# Generate coverage report (if supported)
if command -v vcover &> /dev/null; then
    echo "Generating coverage report..."
    vcover report -html coverage_report.html
fi

echo "Done!"