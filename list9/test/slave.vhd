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
-- receive_start = "001010"
-- receive_data  = "001011"
-- receive_stop  = "001100"
-- wait = "000000"
-- error = "111111"
------------------------------

entity slave is
	generic ( identifier : std_logic_vector (7 downto 0) := "10101010" );
	Port ( 
		data_bus : inout STD_LOGIC_VECTOR (7 downto 0);
		control_bus : inout STD_LOGIC_VECTOR (7 downto 0);
		--clk : in STD_LOGIC;
		state : out STD_LOGIC_VECTOR (5 downto 0);
		send_id : in std_logic_vector (7 downto 0);
		send_data : in std_logic_vector (7 downto 0)
	);
end slave;
architecture Behavioral of slave is

type state_type is (IDLE, RECEIVE_START, RECEIVE_DATA, RECEIVE_STOP, 
					ERROR, WRITE, SEND_START, SEND_STOP, SENDDATA, WAITING);
signal current_s : state_type := IDLE;
signal next_s : state_type := IDLE;

-- input buffer
signal data_in : std_logic_vector (7 downto 0) := (others => '0');
signal control_in : std_logic_vector (7 downto 0) := (others => '0');

signal vstate : std_logic_vector(5 downto 0);
signal sending : std_logic := '0';
signal end_sending : std_logic := '0';
--signal after_sending : std_logic := '0';

--signal sender : std_logic_vector (7 downto 0) := (others => '0');
signal id_tosend : std_logic_vector (7 downto 0) := (others => '0');
signal data_tosend : std_logic_vector (7 downto 0) := (others => '0');

signal result_reg : std_logic_vector (7 downto 0) := (others => '0');
signal tmp_data_bus : std_logic_vector (7 downto 0) := (others => '0');

signal clk : std_logic := '0';

constant clk_period : time := 10 ns;

begin

	clk_process: process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;

	demands: process(send_id)
	begin
		id_tosend <= send_id;
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
		end if;
	end process;

	nextstate: process(current_s, id_tosend, data_in)
		variable received : std_logic_vector (7 downto 0) := (others => '0');
		variable wait_for : integer := 11;
	begin

	case current_s is
		when IDLE =>
			vstate <= "000001";

			if send_id /= "UUUUUUUU" then
				assert false report "'" & str(identifier) & " WANT to send" severity note;
				if control_in /= "00000001" then
					assert false report "'" & str(identifier) & " CAN send" severity note;
					sending <= '1';
					next_s <= WRITE;
				else
					next_s <= WAITING;
				end if;
			elsif data_in = identifier and control_in = "00000001" then
				assert false report "'" & str(identifier) & " is listening" severity note;
				next_s <= RECEIVE_START;
			else
				assert false report "'" & str(identifier) & " is waiting" severity note;
				next_s <= IDLE;
			end if;

		when WAITING =>
			vstate <= "000000";
			sending <= '0';
			if wait_for > 0 then
				wait_for := wait_for - 1;
			else
				next_s <= IDLE;
				wait_for := 11;
			end if;

		when WRITE =>
			vstate <= "000010";
			result_reg <= id_tosend;
			next_s <= SEND_START;

		when SEND_START =>
			vstate <= "000011";
			result_reg <= "00000000";
			next_s <= SENDDATA;

		when SENDDATA =>
			vstate <= "000100";
			result_reg <= data_tosend;
			next_s <= SEND_STOP;

		when SEND_STOP =>
			vstate <= "000101";
			result_reg <= "00000001";
			next_s <= WAITING;

		when RECEIVE_START =>
		-- bit 0, 8 data bits, bit 1
			vstate <= "001010";
			case data_in is
				when "00000000" => 
					next_s <= RECEIVE_DATA;
				when others => 
					next_s <= ERROR;
			end case;

		when RECEIVE_DATA =>
			vstate <= "001011";
			if data_in /= "ZZZZZZZZ" then 
				received := data_in;
				next_s <= RECEIVE_STOP;
			end if;

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
			next_s <= ERROR;

	   when others =>
			next_s <= IDLE;
	   end case;
	end process;

	state <= vstate;

	tmp_data_bus <= result_reg when sending = '1' else "ZZZZZZZZ";
	control_bus <= "00000001" when sending = '1' else "ZZZZZZZZ";

end Behavioral;