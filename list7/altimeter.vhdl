library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

ENTITY altimeter IS
port(
	altitude	: in integer;
	code		: out std_logic_vector(11 downto 0)
);
END altimeter;

ARCHITECTURE behavioral of altimeter IS
	type table is array (natural range <>) of std_logic_vector(2 downto 0);

	constant code_table_C: table := (
		"001", "011", "010", "110", "100", "100", "110", "010", "011", "001"
  	);

  	constant code_table_DAB: table := (
  		"000", "001", "011", "010", "110", "111", "101", "100",
  		"100", "101", "111", "110", "010", "011", "001", "000"
  	);

  	shared variable hundreds : integer;
BEGIN
	process(altitude)
	begin
		hundreds := 12 + (altitude / 100);
		code <= code_table_DAB((hundreds / 400) mod 16) & 
				code_table_DAB((hundreds / 80) mod 16) & 
				code_table_DAB((hundreds / 5) mod 16) & 
				code_table_C(hundreds mod 10);
	end process;
END behavioral;