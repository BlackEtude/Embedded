library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

    -------------------------------------------------------------------------------
    -- Program Counter module                                                    --
    -------------------------------------------------------------------------------
    -- Basic program counter - Can be autoincremented or set to a value.         --
    --                                                                           --
    -- Generic parameters:                                                       --
    -- * WORD_WIDTH - length of counter's state (in bits)                     	 --
    --                                                                           --
    -- Usage:                                                                    --
    -- 1. Increment                                                              --
    --    * set `inc` to '1'                                                     --
    --    * counter is incremented on next tick                                  --
    --    * reset `inc` to '0'                                                   --
    -- 2. Set value                                                              --
    --    * set `set` to '1' (override the state with value from data)           --
    --    * set `data` to target value                                           --
    --    * counter's state is updated on next tick                              --
    -- 3. Output                                                                 --
    --    * set `data_out` to '1' (output the state to data)                     --
    --    * clear `data` (set to "ZZ...Z")                                       --
    --    * counter's state will be written to `data` on next tick               --
    -------------------------------------------------------------------------------

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