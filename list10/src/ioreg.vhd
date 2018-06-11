library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;

entity ioreg is
    generic (
        WORD_WIDTH : integer := 9
    );
    port (
        clk  :  in std_logic;
        cmd  :  in std_logic;
        data :  inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z')
    );
end ioreg;

architecture arch of ioreg is
    constant CMD_READ   : std_logic := '0';
    constant CMD_WRITE  : std_logic := '1';
    constant BUS_FREE   : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');

begin
    process(clk)
        variable io_line   : line;
        variable io_vector : bit_vector(WORD_WIDTH-1 downto 0);
    begin
        if rising_edge(clk) then
            if cmd = CMD_READ then
                report "READING";
                readline(input, io_line);
                read(io_line, io_vector);
                data <= to_stdlogicvector(io_vector);
            elsif cmd = CMD_WRITE then
                report "WRITING";
                write(io_line, to_bitvector(data));
                writeline(output, io_line);
                data <= BUS_FREE;
            else
                data <= BUS_FREE;
            end if;
        end if;
    end process;
end arch;