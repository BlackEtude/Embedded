all:
	ghdl -a clk_div.vhdl
	ghdl -e clk_div

	ghdl -a clk_div_tb.vhdl
	ghdl -e clk_div_tb
	ghdl -r clk_div_tb --vcd=clk_div.vcd --stop-time=100000ns
run:
	gtkwave clk_div.vcd