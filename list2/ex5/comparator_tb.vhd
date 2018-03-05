LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
ENTITY comparator_tb IS
	constant width : integer := 3;	-- editable width
	constant max : integer := 2**width - 1;
END comparator_tb;
 
ARCHITECTURE behavior OF comparator_tb IS 
	-- inputs
	signal a, b : std_logic_vector(width-1 downto 0) :=(others => '0');

	-- outputs
	signal less, equal, greater :  std_logic:='0';
 
BEGIN
	-- instantiate the Unit Under Test (UUT)
	uut: entity work.comparator 
		generic map (width => width) 
		PORT MAP (a, b, less, equal, greater);

	-- definition of simulation process
	tb_proc: process
	begin
		wait for 3 ns;

		for i in 0 to max loop
			for j in 0 to max loop
				wait for 2 ns;
				b <= std_logic_vector(unsigned(b) + 1);
			end loop;
			a <= std_logic_vector(unsigned(a) + 1);
		end loop;

		wait;
	end process tb_proc;
END;
