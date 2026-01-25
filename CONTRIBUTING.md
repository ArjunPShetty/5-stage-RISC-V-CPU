# Contributing to UART_TX-RX

Thank you for your interest in contributing to UART_TX-RX.

## How to Contribute
1. Fork the repository
2. Create a new branch for your feature or fix
3. Follow existing RTL coding and documentation standards
4. Add or update testbenches where applicable
5. Commit with clear and descriptive messages
6. Submit a pull request

## Coding Guidelines
- Use synthesizable Verilog/SystemVerilog constructs only
- Follow synchronous design practices
- Avoid hard-coded values; use parameters
- Maintain readability and modularity

## **Complete Files List :**

## **1. Core UART Modules:**
1. **`rtl/uart/baud_rate_generator.v`** - Baud rate generator with oversampling support
2. **`rtl/uart/uart_tx.v`** - UART transmitter with configurable data width, stop bits, parity
3. **`rtl/uart/uart_rx.v`** - UART receiver with error detection (parity, framing)
4. **`rtl/uart/uart_top.v`** - Top-level UART module integrating TX, RX, and baud generator

## **2. FIFO & Buffering:**
5. **`rtl/fifo/sync_fifo.v`** - Synchronous FIFO for TX/RX buffering
6. **`rtl/fifo/async_fifo.v`** - Asynchronous FIFO for clock domain crossing
7. **`rtl/fifo/fifo_ctrl.v`** - FIFO controller with status flags

## **3. Interface Modules:**
8. **`rtl/interface/axi4lite_uart.v`** - AXI4-Lite interface wrapper for UART
9. **`rtl/interface/apb_uart.v`** - APB interface wrapper for UART
10. **`rtl/interface/wishbone_uart.v`** - Wishbone interface wrapper for UART
11. **`rtl/interface/uart_registers.v`** - Configuration and status registers

## **4. Utility Modules:**
12. **`rtl/utils/synchronizer.v`** - Dual-flop synchronizer for metastability protection
13. **`rtl/utils/edge_detector.v`** - Edge detection for start/stop bits
14. **`rtl/utils/parity_generator.v`** - Parity calculation module
15. **`rtl/utils/uart_loopback.v`** - Loopback test module

## **5. Testbenches:**
16. **`verification/tb/uart_tx_tb.v`** - Transmitter testbench with directed tests
17. **`verification/tb/uart_rx_tb.v`** - Receiver testbench with error injection
18. **`verification/tb/uart_loopback_tb.v`** - Full loopback testbench
19. **`verification/tb/baud_gen_tb.v`** - Baud rate generator testbench
20. **`verification/tb/uart_top_tb.v`** - Top-level module testbench
21. **`verification/tb/testbench_utils.v`** - Test utilities and functions
22. **`verification/tb/uart_monitor.v`** - Verification monitor for protocol checking
23. **`verification/tb/uart_scoreboard.v`** - Scoreboard for data comparison

## **6. Configuration & Common Files:**
24. **`rtl/common/uart_defines.vh`** - UART parameters, states, error codes
25. **`rtl/common/uart_config.vh`** - Configuration for data width, baud rate, parity
26. **`rtl/common/uart_types.vh`** - Type definitions for FSM states

## **7. Top-Level & Integration:**
27. **`rtl/top/uart_system.v`** - Complete UART system with FIFOs and interfaces
28. **`rtl/top/uart_with_interrupts.v`** - UART with interrupt controller
29. **`rtl/top/uart_with_dma.v`** - UART with DMA support

## **8. Simulation & Scripts:**
30. **`scripts/sim/run_simulation.sh`** - Main simulation script
31. **`scripts/sim/run_iverilog.sh`** - Icarus Verilog simulation script
32. **`scripts/sim/wave.do`** - Modelsim waveform script
33. **`scripts/sim/sim_config.vh`** - Simulation configuration parameters

