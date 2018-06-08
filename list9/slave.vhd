library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
USE work.txt_util.ALL;
use ieee.math_real.all;

------------------------------
--		STATES
------------------------------
-- idle  = "000001"
-- write = "000010"
-- send_start = "000011"
-- send_data  = "000100"
-- send_stop  = "000101"
-- receive ACK = "000110"
-- receive_start = "001010"
-- receive_data  = "001011"
-- receive_stop  = "001100"
-- send ACK = "001101"
-- wait = "000000"
-- error = "111111"

-- ACK: on control_bus: 00000010
------------------------------

entity slave is
	generic (identifier : std_logic_vector (7 downto 0) := "10101010");
	Port ( 
		data_bus : inout STD_LOGIC_VECTOR (7 downto 0);
		control_bus : inout STD_LOGIC_VECTOR (7 downto 0);
		clk : in STD_LOGIC;
		state : out STD_LOGIC_VECTOR (5 downto 0);
		send_id : in STD_LOGIC_VECTOR (7 downto 0);
		send_data : in STD_LOGIC_VECTOR (7 downto 0)
	);
end slave;
architecture Behavioral of slave is

type state_type is (IDLE, R_START, R_DATA, R_STOP, R_ACK, INTERRUPT, 
					S_ID, S_START, S_STOP, S_DATA, S_ACK, WAITING);
signal current_s : state_type := IDLE;
signal next_s : state_type := IDLE;
signal vstate : std_logic_vector(5 downto 0);

signal data_in : std_logic_vector (7 downto 0) := (others => '0');
signal control_in : std_logic_vector (7 downto 0) := (others => '0');
signal tmp_data_bus : std_logic_vector (7 downto 0) := (others => '0');
signal tmp_control_bus : std_logic_vector (7 downto 0) := (others => '0');
signal result_reg : std_logic_vector (7 downto 0) := (others => '0');
signal result_control : std_logic_vector (7 downto 0) := (others => '0');

signal sending : std_logic := '0';
signal id_tosend : std_logic_vector (7 downto 0) := (others => '0');
signal data_tosend : std_logic_vector (7 downto 0) := (others => '0');
signal received_data : std_logic_vector (7 downto 0) := (others => '0');

constant clk_period : time := 10 ns;

begin

	new_message: process(send_id)
	begin
		id_tosend <= send_id;
		assert false report "New message to send" severity note;
		data_tosend <= send_data;
	end process;

	stateadvance: process(clk)
	begin
		control_in <= control_bus;
		data_in <= data_bus;

		if rising_edge(clk) then
			current_s <= next_s;
		else
			data_bus <= tmp_data_bus;
			control_bus <= tmp_control_bus;
		end if;

	end process;

	nextstate: process(clk, control_in, data_in)
		variable received : std_logic_vector (7 downto 0) := (others => '0');
		variable wait_for : integer := to_integer(unsigned(identifier)) mod 9;
		variable id : std_logic_vector (7 downto 0) := (others => '0');

	begin

	case current_s is
		when IDLE =>
			vstate <= "000001";
			if id /= send_id then
				id := send_id;
			end if;

			-- If slave want to send data
			if id /= "00000000" then
				if control_in /= "00000001" then
					sending <= '1';
					result_control <= "00000001";
					next_s <= S_ID;
				else
					next_s <= WAITING;
				end if;
			elsif data_in = identifier and control_in = "00000001" then
				next_s <= R_START;
			else
				next_s <= IDLE;
			end if;

		when WAITING =>
			vstate <= "000000";
			sending <= '0';

			if wait_for > 0 then
				wait_for := wait_for - 1;
				next_s <= WAITING;
			else
				next_s <= IDLE;
				wait_for := to_integer(unsigned(identifier)) mod 9;
			end if;

			if data_in = identifier and control_in = "00000001" then
				next_s <= R_START;
			end if;

		when S_ID =>
			vstate <= "000010";
			result_reg <= id;
			next_s <= S_START;

		when S_START =>
			vstate <= "000011";

			-- conflict dectected
			if data_in /= id then
				--assert false report "conflict in ID" severity note;
				next_s <= WAITING;
			end if;

			result_reg <= "00000000";
			next_s <= S_DATA;

		when S_DATA =>
			vstate <= "000100";

			-- conflict dectected
			if data_in /= "00000000" then
				next_s <= WAITING;
			end if;

			result_reg <= data_tosend;
			next_s <= S_STOP;

		when S_STOP =>
			vstate <= "000101";

			-- conflict dectected
			if data_in /= data_tosend then
				next_s <= INTERRUPT;
			end if;

			result_reg <= "00000001";
			next_s <= WAITING;
			id := (others => '0');


		when R_ACK =>
			next_s <= IDLE;
			if control_in = "00000010" then
				id := (others => '0');
			end if;

		when R_START =>
		-- bit 0, 8 data bits, bit 1
			vstate <= "001010";
			case data_in is
				when "00000000" => 
					next_s <= R_DATA;
				when others => 
					next_s <= INTERRUPT;
			end case;

		when R_DATA =>
			vstate <= "001011";
			received := data_in;
			received_data <= data_in;
			next_s <= R_STOP;

		when R_STOP =>
			vstate <= "001100";
			case data_in is
				when "00000001" => 
					next_s <= IDLE;
				when others => 
					next_s <= INTERRUPT;
			end case;

		when S_ACK =>
			sending <= '1';
			result_control <= "00000010";
			next_s <= IDLE;

		when INTERRUPT =>
			vstate <= "111111";
			next_s <= WAITING;

		when others =>
			next_s <= IDLE;
		end case;

	end process;

	state <= vstate;

	tmp_data_bus <= result_reg when sending = '1' else "ZZZZZZZZ";
	tmp_control_bus <= result_control when sending = '1' else "ZZZZZZZZ";
	
end Behavioral;