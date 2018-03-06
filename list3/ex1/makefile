all:
	ghdl -a simple.vhd
	ghdl -e simple
	ghdl -r simple

	ghdl -a simple_tb.vhd
	ghdl -e simple_tb
	ghdl -r simple_tb --vcd=simple.vcd --stop-time=3000ns
	
run:
	
	gtkwave simple.vcd