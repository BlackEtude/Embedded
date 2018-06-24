library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio;
use work.txt_util.all;
    
entity ram is
    generic (
        ADDRESS_WIDTH : integer := 5;
        WORD_WIDTH    : integer := 9
    );
    port (
        clk     :   in std_logic;
        cmd     :   in std_logic;
        address :   in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
        data    :   inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z')
    );
end ram;

architecture arch of ram is
    constant CMD_READ  : std_logic := '0';
    constant CMD_WRITE : std_logic := '1';
    constant BUS_FREE   : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');
    constant EMPTY_WORD : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');

    type memory_t is array(0 to 2 ** ADDRESS_WIDTH-1)
        of std_logic_vector(WORD_WIDTH-1 downto 0);

    signal memory : memory_t := (others => EMPTY_WORD);

begin
    process(clk)
        variable load_program   :   boolean := true;
        file txt_file           :   text;
        variable v_line         :   line;
        variable v_bvector      :   bit_vector(WORD_WIDTH-1 downto 0);
        variable i              :   integer;
        variable file_name      :   line;
        variable name           :   string(1 to 30);

    begin
        if load_program then
            write (file_name, String'("Program to load: "));
            writeline (output, file_name);
            readline (input, file_name);
            read(file_name, name(1 to file_name'length));
            file_open(txt_file, name, read_mode);
            i := 0;
            while not endfile(txt_file) loop
                readline(txt_file, v_line);
                read(v_line, v_bvector);
                memory(i) <= to_stdlogicvector(v_bvector);
                i := i + 1;
            end loop;
            load_program := false;
        end if;

        if rising_edge(clk) then
            if cmd = CMD_READ then
                data <= memory(to_integer(unsigned(address)));
            elsif cmd = CMD_WRITE then
                memory(to_integer(unsigned(address))) <= data;
                data <= BUS_FREE;
            else
                data <= BUS_FREE;
            end if;
        end if;
    end process;
end arch;
