library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE work.txt_util.ALL;

entity transmitter is
	port(
		clk: in std_logic;
		data_in: in std_logic_vector(7 downto 0);
		correct: in std_logic_vector(4 downto 0);
		data_out: out std_logic_vector(15 downto 0) := (others => '0');
		ready: out std_logic := '0'
	);
end transmitter;

architecture behaviour of transmitter is
begin

	code:process(clk)
	begin
		if falling_edge(clk) then
			data_out(7 downto 0) <= data_in;

			data_out(11) <= data_in(4) xor data_in(5) xor data_in(6) xor data_in(7);
			data_out(12) <= data_in(1) xor data_in(2) xor data_in(3) xor data_in(7); 
			data_out(13) <= data_in(0) xor data_in(2) xor data_in(3) xor data_in(5) xor data_in(6);
			data_out(14) <= data_in(0) xor data_in(1) xor data_in(3) xor data_in(4) xor data_in(6);
			data_out(15) <= data_in(0) xor data_in(1) xor data_in(2) xor data_in(4) xor data_in(5) xor data_in(7);
		end if;

		if rising_edge(clk) then
			if correct = "11111"
				or correct = "11110" or correct = "11101" or correct = "11011" or correct = "10111" or correct = "01111" 
				or correct = "11100" or correct = "11010" or correct = "10110" or correct = "01110"	or correct = "11001" or correct = "10101" or correct = "01101" or correct = "10011" or correct = "01011" or correct = "00111" then
				ready <= '1';
			else
				ready <= '0';
			end if;
		end if;
	end process;
end behaviour;
