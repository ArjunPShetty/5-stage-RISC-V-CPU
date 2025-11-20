# UART TX/RX — Verilog 

This project implements a complete UART communication system in Verilog, 
including both Transmitter (TX) and Receiver (RX). The design is fully 
synthesizable and verified using a behavioral testbench.

 🚀 Features 
✔ UART Transmitter (TX)  
✔ UART Receiver (RX)  
✔ Parameterized Baud Rate  
✔ Parameterized Clock Frequency  
✔ Start, Data, and Stop bits  
✔ Fully synthesizable (Vivado tested)  
✔ Complete Testbench Included  

📡 UART Protocol Overview  
This design uses:
- **1 Start bit (0)**
- **8 Data bits (LSB first)**
- **1 Stop bit (1)**
- **Baud Tick Generator** derived from system clock

🧩 TX Module (UART_TX)  
- Converts parallel 8-bit data into serial output
- Generates proper baud timing
- Outputs start + data + stop bits
- Provides `tx_busy` status

🧩 RX Module (UART_RX)  
- Samples incoming serial data
- Detects start bit
- Captures 8 serial bits
- Stores final byte in `rx_data`
- Pulses `rx_done` when a byte is received
