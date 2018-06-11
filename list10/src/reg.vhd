library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

    --------------------------------------------------------------
    --                 Generic register module                  --
    --------------------------------------------------------------
    -- Generic parameters:                                      --
    -- * WORD_WIDTH - length of the addressable unit (in bits)  --
    --                                                          --
    -- Usage:                                                   --
    -- 1. Reading                                               --
    --    * set `cmd` to '0'                                    --
    --    * clear `data` (set to "ZZ...Z")                      --
    --    * state is output to `data` on next tick              --
    --    * reset `cmd` to 'Z'                                  --
    -- 2. Writing                                               --
    --    * set `cmd` to '1'                                    --
    --    * set `data` to what you want to store                --
    --    * data is saved in the next tick                      --
    --    * reset `cmd` to 'Z'                                  --
    --                                                          --
    -- Signal `cmd` should be kept in high impendance state     --
    -- when register is not being actively used.                --
    --------------------------------------------------------------

entity reg is
    generic (
        WORD_WIDTH : integer := 9
    );
    port (
        clk  :  in std_logic;
        cmd  :  in std_logic;
        data :  inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z')
    );
end reg;

architecture arch of reg is
    constant CMD_READ  : std_logic := '0';
    constant CMD_WRITE : std_logic := '1';
    constant BUS_FREE  : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');

    signal state : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if cmd = CMD_READ then
                data <= state;
            elsif cmd = CMD_WRITE then
                state <= data;
                data <= BUS_FREE;
            else
                data <= BUS_FREE;
            end if;
        end if;
    end process;
end arch;