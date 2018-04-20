library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.numeric_std;

ENTITY altimeter IS
port(
	altitude	: in integer;
	code		: out std_logic_vector(11 downto 0)
);
END altimeter;

ARCHITECTURE behavioral of altimeter IS
	type code_table_C is array (0 to 9) of std_logic_vector(2 downto 0);
	type code_table_B is array (0 to 15) of std_logic_vector(2 downto 0);

	constant table_C: code_table_C := (
		"001", "011", "010", "110", "100", "100", "110", "010", "011", "001"
  	);

  	constant table_B: code_table_B := (
  		"000", "001", "011", "010", "110", "111", "101", "100",
  		"100", "101", "111", "110", "010", "011", "001", "000"
  	);

  	shared variable s : integer;
BEGIN
	process(altitude)
	begin
		-- error for altitude < -1200

		s := (-1200 - altitude) / (-100);
		code <= table_B((s / 400) mod 16) & table_B((s / 80) mod 16) & table_B((s / 5) mod 16) & table_C(s mod 10);
	end process;
END behavioral;