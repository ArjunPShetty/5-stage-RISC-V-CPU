# Security Policy

## Supported Versions

Only the latest version on the `main` branch of **UART_TX-RX** is actively supported with security or correctness-related fixes.

## Reporting a Vulnerability

If you discover a security issue, functional flaw, or design behavior that could impact reliability or system safety:

* Do **not** open a public issue
* Contact the project maintainer privately
* Provide a clear description of the issue and steps to reproduce it (simulation details preferred)

Responsible disclosure is encouraged and appreciated.

## Scope

Security and safety concerns include, but are not limited to:

* UART protocol violations (framing, parity, baud mismatch)
* Unsafe or undefined RTL behavior
* FIFO overflow/underflow conditions
* Clock-domain or reset-related issues
* Data corruption or loss scenarios
* Simulation–synthesis mismatches
