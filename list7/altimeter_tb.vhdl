LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
USE work.txt_util.ALL;
 
ENTITY altimeter_tb IS
END altimeter_tb;
 
ARCHITECTURE behavior OF altimeter_tb IS 
	signal altitude 	: integer;
	signal code		: std_logic_vector(11 downto 0);

BEGIN
	uut: entity work.altimeter 
		port map (
			 altitude => altitude,
			 code => code
		  );


	tb_proc: process
		variable l : line;
		variable int : integer;

		type pattern_type is record
			altitude : integer; 
			code : std_logic_vector(11 downto 0);
		end record;

		type pattern_array is array (natural range <>) of pattern_type;
		constant patterns : pattern_array := (
			(1200, "000000110100"),
         	(300, "000000010100")
         );

	begin
		assert false report "Start of test" severity note;

		for i in patterns'range loop
			altitude <= patterns(i).altitude;

			wait for 1 ns;

			assert code = patterns(i).code
				report "Bad code" severity error;
      	end loop;

		assert false report "End of test" severity note;

		wait for 2 ns;

		while not endfile(input) loop
			readline (input, l);
			read(l, int);
			altitude <= int;

			wait for 2 ns;
			
			assert false 
				report "Code is equal: '" & str(code) & "'" severity note;
		end loop;

		wait;
	end process tb_proc;
END;