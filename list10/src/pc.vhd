library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity pc is
    generic (
        WORD_WIDTH : integer := 9
    );
    port (
        clk  	 :  in std_logic;
        data_out :  in std_logic; 
        set  	 :  in std_logic;
        inc  	 :  in std_logic;
        data 	 :  inout std_logic_vector(WORD_WIDTH-1 downto 0)
    );
end pc;

architecture arch of pc is
    constant BUS_CLR : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');
    constant MAX_PC  : integer := 2 ** WORD_WIDTH - 1;

    signal state : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if set = '1' then
                state <= data;
                data <= BUS_CLR;
            elsif inc = '1' then
                if unsigned(state) >= MAX_PC then
                    state <= (others => '0');
                else
                    state <= std_logic_vector(unsigned(state) + 1);
                end if;
                data <= BUS_CLR;
            elsif data_out = '1' then
                data <= state;
            else
                data <= BUS_CLR;
            end if;
        end if;
    end process;
end arch;