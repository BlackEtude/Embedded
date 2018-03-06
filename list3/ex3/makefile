all:
	ghdl -a lfsr.vhd
	ghdl -e lfsr
	ghdl -r lfsr

	ghdl -a lfsr_tb.vhd
	ghdl -e lfsr_tb
	ghdl -r lfsr_tb --vcd=lfsr.vcd --stop-time=1000ns
	
run:
	gtkwave lfsr.vcd