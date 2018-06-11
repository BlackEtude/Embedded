ramtb:
	ghdl -a src/txt_util.vhd src/ram.vhd src/ram_tb.vhd
	ghdl -e ram_tb
	ghdl -r ram_tb --vcd=ram.vcd --stop-time=400ns
	gtkwave ram.vcd

mempctb:
	ghdl -a src/txt_util.vhd src/pc.vhd src/ram.vhd src/mempc_tb.vhd
	ghdl -e mempc_tb
	ghdl -r mempc_tb --vcd=mempc.vcd --stop-time=400ns
	gtkwave mempc.vcd

pctb:
	ghdl -a src/txt_util.vhd src/pc.vhd src/pc_tb.vhd
	ghdl -e pc_tb
	ghdl -r pc_tb --vcd=pc.vcd --stop-time=400ns
	gtkwave pc.vcd

test:
	ghdl -a --ieee=synopsys src/types.vhd src/txt_util.vhd src/pc.vhd src/ram.vhd src/reg.vhd src/ioreg.vhd src/mar.vhd src/acreg.vhd src/alu.vhd src/controller.vhd src/testbench.vhd	
	ghdl -e --ieee=synopsys testbench
	ghdl -r testbench --vcd=test.vcd --stop-time=7000ns
	# gtkwave test.vcd

clean:
	rm  *.o *.vcd *.cf *_tb
