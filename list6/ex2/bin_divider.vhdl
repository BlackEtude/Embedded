library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

entity bin_divider is
    generic(N : integer);
    port(
        clk_in: in std_logic;
        clk_out: out std_logic_vector(N downto 0));
end entity bin_divider;

architecture behavior of bin_divider is
    signal clk_temp : std_logic_vector(N downto 0) := (others => '0');

begin

    count: process(clk_in)
    begin
        if clk_in'event and clk_in = '1' then
            clk_temp <= std_logic_vector(unsigned(clk_temp) + 1);
        end if;
    end process;

    clk_out <= clk_temp;
    
end architecture behavior;