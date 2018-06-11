library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.types.all;

entity alu is
    generic (
        WORD_WIDTH : integer := 9
    );
    port (
        clk     : in std_logic;
        cmd     : in std_logic;
        data    : inout std_logic_vector(WORD_WIDTH-1 downto 0);
        alu_in  : in std_logic_vector(WORD_WIDTH-1 downto 0);
        alu_out : out std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end alu;

architecture arch of alu is
    signal result : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if cmd = '1' then
                result <= std_logic_vector(signed(data) + signed(alu_in));
            elsif cmd = '0' then
                result <= std_logic_vector(signed(data) - signed(alu_in));
            end if;
        end if;

        alu_out <= result;
    end process;
end arch;