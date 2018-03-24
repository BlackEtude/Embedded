all:
	ghdl -a statemachine.vhd
	ghdl -e statemachine

	ghdl -a vhdl_txt.vhd

	ghdl -a statemachine_tb.vhd
	ghdl -e statemachine_tb
	ghdl -r statemachine_tb --stop-time=500ns