library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity clk_div is
    generic (R : natural := 1; F :natural := 1);
    port (
        clk_in  :in std_logic;
        clk_out :out std_logic
    );
end clk_div;

architecture clk_div_arch of clk_div is
    signal clk_temp :std_logic := '0';
begin
    count: process(clk_in)
        variable clk_count : natural range 0 to (R + F) := 0;
    begin
        if clk_in'event then
            clk_count := clk_count + 1;
            if clk_count = F then
                clk_temp <= not clk_temp;
            elsif clk_count = F + R then
                clk_temp <= not clk_temp;
                clk_count := 0;
            end if;
        end if;
    end process;
    clk_out <= clk_temp;
end clk_div_arch;
