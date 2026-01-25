# UART Controller Test Plan

## 1. Overview
This document outlines the test strategy for verifying the UART controller design.

## 2. Test Objectives
- Verify correct UART transmission and reception
- Validate FIFO operation
- Test different baud rates
- Verify parity generation and checking
- Test error conditions
- Validate loopback functionality

## 3. Test Environment
### 3.1 Simulation Tools
- Simulator: Icarus Verilog / ModelSim
- Waveform Viewer: GTKWave / ModelSim
- Linting: Verilator / SpyGlass

### 3.2 Hardware
- FPGA: Xilinx Artix-7 (Nexys A7)
- Oscilloscope: For signal integrity testing
- Logic Analyzer: For protocol verification

## 4. Test Cases

### 4.1 Unit Tests
#### 4.1.1 UART Transmitter (uart_tx)
- **TC01**: Basic byte transmission
- **TC02**: Continuous transmission
- **TC03**: Parity generation (odd/even)
- **TC04**: Stop bits (1, 1.5, 2)
- **TC05**: Data bits (5, 6, 7, 8)

#### 4.1.2 UART Receiver (uart_rx)
- **TC06**: Basic byte reception
- **TC07**: Parity checking
- **TC08**: Frame error detection
- **TC09**: Baud rate tolerance (±5%)
- **TC10**: Noise immunity test

#### 4.1.3 FIFO (fifo_sync)
- **TC11**: FIFO write/read operations
- **TC12**: FIFO full condition
- **TC13**: FIFO empty condition
- **TC14**: Simultaneous read/write
- **TC15**: FIFO reset behavior

### 4.2 Integration Tests
#### 4.2.1 UART Top Module
- **TC16**: Loopback test
- **TC17**: Baud rate switching
- **TC18**: Configuration changes during operation
- **TC19**: Reset during transmission
- **TC20**: Simultaneous TX/RX

### 4.3 System Tests
#### 4.3.1 Real Hardware Tests
- **TC21**: FPGA implementation test
- **TC22**: External device communication
- **TC23**: Power cycle test
- **TC24**: Long duration test (24 hours)
- **TC25**: Temperature variation test

## 5. Test Procedures

### 5.1 Simulation Tests
```bash
# Run all tests
./sim/run_simulation.sh

# Run specific test
./sim/run_simulation.sh tx
./sim/run_simulation.sh rx
./sim/run_simulation.sh loopback