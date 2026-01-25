# Synthesis Script for UART Design
# For Xilinx Vivado

# Create project
create_project uart_controller ./build/uart_controller \
    -part xc7a35ticsg324-1L \
    -force

# Set project properties
set_property target_language Verilog [current_project]
set_property simulator_language Verilog [current_project]
set_property source_mgmt_mode All [current_project]

# Add source files
add_files -norecurse {
    ../rtl/uart_tx.v
    ../rtl/uart_rx.v
    ../rtl/baud_rate_generator.v
    ../rtl/fifo_sync.v
    ../rtl/uart_top.v
}

# Add constraints
add_files -fileset constrs_1 -norecurse ../constraints/uart_constraints.xdc

# Set top module
set_property top uart_top [current_fileset]

# Synthesis settings
set_property strategy {Vivado Synthesis Defaults} [get_runs synth_1]
set_property steps.synth_design.args.flatten_hierarchy full [get_runs synth_1]
set_property steps.synth_design.args.gated_clock_conversion off [get_runs synth_1]
set_property steps.synth_design.args.bufg 16 [get_runs synth_1]
set_property steps.synth_design.args.fanout_limit 400 [get_runs synth_1]
set_property steps.synth_design.args.directive Default [get_runs synth_1]

# Implementation settings
set_property strategy {Vivado Implementation Defaults} [get_runs impl_1]
set_property steps.opt_design.is_enabled true [get_runs impl_1]
set_property steps.opt_design.args.directive Default [get_runs impl_1]
set_property steps.place_design.args.directive Default [get_runs impl_1]
set_property steps.phys_opt_design.is_enabled true [get_runs impl_1]
set_property steps.phys_opt_design.args.directive Default [get_runs impl_1]
set_property steps.route_design.args.directive Default [get_runs impl_1]
set_property steps.post_route_phys_opt_design.is_enabled true [get_runs impl_1]
set_property steps.post_route_phys_opt_design.args.directive Default [get_runs impl_1]

# Run synthesis
puts "Starting synthesis..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check synthesis status
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Synthesis failed!"
} else {
    puts "Synthesis completed successfully!"
    
    # Open synthesized design
    open_run synth_1 -name netlist_1
    
    # Generate reports
    report_timing_summary -delay_type min_max \
        -report_unconstrained \
        -check_timing_verbose \
        -max_paths 10 \
        -input_pins \
        -file synthesis_timing.rpt
    
    report_utilization -hierarchical \
        -file synthesis_utilization.rpt
    
    report_power -file synthesis_power.rpt
    
    report_clock_networks -file synthesis_clocks.rpt
    
    puts "Synthesis reports generated:"
    puts "  - synthesis_timing.rpt"
    puts "  - synthesis_utilization.rpt"
    puts "  - synthesis_power.rpt"
    puts "  - synthesis_clocks.rpt"
}

# Run implementation
puts "\nStarting implementation..."
launch_runs impl_1 -jobs 4
wait_on_run impl_1

# Check implementation status
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "Implementation failed!"
} else {
    puts "Implementation completed successfully!"
    
    # Open implemented design
    open_run impl_1
    
    # Generate implementation reports
    report_timing_summary -delay_type min_max \
        -report_unconstrained \
        -check_timing_verbose \
        -max_paths 10 \
        -input_pins \
        -file implementation_timing.rpt
    
    report_utilization -hierarchical \
        -file implementation_utilization.rpt
    
    report_power -file implementation_power.rpt
    
    report_route_status -file implementation_route.rpt
    
    report_drc -file implementation_drc.rpt
    
    puts "Implementation reports generated:"
    puts "  - implementation_timing.rpt"
    puts "  - implementation_utilization.rpt"
    puts "  - implementation_power.rpt"
    puts "  - implementation_route.rpt"
    puts "  - implementation_drc.rpt"
}

# Generate bitstream
puts "\nGenerating bitstream..."
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    error "Bitstream generation failed!"
} else {
    puts "Bitstream generation completed!"
    
    # Export hardware
    file copy -force ./build/uart_controller/uart_controller.runs/impl_1/uart_top.bit \
        ./build/uart_top.bit
    
    # Generate programming file
    write_cfgmem -format mcs \
        -interface spi x1 \
        -size 16 \
        -loadbit {up 0x0 ./build/uart_top.bit} \
        -file ./build/uart_top.mcs \
        -force
    
    puts "Output files generated in ./build/:"
    puts "  - uart_top.bit (Bitstream)"
    puts "  - uart_top.mcs (Programming file)"
}

puts "\nSynthesis and implementation completed successfully!"
close_project