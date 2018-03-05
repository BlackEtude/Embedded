LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
 
entity xand_tb IS
end xand_tb;
 
architecture behavior OF xand_tb IS 
	constant x_width : integer := 8;
	constant period : time := 10 ns;
	constant max : integer := 2**x_width;

	component Xand
		generic(width : integer);
	port(clk: in std_logic;
		A, B: in std_logic_vector(width-1 downto 0);
		C	: out std_logic_vector(width-1 downto 0)
	);
	end component;

	signal clk: std_logic := '1';
	signal A, B: std_logic_vector(x_width-1 downto 0) := (others => '0');

	signal C: std_logic_vector(x_width-1 downto 0);
 
begin
	uut: Xand 
		generic map (width => x_width)
		port map (
			clk => clk,
			A => A,
			B => B,
			C => C
		);

	stim_proc: process
	begin		
		wait for 100 ns;	
		wait for period*10;

		for i in 0 to max loop
			A <= std_logic_vector(unsigned(A) + 1);
			for j in 0 to max loop
				B <= std_logic_vector(unsigned(B) + 1);
				wait for period;
			end loop;
		end loop;
		wait;
	end process;
end;
