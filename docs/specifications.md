# UART Controller Specifications

## Overview
UART (Universal Asynchronous Receiver/Transmitter) controller with configurable baud rates, data bits, stop bits, and parity.

## Features
- Configurable baud rates (9600, 19200, 38400, 57600, 115200)
- Configurable data bits (5, 6, 7, 8)
- Configurable stop bits (1, 1.5, 2)
- Configurable parity (None, Odd, Even)
- Synchronous FIFO buffers (16x8)
- Loopback test mode
- Full RTL implementation with testbenches

## Interface Signals

### Top Module Signals
- **Clock/Reset**: clk, reset_n
- **UART Interface**: tx, rx
- **Control Interface**: 
  - data_in[7:0], data_out[7:0]
  - wr_en, rd_en
  - tx_full, rx_empty
  - tx_busy, rx_busy

## Timing Requirements
- Baud Rate: 115200 bps (default)
- System Clock: 100 MHz
- Baud Clock Division: 868 (for 115200 bps @ 100MHz)

## Register Map
| Address | Name       | Description                     |
|---------|------------|---------------------------------|
| 0x00    | TX_DATA    | Transmit Data Register         |
| 0x01    | RX_DATA    | Receive Data Register          |
| 0x02    | STATUS     | Status Register                |
| 0x03    | CTRL       | Control Register               |
| 0x04    | BAUD_H     | Baud Rate High Byte            |
| 0x05    | BAUD_L     | Baud Rate Low Byte             |

## Block Diagram
┌─────────────────────────────────────────┐
│           UART TOP Module               │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐ │
│  │  UART   │  │  UART   │  │  Baud   │ │
│  │   TX    │◄─►│   RX    │  │  Rate   │ │
│  │         │  │         │  │  Gen    │ │
│  └─────────┘  └─────────┘  └─────────┘ │
│         │           │           │       │
│  ┌──────▼─────┐ ┌──▼──────┐     │       │
│  │  TX FIFO   │ │ RX FIFO │     │       │
│  └────────────┘ └─────────┘     │       │
└─────────────────────────────────┘       │
                 │                        │
           ┌─────▼────┐                  │
           │ Control  │◄─────────────────┘
           │ Interface│
           └──────────┘