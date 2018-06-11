library ieee;
USE ieee.std_logic_1164.ALL;

package types is
	type control_t is record
		PC     : std_logic_vector(2 downto 0);
		MEM    : std_logic;
		ALU    : std_logic;    
		ALU2AC : std_logic;
		AC     : std_logic;
		MAR    : std_logic;
		MBR    : std_logic;
		IR     : std_logic;
		INreg  : std_logic;
		OUTreg : std_logic;
	end record;
end types;