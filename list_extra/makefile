all:
	ghdl -a slave.vhd
	ghdl -e slave

	ghdl -a slave_tb.vhd
	ghdl -e slave_tb

run:
	ghdl -r slave_tb --vcd=slave.vcd

wave:
	gtkwave slave.vcd