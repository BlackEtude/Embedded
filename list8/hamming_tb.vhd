LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
USE work.txt_util.ALL;

ENTITY hamming_tb IS
END hamming_tb;

ARCHITECTURE behavior OF hamming_tb IS 
	signal encoder_in: std_logic_vector(7 downto 0):= (others=>'0');
	signal encoder_out:std_logic_vector(15 downto 0);
	signal receiver_in:std_logic_vector(15 downto 0);
	signal receiver_out: std_logic_vector(4 downto 0);
	signal data_out: std_logic_vector(7 downto 0);
	signal correct: std_logic_vector(4 downto 0);
	signal ready: std_logic;
	signal clk : std_logic := '0';

	constant clk_period : time := 10 ns;
	constant WIDTH : positive := 16;
	constant WIDTH2: positive := 5;

begin
	coder: entity work.transmitter 
		port map(clk => clk, data_in => encoder_in, correct => receiver_out, ready => ready, data_out => encoder_out);

	decoder: entity work.receiver
		port map(clk => clk, data_in => receiver_in, correct => correct, data_out => data_out);
	
	canal: entity work.lossy_channel
		generic map(N => WIDTH)
		port map(data_in => encoder_out, clk => clk, data_out => receiver_in);

	canal2: entity work.lossy_channel
		generic map(N => WIDTH2)
		port map(data_in => correct, clk => clk, data_out => receiver_out);

	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;	
	
	flow: process
		variable b:std_logic;
	begin
		wait for clk_period * 3;
		assert false report "Start of test" severity note;
		
		for i in 0 to 255 loop
			encoder_in <= std_logic_vector(to_unsigned(i, encoder_in'length));
			wait for clk_period * 3;
			
			while ready = '0' loop 
				wait for clk_period * 3; 
			end loop;

			assert encoder_in = data_out report "flip! "& str(encoder_in) & " and " & str(data_out) severity note;
		end loop;

		assert false report "End of test" severity note;
		wait;
	end process;
end;
