library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity acreg is
    generic (
        WORD_WIDTH : integer := 9
    );
    port (
        clk     :   in std_logic;
        cmd     :   in std_logic;
        alu_get :   in std_logic;
        data    :   inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');
        ac_out  :   out std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');
        ac_in   :   in std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z')
    );
end acreg;

architecture arch of acreg is
    constant CMD_READ   :   std_logic := '0';
    constant CMD_WRITE  :   std_logic := '1';
    constant BUS_FREE   :   std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');

    signal state : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

begin
    ac_out <= state;
    process(clk)
    begin
        if rising_edge(clk) then
            if cmd = CMD_READ then
                report "AC: READ: " & str(state);
                data <= state;
            elsif cmd = CMD_WRITE then
                --report "AC: WRITE";
                state <= data;
                data <= BUS_FREE;
            elsif alu_get = '1' then
                state <= ac_in;
                data <= state;
            else
                data <= BUS_FREE;
            end if;
        end if;
    end process;
end arch;