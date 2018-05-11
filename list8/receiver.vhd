LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity receiver is
	port(
		clk: in std_logic;
		data_in: in std_logic_vector(12 downto 0);
		correct: out std_logic_vector(4 downto 0) := (others => '0');
		data_out: out std_logic_vector(7 downto 0) := (others => '0')
	);
end receiver;

architecture flow of receiver is
begin
	main:process(clk)
		variable error_in: std_logic_vector(4 downto 0);
	begin
		if rising_edge(clk) then
			error_in(0) := data_in(4) xor data_in(5) xor data_in(6) xor data_in(7) xor data_in(8);
			error_in(1) := data_in(1) xor data_in(2) xor data_in(3) xor data_in(7) xor data_in(9); 
			error_in(2) := data_in(0) xor data_in(2) xor data_in(3) xor data_in(5) xor data_in(6) xor data_in(10);
			error_in(3) := data_in(0) xor data_in(1) xor data_in(3) xor data_in(4) xor data_in(6) xor data_in(11);		
			error_in(4) := data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor data_in(4) xor data_in(5) xor
							data_in(6) xor data_in(7) xor data_in(8) xor data_in(9) xor data_in(10) xor data_in(11) xor data_in(12);
			
			correct <= "11111";
			if(error_in = "00000" or error_in = "10000") then
				data_out <= data_in(7 downto 0);
			else 
				if error_in(4) = '1' then
					data_out <= data_in(7 downto 0);

					if error_in = "11100" then 
						data_out(0) <= not data_in(0); 
					end if;
					if error_in = "11010" then
						data_out(1) <= not data_in(1);
					end if;
					if error_in = "10110" then 
						data_out(2) <= not data_in(2); 
					end if;
					if error_in = "11110" then 
						data_out(3) <= not data_in(3); 
					end if;
					if error_in = "11001" then 
						data_out(4) <= not data_in(4); 
					end if;
					if error_in = "10101" then 
						data_out(5) <= not data_in(5);
					end if;
					if error_in = "11101" then 
						data_out(6) <= not data_in(6); 
					end if;
					if error_in = "10011" then 
						data_out(7) <= not data_in(7);
					end if;
				else
					correct <= "00000";
				end if;
			end if;
		end if;
	end process;
end flow;
