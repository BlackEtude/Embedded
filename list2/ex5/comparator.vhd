library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY comparator IS
generic(width : integer:=3);	--default value = 3
port(
	a 		: 	in std_logic_vector(width-1 downto 0);
	b 		: 	in std_logic_vector(width-1 downto 0);
	less	: 	out std_logic;
	equal	: 	out std_logic;
	greater	:	out std_logic
);
END comparator;

ARCHITECTURE Behavioral of comparator IS
BEGIN
	process(a, b)
	begin
		less <= '0';
		equal <= '0';
		greater <= '0';

		if (a < b) then
			less <= '1';
		elsif (a > b) then
			greater <= '1';
		else
			equal <= '1';
		end if;
	end process;
END Behavioral;


