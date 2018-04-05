LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity bin_div_tb is
end bin_div_tb;

architecture behavior of bin_div_tb is

    component bin_div is generic(N : integer);
    port(
        clk_in: in std_logic;
        clk_out: out std_logic_vector(N downto 0));
    end component;

    constant N : integer := 4;
    signal clk_in : std_logic := '0';
    signal clk_out : std_logic_vector(N downto 0) := (others => '0');
    constant clk_period : Time := 8 ns;

begin
    uut: bin_div generic map (N => N)
    port map (
        clk_in => clk_in,
        clk_out => clk_out
    );

    clk_process: process
    begin
        clk_in <= '1';
        wait for clk_period / 2;
        clk_in <= '0';
        wait for clk_period / 2;
    end process;
end;