all:
	ghdl -a twoway.vhd
	ghdl -e twoway
	ghdl -r twoway

	ghdl -a twoway_tb.vhd
	ghdl -e twoway_tb
	ghdl -r twoway_tb --vcd=twoway.vcd --stop-time=10000ns
	
run:
	gtkwave twoway.vcd