## **9. Synthesis & Implementation:**
34. **`constraints/uart_constraints.xdc`** - Vivado timing and pin constraints
35. **`constraints/uart_timing.sdc`** - Quartus timing constraints
36. **`scripts/synth/synth_uart.tcl`** - Synthesis script for FPGA
37. **`scripts/synth/impl_uart.tcl`** - Implementation script

## **10. Verification & Formal:**
38. **`verification/formal/uart_properties.sva`** - SystemVerilog Assertions
39. **`verification/formal/cover_points.sv`** - Coverage points
40. **`verification/uvm/uart_agent.sv`** - UVM agent for verification
41. **`verification/uvm/uart_env.sv`** - UVM test environment

## **11. Makefile & Build System:**
42. **`Makefile`** - Complete build system with targets:
    - `make sim` - Run simulation
    - `make synth` - Run synthesis
    - `make lint` - Run lint check
    - `make clean` - Clean build artifacts
43. **`scripts/build/check_tools.sh`** - Tool availability check script

## **12. Software & Drivers:**
44. **`software/drivers/uart_driver.c`** - C driver for UART
45. **`software/drivers/uart_driver.h`** - Driver header file
46. **`software/examples/uart_example.c`** - Example usage of UART
47. **`software/tests/uart_test.c`** - Software test program

## **13. Test Programs:**
48. **`software/asm/uart_loopback_test.s`** - Assembly loopback test
49. **`software/asm/baud_rate_test.s`** - Baud rate test program
50. **`scripts/generate_test_cases.py`** - Python script to generate test cases

## **14. Documentation:**
51. **`docs/uart_specification.md`** - Detailed UART specifications
52. **`docs/interface_protocol.md`** - Interface protocol documentation
53. **`docs/verification_plan.md`** - Verification methodology
54. **`README.md`** - Project README with setup instructions

## **15. Project Configuration:**
55. **`.gitignore`** - Git ignore patterns for Verilog projects
56. **`project.cfg`** - Project configuration file
57. **`version.txt`** - Project version information

## **16. Optional Advanced Features:**
58. **`rtl/advanced/uart_auto_baud.v`** - Auto-baud rate detection
59. **`rtl/advanced/uart_flow_control.v`** - Hardware flow control (RTS/CTS)
60. **`rtl/advanced/uart_multi_drop.v`** - Multi-drop (9-bit) addressing
61. **`rtl/advanced/uart_irq_controller.v`** - Interrupt controller
62. **`rtl/advanced/uart_dma_controller.v`** - DMA controller for UART

## **17. Simulation Models:**
63. **`models/uart_bfm.v`** - Bus Functional Model for UART
64. **`models/uart_reference.v`** - Golden reference model
65. **`models/memory_model.v`** - Memory model for simulation

## **18. Integration Examples:**
66. **`examples/soc/uart_peripheral.v`** - Example SoC integration
67. **`examples/fpga/uart_top_fpga.v`** - FPGA top-level with I/O
68. **`examples/asic/uart_top_asic.v`** - ASIC top-level with pads

## **19. Quality Assurance:**
69. **`qa/lint/uart_lint_rules.rules`** - Lint rules configuration
70. **`qa/coverage/coverage_plan.md`** - Coverage plan document
71. **`qa/tests/test_plan.md`** - Test plan document

## **20. Release Packaging:**
72. **`scripts/release/package_uart_ip.tcl`** - IP packaging script
73. **`scripts/release/gen_docs.py`** - Documentation generator

### Project Structure and Feature Update Policy

Contributors are requested to **keep the project structure up to date** at all times.

* If you **create a new file, folder, or module**, please update the project structure section accordingly.
* If you **modify existing modules** or **add new features**, ensure the changes are clearly reflected in:

  * Project directory tree
  * Relevant documentation (README or docs folder)
  * Comments where applicable
* Any **major architectural change or new feature** should be briefly described so that other contributors can easily understand its purpose and usage.

Keeping the project structure and documentation updated helps maintain clarity, improves collaboration, and ensures the project remains accessible to new contributors.

## Reporting Issues
Please use the GitHub Issues tab to report bugs or request enhancements.

All contributions must comply with the Code of Conduct.