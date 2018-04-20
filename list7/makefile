all:
	ghdl -a vhdl_txt.vhd
	
	ghdl -a altimeter.vhdl
	ghdl -e altimeter

	ghdl -a altimeter_tb.vhdl
	ghdl -e altimeter_tb
	ghdl -r altimeter_tb
run:
	gtkwave bin_div.vcd