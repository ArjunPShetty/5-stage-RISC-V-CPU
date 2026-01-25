# Lint Checking Script for UART Design
# Run with: vlog -lint -work work {files}

# Set linting options
set lint_options {
    -pedanticerrors
    -warning PCDPC
    -warning IMPLICIT
    -warning LITENDIAN
    -warning MULTIDRIVEN
}

# List of files to check
set rtl_files {
    ../rtl/uart_tx.v
    ../rtl/uart_rx.v
    ../rtl/baud_rate_generator.v
    ../rtl/fifo_sync.v
    ../rtl/uart_top.v
}

# Create work library
vlib work
vmap work work

# Lint check each file
foreach file $rtl_files {
    puts "========================================"
    puts "Linting: $file"
    puts "========================================"
    
    # Compile with linting options
    set compile_result [catch {
        vlog {*}$lint_options $file
    } error_msg]
    
    if {$compile_result != 0} {
        puts "ERROR: $error_msg"
    } else {
        puts "PASS: No lint errors found"
    }
    
    puts ""
}

# Check for specific common issues
proc check_common_issues {} {
    puts "========================================"
    puts "Checking for Common Design Issues"
    puts "========================================"
    
    # Check for latch inference
    puts "Checking for unintended latches..."
    set latch_count [llength [find instances -hier -noscope *latch*]]
    if {$latch_count > 0} {
        puts "WARNING: Found $latch_count potential latch(es)"
        find instances -hier -noscope *latch*
    } else {
        puts "PASS: No latches found"
    }
    
    # Check for multiple drivers
    puts "\nChecking for multiple drivers..."
    set multi_driven [find signals -hier * -multiple_driver]
    if {[llength $multi_driven] > 0} {
        puts "WARNING: Found [llength $multi_driven] multi-driven signal(s)"
        foreach signal $multi_driven {
            puts "  $signal"
        }
    } else {
        puts "PASS: No multi-driven signals"
    }
    
    # Check for unconnected ports
    puts "\nChecking for unconnected ports..."
    set unconnected [find instances -hier * -unconnected]
    if {[llength $unconnected] > 0} {
        puts "WARNING: Found [llength $unconnected] unconnected port(s)"
        foreach port $unconnected {
            puts "  $port"
        }
    } else {
        puts "PASS: All ports connected"
    }
    
    # Check clock domain crossing
    puts "\nChecking clock domain crossing..."
    set cdc_signals [find signals -hier * -clock_crossing]
    if {[llength $cdc_signals] > 0} {
        puts "WARNING: Found [llength $cdc_signals] CDC signal(s)"
        foreach signal $cdc_signals {
            puts "  $signal"
        }
    } else {
        puts "PASS: No CDC issues found"
    }
}

# Run common checks
check_common_issues

# Generate summary report
puts "\n========================================"
puts "LINT CHECK SUMMARY"
puts "========================================"
puts "Design: UART Controller"
puts "Date: [clock format [clock seconds]]"
puts "Files Checked: [llength $rtl_files]"
puts "========================================"

# Check timing paths
proc check_timing_paths {} {
    puts "\nChecking critical timing paths..."
    
    # Create timing constraints
    create_clock -name clk -period 10 [get_ports clk]
    
    # Report timing
    report_timing -max_paths 10 -nworst 10 \
        -setup -hold -input_pins \
        -file timing_report.txt
    
    puts "Timing report saved to: timing_report.txt"
}

# Exit
puts "\nLint check completed!"
quit