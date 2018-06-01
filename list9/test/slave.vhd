library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

------------------------------
--		STATES
------------------------------
-- idle  = "000001"
-- start = "000000"
-- data  = "000010"
-- stop  = "000100"
-- write = "100000"
-- error = "111111"
------------------------------

entity slave is
	generic ( identifier : std_logic_vector (7 downto 0) := "10101010" );
	Port ( 
		data_bus : inout STD_LOGIC_VECTOR (7 downto 0);
		control_bus : inout STD_LOGIC_VECTOR (7 downto 0);
		clk : in STD_LOGIC;
		state : out STD_LOGIC_VECTOR (5 downto 0)
	);
end slave;
architecture Behavioral of slave is

type state_type is (IDLE, START, DATA, STOP, ERROR, WRITE);
signal current_s : state_type := IDLE;
signal next_s : state_type := IDLE;

-- input buffer
signal data_in : std_logic_vector (7 downto 0) := (others => '0');
signal control_in : std_logic_vector (7 downto 0) := (others => '0');
signal command : std_logic_vector (7 downto 0) := (others => '0');

signal result_reg : std_logic_vector (7 downto 0) := (others => '0');
signal vstate : std_logic_vector(5 downto 0);
signal sending : std_logic := '0';

constant clk_period : time := 10 ns;

-- data to send
signal id_tosend : std_logic_vector (7 downto 0) := (others => '0');
signal data_tosend : std_logic_vector (7 downto 0) := (others => '0');

procedure send(id, data, control_in : in std_logic_vector; signal data_bus, control_bus : out std_logic_vector) is
	begin
		--if control_in = "ZZZZZZZZ" then
		--end if;

		--while control_in = "ZZZZZZZZ" loop
		--	wait for 3 * clk_period;
		--end loop;

		control_bus <= "00000001";
		data_bus <= id;
		wait for clk_period;
		data_bus <= "00000000";
		wait for clk_period;
		data_bus <= data;
		wait for clk_period;
		data_bus <= "00000001";
		wait for clk_period;
		control_bus <= "ZZZZZZZZ";
		data_bus <= "ZZZZZZZZ";
		
end send;


begin
	
	stim_proc: process
	begin
		wait for 5 * clk_period;

		-- send to slaveB
		send(control_in => control_in, control_bus => control_bus, data_bus => data_bus, id => "00000010", data => "10101010");

		wait for clk_period;

		send(control_in => control_in, control_bus => control_bus, data_bus => data_bus, id => "00000001", data => "11111111");
	
	end process;

	stateadvance: process(clk)
	begin
		control_in <= control_bus;
		if rising_edge(clk) then
			data_in <= data_bus;
			current_s <= next_s;
		end if;
	end process;

	nextstate: process(current_s, data_in, control_in)
		variable received : std_logic_vector (7 downto 0) := (others => '0');
	begin

	case current_s is
		when IDLE =>
			vstate <= "000001";
			
			if data_in = identifier then
				next_s <= START;
			elsif sending = '1' then
				next_s <= WRITE;
			else
				next_s <= IDLE;
			end if;

		when WRITE =>
			vstate <= "100000";
			if sending /= '1' then
				next_s <= IDLE;
			end if;

		when START =>
			vstate <= "000000";

			-- bit 0, 8 data bits, bit 1
			case data_in is
				when "00000000" => 
					next_s <= DATA;
				when others => 
					next_s <= IDLE;
			end case;

		when DATA =>
			vstate <= "000010";
			received := data_in;
			next_s <= STOP;

		when STOP =>
			vstate <= "000100";
			case data_in is
				when "00000001" => 
					next_s <= IDLE;
				when others => 
					next_s <= ERROR;
			end case;

		when ERROR =>
			vstate <= "111111";
			next_s <= IDLE;

	   when others =>
			next_s <= IDLE;
	   end case;
	end process;

	state <= vstate;

end Behavioral;