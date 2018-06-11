library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity mempc_tb is
end mempc_tb;

architecture test of mempc_tb is
    component ram
        generic (
            ADDRESS_WIDTH 	: integer := 5;
            WORD_WIDTH 		: integer := 9
        );
        port (
            clk     :	in std_logic;
            cmd     :   in std_logic;
            address :   in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
            data    :	inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others=>'Z')
        );
    end component;

    component pc
        generic (
            WORD_WIDTH : integer
        );
        port (
            clk 	 :	in std_logic;
            data_out :	in std_logic;
            set      :	in std_logic;
            inc      :	in std_logic;
            data     :	inout std_logic_vector(WORD_WIDTH-1 downto 0)
        );
    end component;

    constant ADDRESS_WIDTH  : integer := 5;
    constant WORD_WIDTH     : integer := 9;
    constant clk_period : time := 20 ns;

    constant ADDRESS_CLR : std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => 'Z');
    constant DATA_CLR : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');

    signal clk  	:	std_logic := '0';
    signal data_bus	:	std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');

    signal mem_cmd  : std_logic := 'Z';
    signal mem_addr : std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => 'Z');

    signal pc_out : std_logic := '0';
    signal pc_set : std_logic := '0';
    signal pc_inc : std_logic := '0';

begin
    memory: ram
    generic map (
        ADDRESS_WIDTH => ADDRESS_WIDTH,
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => mem_cmd,
        address => mem_addr,
        data => data_bus
    );

    counter: pc
    generic map (
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        data_out => pc_out,
        set => pc_set,
        inc => pc_inc,
        data => data_bus
    );


    clk_process: process
    begin
        clk <= '1';
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process;

	---------------------------------------------------
    -- Test 1.
    --
    -- Read a value from memory address provided by PC
    ---------------------------------------------------

    test_process: process
    begin
        wait for 100 ns;

        -- save data in memory
        mem_cmd <= '1';
        mem_addr <= "01010";
        data_bus <= "100110011";
        wait for clk_period;

        -- clear memory controls
        mem_cmd <= 'Z';
        mem_addr <= ADDRESS_CLR;
        -- set pc to the same address
        data_bus <= "000001010";
        pc_set <= '1';
        wait for clk_period;

        -- output pc value
        pc_set <= '0';
        pc_out <= '1';
        data_bus <= "0000ZZZZZ";
        wait for clk_period;

        -- read from memory
        pc_out <= '0';
        mem_addr <= data_bus(ADDRESS_WIDTH-1 downto 0);
        mem_cmd <= '0';
        data_bus <= DATA_CLR;
        wait for clk_period;

        mem_cmd <= 'Z';
        assert data_bus = "100110011"
            report "expected '100110011' but got '" & str(data_bus) & "'";
        wait for clk_period;

        -- reset all
        mem_addr <= ADDRESS_CLR;
        data_bus <= DATA_CLR;

        wait for 100 ns;
        wait;
    end process;
end test;