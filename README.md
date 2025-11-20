# UART TX/RX — Verilog 

UART TX/RX Project (Vivado RTL)

This project implements a complete UART Transmitter (TX) and Receiver (RX) in Verilog, along with a top-level integration module and a simulation testbench. It is designed to run entirely in AMD Vivado without requiring any FPGA hardware.
 
Features 
✔ UART Transmitter (TX)  
Parameterized clock frequency and baud rate  
Generates start bit, 8 data bits, stop bit  
Signals tx_done when transmission is complete  
Fully synchronous logic  
 
✔ UART Receiver (RX)  
Detects start bit and samples incoming bits  
Reconstructs 8-bit data  
Signals rx_done after a full byte is received  
Uses double-synced RX input  
 
✔ Top Module (UART_TOP)    
Connects TX output to RX input  
Provides a complete loopback system  
Perfect for simulation and debugging  
 
✔ Testbench (uart_tb.v)  
Generates clock  
Automates TX send sequences  
Waits for RX reception  
Simulates two test bytes (A5 and 3C)  
Ends simulation automatically  
