all:
	ghdl -a slave.vhd
	ghdl -e slave

	ghdl -a slave_tb.vhd
	ghdl -e slave_tb

	ghdl -a multislave_tb.vhd
	ghdl -e multislave_tb

run:
	ghdl -r slave_tb --vcd=slave.vcd

wave:
	gtkwave slave.vcd

multi:
	ghdl -r multislave_tb --vcd=multislave.vcd

multiwave:
	gtkwave multislave.vcd