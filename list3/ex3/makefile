all:
	ghdl -a lfsr.vhd
	ghdl -e lfsr
	ghdl -r lfsr

	ghdl -a lfsr_tb.vhd
	ghdl -e lfsr_tb
	ghdl -r lfsr_tb --vcd=lfsr.vcd --stop-time=4000ns

build:
	lfsr-generator --length=16 --taps=16,15,14,5 --shift-amounts=1 --shift-left > shift_lfsr.c
	gcc -o shift_lfsr shift_lfsr_tb.c shift_lfsr.c 
	./shift_lfsr > out

run:
	gtkwave lfsr.vcd