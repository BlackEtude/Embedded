LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

entity clk_div_tb is
end clk_div_tb;

architecture behavior of clk_div_tb is

    component clk_div is generic (R :natural; F :natural);
    port (
        clk_in  :in std_logic;
        clk_out :out std_logic
    );
    end component;

    signal clk_in   :std_logic := '0';
    signal clk_50M  :std_logic := '0';
    signal clk_1_1K :std_logic := '0';
    signal clk_100  :std_logic := '0';
    constant clk_period : Time := 8 ns;
begin

    clk50M : entity work.clk_div(clk_div_arch)
    generic map(R => 3, F => 2)
    port map (
        clk_in => clk_in,
        clk_out => clk_50M
    );

    clk1_1K : entity work.clk_div(clk_div_arch)
    generic map(R => 114, F => 113)
    port map (
        clk_in => clk_in,
        clk_out => clk_1_1K
    );

    clk100H : entity work.clk_div(clk_div_arch)
    generic map(R => 1250000, F => 1250000)
    port map (
        clk_in => clk_in,
        clk_out => clk_100
    );

    clk_process: process
    begin
        clk_in <= '1';
        wait for clk_period / 2;
        clk_in <= '0';
        wait for clk_period / 2;
    end process;
end;
