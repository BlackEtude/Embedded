LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity receiver is
	port(
		clk: in std_logic;
		data_in: in std_logic_vector(15 downto 0);
		correct: out std_logic_vector(4 downto 0) := (others => '0');
		data_out: out std_logic_vector(7 downto 0) := (others => '0')
	);
end receiver;

architecture flow of receiver is
begin
	main:process(clk)
		variable error_in: std_logic_vector(4 downto 0);
		variable number: integer;
	begin
		if rising_edge(clk) then
		error_in(3) := data_in(0) xor data_in(1) xor data_in(3) xor data_in(4) xor data_in(6) xor data_in(14);
		error_in(2) := data_in(0) xor data_in(2) xor data_in(3) xor data_in(5) xor data_in(6) xor data_in(13);
		error_in(1) := data_in(1) xor data_in(2) xor data_in(3) xor data_in(7) xor data_in(12); 
		error_in(0) := data_in(4) xor data_in(5) xor data_in(6) xor data_in(7) xor data_in(11);
		error_in(4) := data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(5) xor
						data_in(6) xor data_in(7) xor data_in(11) xor data_in(12) xor data_in(13) xor data_in(14) xor data_in(15);
		
		if(error_in = "00000" or error_in = "10000") then
			correct <= "11111";
			data_out <= data_in(7 downto 0);
		else 
			if error_in(4) = '1' then
				correct <= "11111";
				number := to_integer(unsigned(error_in(3 downto 0)));
				data_out <= data_in(7 downto 0);

				if number = 12 then 
					data_out(0) <= not data_in(0); 
				end if;
				if number = 10 then
					data_out(1) <= not data_in(1);
				end if;
				if number = 6 then 
					data_out(2) <= not data_in(2); 
				end if;
				if number = 14 then 
					data_out(3) <= not data_in(3); 
				end if;
				if number = 9 then 
					data_out(4) <= not data_in(4); 
				end if;
				if number = 5 then 
					data_out(5) <= not data_in(5);
				end if;
				if number = 13 then 
					data_out(6) <= not data_in(6); 
				end if;
				if number = 3 then 
					data_out(7) <= not data_in(7);
				end if;
				else
					correct <= "00000";
				end if;
			end if;
		end if;
	end process;
end flow;
