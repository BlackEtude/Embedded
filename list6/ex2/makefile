all:
	ghdl -a bin_divider.vhdl
	ghdl -e bin_divider

	ghdl -a bin_divider_tb.vhdl
	ghdl -e bin_divider_tb
	ghdl -r bin_divider_tb --vcd=bin_divider.vcd --stop-time=50000ns
run:
	gtkwave bin_divider.vcd