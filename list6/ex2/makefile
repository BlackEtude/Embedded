all:
	ghdl -a bin_div.vhdl
	ghdl -e bin_div

	ghdl -a bin_div_tb.vhdl
	ghdl -e bin_div_tb
	ghdl -r bin_div_tb --vcd=bin_div.vcd --stop-time=5000ns
run:
	gtkwave bin_div.vcd