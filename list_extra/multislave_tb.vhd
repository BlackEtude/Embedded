LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY multislave_tb IS
END multislave_tb;

ARCHITECTURE behavior OF multislave_tb IS
	COMPONENT slave
		generic ( identifier : std_logic_vector (7 downto 0) );
    PORT(
        	conn_bus : INOUT  std_logic_vector(7 downto 0);
        	clk : IN  std_logic;
			state : out STD_LOGIC_VECTOR (5 downto 0);
			vq : out std_logic_vector (7 downto 0);
			vcurrent_cmd : out std_logic_vector(3 downto 0)
        );
    END COMPONENT;

   	--Inputs
   	signal clk : std_logic := '0';

	--BiDirs
   	signal conn_bus : std_logic_vector(7 downto 0) := (others => 'Z');

	-- outputs from UUT for debugging: A
	signal stateA : std_logic_vector(5 downto 0);
	signal vqA : std_logic_vector (7 downto 0);
	signal current_cmdA : std_logic_vector (3 downto 0);

	-- outputs from UUT for debugging: B
	signal stateB : std_logic_vector(5 downto 0);
	signal vqB : std_logic_vector (7 downto 0);
	signal current_cmdB : std_logic_vector (3 downto 0);

   	-- Clock period definitions
   	constant clk_period : time := 10 ns;

BEGIN
   slave_A: slave
	GENERIC MAP (identifier => "00001010")
	PORT MAP (
          conn_bus => conn_bus,
          clk => clk,
			 state => stateA,
			 vq => vqA,
			 vcurrent_cmd => current_cmdA
        );

	slave_B: slave
	GENERIC MAP (identifier => "00001011")
	PORT MAP (
          conn_bus => conn_bus,
          clk => clk,
			 state => stateB,
			 vq => vqB,
			 vcurrent_cmd => current_cmdB
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

   	-- Stimulus process
	stim_proc: process
   	begin
    	-- hold reset state for 100 ns.
      	wait for 100 ns;

		-- A, ADD, 0x10
		conn_bus <= "00001010";
		wait for clk_period;
		conn_bus <= "00010000";
		wait for clk_period;
		conn_bus <= "00100000";
		wait for clk_period;

		-- B, ADD, 0x01
		conn_bus <= "00001011";
		wait for clk_period;
		conn_bus <= "00010000";
		wait for clk_period;
		conn_bus <= "00000010";
		wait for clk_period;

		-- B, ADD, <after 3>
		conn_bus <= "00001011";
		wait for clk_period;
		conn_bus <= "00010100";
		wait for clk_period;
		conn_bus <= "00010000";
		wait for clk_period;

		-- A, DATA_REQ
		conn_bus <= "00001010";
		wait for clk_period;
		conn_bus <= "01000000";
		wait for clk_period;
		conn_bus <= "ZZZZZZZZ";
		wait for clk_period;
		conn_bus <= "ZZZZZZZZ";
		wait for clk_period;

		-- B, DATA_REQ
		conn_bus <= "00001011";
		wait for clk_period;
		conn_bus <= "01000000";
		wait for clk_period;
		conn_bus <= "ZZZZZZZZ";
		wait for clk_period;
		conn_bus <= "ZZZZZZZZ";
		wait for clk_period;

      	wait;
   	end process;
END;