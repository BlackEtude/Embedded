all:
	ghdl -a lfsr.vhd
	ghdl -e lfsr
	ghdl -r lfsr

	ghdl -a lfsr_tb.vhd
	ghdl -e lfsr_tb
	ghdl -r lfsr_tb --vcd=lfsr.vcd --stop-time=4000ns

build:
	gcc -o shift_lfsr shift_lfsr_tb.c shift_lfsr.c 

run:
	gtkwave lfsr.vcd