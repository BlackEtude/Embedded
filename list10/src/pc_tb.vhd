library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;

entity pc_tb is
end pc_tb;

architecture test of pc_tb is
    component pc
        generic (
            WORD_WIDTH : integer
        );
        port (
            clk      :	in std_logic;
            data_out : 	in std_logic;
            set 	 : 	in std_logic;
            inc 	 : 	in std_logic;
            data 	 :	inout std_logic_vector(WORD_WIDTH-1 downto 0)
        );
    end component;

    constant clk_period : time := 20 ns;

    signal clk      : std_logic := '0';
    signal data_out : std_logic := '0';
    signal set      : std_logic := '0';
    signal inc      : std_logic := '0';
    signal data_bus : std_logic_vector(8 downto 0) := (others => 'Z');

begin
    uut : pc
    generic map (
        WORD_WIDTH => 9
    )
    port map (
        clk => clk,
        data_out => data_out,
        set => set,
        inc => inc,
        data => data_bus
    );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period / 2;
        clk <= '1';
        wait for clk_period / 2;
    end process;

    test_process : process
    begin
        wait for clk_period * 2;

        inc <= '1';
        wait for clk_period * 5;

        inc <= '0';
        data_out <= '1';
        wait for clk_period;

        assert data_bus = "000000101"
            report "Expected '000000101', but got '" & str(data_bus) & "'";
        data_out <= '0';
        wait for clk_period;

        set <= '1';
        data_bus <= "101010101";
        wait for clk_period;

        assert data_bus = "101010101"
            report "Expected '101010101', but got '" & str(data_bus) & "'";
        wait for clk_period;

        wait;
    end process;
end test;
