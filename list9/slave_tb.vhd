LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY slave_tb IS
END slave_tb;

ARCHITECTURE behavior OF slave_tb IS 
	COMPONENT slave
		generic ( identifier : std_logic_vector (7 downto 0) );
	PORT(
		data_bus : INOUT std_logic_vector(7 downto 0);
		control_bus : INOUT std_logic_vector(7 downto 0);
		clk : IN std_logic;
		state : out STD_LOGIC_VECTOR (5 downto 0);
		send_id : in std_logic_vector (7 downto 0);
		send_data : in std_logic_vector (7 downto 0)
	);
	END COMPONENT;

	signal clk : std_logic := '0';
	signal data_bus : std_logic_vector(7 downto 0) := (others => 'Z');
	signal control_bus : std_logic_vector(7 downto 0) := (others => 'Z');

	signal stateA : std_logic_vector(5 downto 0);
	signal stateB : std_logic_vector(5 downto 0);
	signal stateC : std_logic_vector(5 downto 0);
	signal send_idA : std_logic_vector(7 downto 0) := (others => '0');
	signal send_idB : std_logic_vector(7 downto 0) := (others => '0');
	signal send_idC : std_logic_vector(7 downto 0) := (others => '0');
	signal send_dataA : std_logic_vector(7 downto 0) := (others => '0');
	signal send_dataB : std_logic_vector(7 downto 0) := (others => '0');
	signal send_dataC : std_logic_vector(7 downto 0) := (others => '0');

	constant clk_period : time := 10 ns;
 
BEGIN
	slave_A: slave
	GENERIC MAP (identifier => "10101010")
	PORT MAP (
		data_bus => data_bus,
		control_bus => control_bus,
		clk => clk,
		state => stateA,
		send_id => send_idA,
		send_data => send_dataA
	);

	slave_B: slave
	GENERIC MAP (identifier => "10111011")
	PORT MAP (
		data_bus => data_bus,
		control_bus => control_bus,
		clk => clk,
		state => stateB,
		send_id => send_idB,
		send_data => send_dataB
	);

	slave_C: slave
	GENERIC MAP (identifier => "11001100")
	PORT MAP (
		data_bus => data_bus,
		control_bus => control_bus,
		clk => clk,
		state => stateC,
		send_id => send_idC,
		send_data => send_dataC
	);

	clk_process: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	stim_proc: process
	begin		
		wait for clk_period;

		-- slaveA => slaveB
		send_dataA <= "11101110";
		send_idA <= "10111011";

		wait for clk_period * 3;

		-- slaveB => slaveC
		send_dataB <= "11111111";
		send_idB <= "11001100";
		
		wait for clk_period * 6;

		-- slaveC => slaveA
		send_dataC <= "10111011";
		send_idC <= "10101010";

		--wait;
	end process;
END;