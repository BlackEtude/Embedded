library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;


ENTITY lfsr IS
	PORT (
	 	clk : in  STD_LOGIC;
		--q : inout  STD_LOGIC_VECTOR(15 downto 0) := (OTHERS => '1')
		q : inout  STD_LOGIC_VECTOR(15 downto 0) := (0 => '1', OTHERS => '0')

	);
END lfsr;

ARCHITECTURE Behavioral OF lfsr IS
BEGIN
  PROCESS
  BEGIN

  	WAIT UNTIL clk'event AND clk='1';
	q(15 downto 1) <= q(14 downto 0);
	q(0) <= q(15) XOR q(14) XOR q(13) XOR q(4);
	
  END PROCESS;
END Behavioral;

