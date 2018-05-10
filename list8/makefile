all:
	ghdl -a vhdl_txt.vhd
	
	ghdl -a lfsr.vhd
	ghdl -e lfsr

	ghdl -a lossy_channel.vhd
	ghdl -e lossy_channel


	ghdl -a transmitter.vhd
	ghdl -e transmitter

	ghdl -a receiver.vhd
	ghdl -e receiver

	ghdl -a hamming_tb.vhd
	ghdl -e hamming_tb

	ghdl -r hamming_tb