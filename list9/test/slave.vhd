library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
USE work.txt_util.ALL;

------------------------------
--		STATES
------------------------------
-- idle  = "000001"
-- write = "000010"
-- send_start = "000011"
-- send_data  = "000100"
-- send_stop  = "000101"
-- send_end = "00110"
-- receive_start = "001010"
-- receive_data  = "001011"
-- receive_stop  = "001100"
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

type state_type is (IDLE, RECEIVE_START, RECEIVE_DATA, RECEIVE_STOP, 
					ERROR, WRITE, SEND_START, SEND_STOP, SEND_DATA, SEND_END);
signal current_s : state_type := IDLE;
signal next_s : state_type := IDLE;

-- input buffer
signal data_in : std_logic_vector (7 downto 0) := (others => '0');
signal control_in : std_logic_vector (7 downto 0) := (others => '0');

signal vstate : std_logic_vector(5 downto 0);
signal sending : std_logic := '0';
signal end_sending : std_logic := '0';

signal sender : std_logic_vector (7 downto 0) := (others => '0');
signal id_tosend : std_logic_vector (7 downto 0) := (others => '0');
signal data_tosend : std_logic_vector (7 downto 0) := (others => '0');

signal result_reg : std_logic_vector (7 downto 0) := (others => '0');
signal tmp_data_bus : std_logic_vector (7 downto 0) := (others => '0');

constant clk_period : time := 10 ns;

begin
	
	stim_proc: process
	begin
		wait for clk_period;

		-- slaveA => slaveB
		sender <= "00000001";
		id_tosend <= "00000010";
		data_tosend <= "10101010";

		-- slaveB => slaveC
		--sender <= "00000010";
		--id_tosend <= "00000011";
		--data_tosend <= "10101010";

		wait for 100 * clk_period;

	end process;

	sending_process: process(data_tosend, control_in)
	begin
		if control_in /= "00000001" and data_tosend /= "00000000" then
			control_bus <= "00000001";
			sending <= '1';
		end if;
	end process;

	stateadvance: process(clk)
	begin
		control_in <= control_bus;
		if rising_edge(clk) then
			data_in <= data_bus;
			current_s <= next_s;
		else
			data_bus <= tmp_data_bus;
		end if;
	end process;

	nextstate: process(current_s, data_in)
		variable received : std_logic_vector (7 downto 0) := (others => '0');
	begin

	case current_s is
		when IDLE =>
			vstate <= "000001";

			if sender = identifier and sending = '1' then
				next_s <= WRITE;
			elsif data_in = identifier and sending /= '0' then
				next_s <= RECEIVE_START;
			else
				next_s <= IDLE;
			end if;

		when WRITE =>
			vstate <= "000010";
			result_reg <= id_tosend;
			next_s <= SEND_START;

		when SEND_START =>
			vstate <= "000011";
			result_reg <= "00000000";
			next_s <= SEND_DATA;

		when SEND_DATA =>
			vstate <= "000100";
			result_reg <= data_tosend;
			next_s <= SEND_STOP;

		when SEND_STOP =>
			vstate <= "000101";
			result_reg <= "00000001";
			next_s <= IDLE;

		when SEND_END =>
			vstate <= "000110";
			--sending <= '0';
			next_s <= IDLE;

		when RECEIVE_START =>
		-- bit 0, 8 data bits, bit 1
			vstate <= "001010";
			case data_in is
				when "00000000" => 
					next_s <= RECEIVE_DATA;
				when others => 
					next_s <= IDLE;
			end case;

		when RECEIVE_DATA =>
			vstate <= "001011";
			received := data_in;
			next_s <= RECEIVE_STOP;

		when RECEIVE_STOP =>
			vstate <= "001100";
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

	tmp_data_bus <= result_reg when sending = '1' and sender = identifier else "ZZZZZZZZ";

end Behavioral;