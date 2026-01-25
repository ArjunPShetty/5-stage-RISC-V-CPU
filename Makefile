# Makefile for UART Project
VIVADO = vivado
PROJECT_DIR = ./uart_project
TCL_SCRIPT = ./vivado_scripts/create_project.tcl

all: create_project

create_project:
	$(VIVADO) -mode batch -source $(TCL_SCRIPT)

simulate:
	$(VIVADO) -mode batch -source simulate.tcl

clean:
	rm -rf $(PROJECT_DIR)
	rm -rf *.jou
	rm -rf *.log
	rm -rf *.vcd
	rm -rf xsim.dir

.PHONY: all create_project simulate clean