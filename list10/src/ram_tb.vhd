library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity ram_tb is
end ram_tb;

architecture test of ram_tb is
	component ram
		generic (
			ADDRESS_WIDTH : integer := 5;
			WORD_WIDTH    : integer := 9
		);
		port (
			clk:     in std_logic;
			cmd:     in std_logic;
			address: in std_logic_vector(ADDRESS_WIDTH - 1 downto 0);
			data:    inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others=>'Z')
		);
	end component;

	constant clk_period : time := 20 ns;

	signal clk      : std_logic := '0';
	signal cmd      : std_logic := 'Z';
	signal address  : std_logic_vector(4 downto 0) := (others => 'Z');
	signal data_bus : std_logic_vector(8 downto 0) := (others => 'Z');

begin
	uut: ram
		generic map (
			ADDRESS_WIDTH => 5,
			WORD_WIDTH => 9
		)
		port map (
			clk => clk,
			cmd => cmd,
			data => data_bus,
			address => address
		);

	clk_process: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	test_process: process
	begin
		wait for clk_period * 2;

		-- write "101010101" to address 00001
		cmd <= '1';
		address <= "00001";
		data_bus <= "101010101";
		wait for clk_period;
		cmd <= 'Z';

		-- write "111100001" to address 00010
		cmd <= '1';
		address <= "00010";
		data_bus <= "111100001";
		wait for clk_period;
		cmd <= 'Z';

		cmd <= '0';
		address <= "00001";
		data_bus <= "ZZZZZZZZZ";
		wait for clk_period;

		assert data_bus = "101010101"
			report "Expected '101010101', but got '" & str(data_bus) & "'";

		wait for clk_period;

		cmd <= '0';
		address <= "00010";
		data_bus <= "ZZZZZZZZZ";

		wait for clk_period;

		cmd <= 'Z';
		assert data_bus = "111100001"
			report "Expected '111100001', but got '" & str(data_bus) & "'";

		wait for clk_period;
		wait;

	end process;
end test;