LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use std.textio.all;

ENTITY lfsr_tb IS
END lfsr_tb;
 
ARCHITECTURE behavior OF lfsr_tb IS 
	-- UUT (Unit Under Test)
	COMPONENT lfsr
	PORT(
		clk : IN  std_logic;
		q : INOUT std_logic_vector(15 downto 0) := (OTHERS => '0')
		);
	END COMPONENT;

	-- input signals
	signal clk : std_logic := '0';

	-- input/output signal
	signal qq : std_logic_vector(15 downto 0) := (OTHERS => '0');

	-- set clock period 
	constant clk_period : time := 10 ns;
 
BEGIN
	-- instantiate UUT
	uut: lfsr PORT MAP (
		clk => clk,
		q   => qq
	);
   
	clk_process :PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clk_period/2;
		clk <= '1';
		WAIT FOR clk_period/2;
	END PROCESS;


	-- stimulating process
	stim_proc: PROCESS

	variable int : integer := 0;
	variable l : line;
	variable s : std_logic;
	BEGIN
		wait for clk_period;

		while true loop
			write(l, to_integer(unsigned(qq)));
			writeline(output, l);

			wait for clk_period;
		end loop;

		wait;
	END PROCESS;	
END;
