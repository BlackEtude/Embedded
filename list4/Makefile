all:
	ghdl -a rom.vhd
	ghdl -e rom_for_crc8

	ghdl -a pack.vhd
	ghdl -a crc8.vhd
	ghdl -e crc8

	ghdl -a crc8_tb.vhd
	ghdl -e crc8_tb
	ghdl -r crc8_tb --vcd=crc8.vcd --stop-time=3000ns

run:
	gtkwave crc8.vcd