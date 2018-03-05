ghdl -a comparator.vhd
ghdl -e comparator

ghdl -a comparator_tb.vhd
ghdl -e comparator_tb
ghdl -r comparator_tb --vcd=comparator.vcd

gtkwave comparator.vcd