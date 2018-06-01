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
		state : out STD_LOGIC_VECTOR (5 downto 0)
	);
	END COMPONENT;

	--Inputs
	signal clk : std_logic := '0';

	signal data_bus : std_logic_vector(7 downto 0) := (others => 'Z');
	signal control_bus : std_logic_vector(7 downto 0) := (others => 'Z');

	-- outputs from UUT for debugging
	signal stateA : std_logic_vector(5 downto 0);
	signal stateB : std_logic_vector(5 downto 0);
	signal stateC : std_logic_vector(5 downto 0);

	constant clk_period : time := 10 ns;
 
BEGIN
	slave_A: slave
	GENERIC MAP (identifier => "00000001")
	PORT MAP (
		data_bus => data_bus,
		control_bus => control_bus,
		clk => clk,
		state => stateA
	);

	slave_B: slave
	GENERIC MAP (identifier => "00000010")
	PORT MAP (
		data_bus => data_bus,
		control_bus => control_bus,
		clk => clk,
		state => stateB
	);

	slave_C: slave
	GENERIC MAP (identifier => "00000011")
	PORT MAP (
		data_bus => data_bus,
		control_bus => control_bus,
		clk => clk,
		state => stateC
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
		wait;
	end process;
END;