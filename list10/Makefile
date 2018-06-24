test:
	ghdl -a --ieee=synopsys src/types.vhd src/txt_util.vhd src/pc.vhd src/ram.vhd src/reg.vhd src/ioreg.vhd src/mar.vhd src/acreg.vhd src/alu.vhd src/controller.vhd src/testbench.vhd	
	ghdl -e --ieee=synopsys testbench
	ghdl -r --ieee=synopsys testbench --vcd=test.vcd --stop-time=6000ns
	# gtkwave test.vcd

clean:
	rm  *.o *.vcd *.cf *_tb
