library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use std.textio.all;
use work.txt_util.all;
use work.types.all;

entity controller is
    generic (
        ADDRESS_WIDTH : integer := 5;
        WORD_WIDTH    : integer := 9
    );
    port (
        clk      : in std_logic;
        data_bus : inout std_logic_vector(WORD_WIDTH-1 downto 0);
        ctrl_out : out control_t
    );
end controller;

architecture arch of controller is
    type state_t is (FETCH, DECODE, EXEC, STORE);
    
    type cmd_t is (NOP, LOAD, STORE, ADD, SUBT, CIN, COUT, HALT, SKIPCOND, JUMP, UNDEF);
    attribute enum_encoding : string;
    attribute enum_encoding of cmd_t : type is
        "0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 ZZZZ";

    signal state_cur : state_t := FETCH;
    signal state_next : state_t := FETCH;
    signal instr : cmd_t := UNDEF;

    constant CMD_READ  : std_logic := '0';
    constant CMD_WRITE : std_logic := '1';
    constant CMD_NOP   : std_logic := 'Z';
    constant PC_SET    : std_logic_vector(2 downto 0) := "100";
    constant PC_INC    : std_logic_vector(2 downto 0) := "010";
    constant PC_OUTPUT : std_logic_vector(2 downto 0) := "001";
    constant PC_NOP    : std_logic_vector(2 downto 0) := "000";
    constant ALU_ADD   : std_logic := '1';
    constant ALU_SUBT  : std_logic := '0';

    signal bus_buffer : std_logic_vector(WORD_WIDTH-1 downto 0) := (others => '0');
    signal control : control_t := (pc => "ZZZ", others => 'Z');

begin
    ctrl_out <= control;

    progress: process(clk)
    begin
        if rising_edge(clk) then
            bus_buffer <= data_bus;
            state_cur <= state_next;
        end if;
    end process;

    main: process(state_cur, data_bus)
        variable substate_ctr :    integer := -1;
        variable opcode    :    std_logic_vector(3 downto 0);
        variable cmp       :    std_logic_vector(1 downto 0);
        variable cmp_res   :    boolean;
        constant state_rst :    integer := -1;

    begin
        case state_cur is
            when FETCH =>
                --report "FETCH:" & str(substate_ctr);
                case substate_ctr is
                    when 0 =>       -- fetch instruction address from PC
                        control.PC <= PC_OUTPUT;
                    when 1 =>        -- save address in MAR; read from memory
                        control.PC <= PC_NOP;
                        control.MAR <= CMD_WRITE;
                    when 2 =>
                        control.MAR <= CMD_NOP;
                        control.MEM <= CMD_READ;
                    when 3 =>       -- write instruction to IR
                        control.MEM <= CMD_NOP;
                        control.IR <= CMD_WRITE;
                        state_next <= DECODE;
                    when others =>
                        state_next <= FETCH;
                end case;
                substate_ctr := substate_ctr + 1;

            --------------------------------------------------------------------
            when DECODE =>
                control.IR <= CMD_NOP;
                report "decode: " & str(bus_buffer);
                opcode := bus_buffer(WORD_WIDTH-1 downto WORD_WIDTH-4);
                case opcode is
                    when "0000" => instr <= NOP;
                    when "0001" => instr <= LOAD;
                    when "0010" => instr <= STORE;
                    when "0011" => instr <= ADD;
                    when "0100" => instr <= SUBT;
                    when "0101" => instr <= CIN;
                    when "0110" => instr <= COUT;
                    when "0111" => instr <= HALT;
                    when "1000" => instr <= SKIPCOND;
                    when "1001" => instr <= JUMP;
                    when others => instr <= UNDEF;
                end case;
                substate_ctr := 0;
                control.PC <= PC_INC;
                state_next <= EXEC;

            --------------------------------------------------------------------
            when EXEC =>
                control.PC <= PC_NOP;
                case instr is
                    when NOP =>
                        report "EXEC:NOP";
                        state_next <= FETCH;

                    when LOAD =>        -- mem[addr] -> ac
                        report "EXEC:LOAD:" & str(substate_ctr);
                        case substate_ctr is
                            when 0 =>
                                control.IR <= CMD_READ;
                            when 1 =>
                                control.IR <= CMD_NOP;
                                control.MAR <= CMD_WRITE; -- from IR
                            when 2 =>
                                control.MAR <= CMD_NOP;
                                control.MEM <= CMD_READ;
                            when 3 =>
                                control.MEM <= CMD_NOP;
                                control.MBR <= CMD_WRITE;
                            when 4 =>
                                control.MBR <= CMD_READ;
                            when 5 =>
                                control.MBR <= CMD_NOP;
                                control.AC <= CMD_WRITE;
                            when 6 =>
                                control.AC <= CMD_NOP;
                                substate_ctr := state_rst;
                                state_next <= FETCH;
                            when others =>
                        end case;

                    when STORE =>       -- ac -> mem[addr]
                        report "EXEC:STORE:" & str(substate_ctr);
                        case substate_ctr is
                            when 0 =>
                                control.AC <= CMD_READ;
                            when 1 =>
                                control.AC <= CMD_NOP;
                                control.IR <= CMD_READ;
                                control.MBR <= CMD_WRITE;
                            when 2 =>
                                control.MBR <= CMD_NOP;
                                control.IR <= CMD_NOP;
                                control.MAR <= CMD_WRITE;
                            when 3 =>
                                control.MAR <= CMD_NOP;
                                substate_ctr := state_rst;
                                state_next <= STORE;
                            when others =>
                        end case;

                    when ADD =>      -- load mem[addr] to bus and tell alu to ADD
                        report "EXEC:ADD:" & str(substate_ctr);
                        case substate_ctr is
                            when 0 =>
                                control.IR <= CMD_READ;
                            when 1 =>
                                control.IR <= CMD_NOP;
                                control.MAR <= CMD_WRITE;
                            when 2 =>
                                control.MAR <= CMD_NOP;
                                control.MEM <= CMD_READ;
                            when 3 =>
                                control.MEM <= CMD_NOP;
                                control.ALU <= ALU_ADD;
                            when 4 =>
                                control.ALU <= CMD_NOP;
                                control.ALU2AC <= '1';
                            when 5 =>
                                control.ALU2AC <= '0';
                                substate_ctr := state_rst;
                                state_next <= FETCH;
                            when others =>
                        end case;
                    when SUBT =>
                        report "EXEC:SUBT:" & str(substate_ctr);
                        -- load mem[addr] to bus and tell alu to SUBT
                        case substate_ctr is
                            when 0 =>
                                control.IR <= CMD_READ;
                            when 1 =>
                                control.IR <= CMD_NOP;
                                control.MAR <= CMD_WRITE;
                            when 2 =>
                                control.MAR <= CMD_NOP;
                                control.MEM <= CMD_READ;
                            when 3 =>
                                control.MEM <= CMD_NOP;
                                control.ALU <= ALU_SUBT;
                            when 4 =>
                                control.ALU <= CMD_NOP;
                                control.ALU2AC <= '1';
                            when 5 =>
                                control.ALU2AC <= '0';
                                substate_ctr := state_rst;
                                state_next <= FETCH;
                            when others =>
                        end case;
                    when CIN =>
                        report "EXEC:CIN:" & str(substate_ctr);
                        case substate_ctr is
                            when 0 =>
                                control.INREG <= CMD_READ;
                            when 1 =>
                                control.INREG <= CMD_NOP;
                                control.AC <= CMD_WRITE;
                            when 2 =>
                                control.AC <= CMD_NOP;
                                substate_ctr := state_rst;
                                state_next <= FETCH;
                            when others =>
                        end case;
                    when COUT =>
                        report "EXEC:COUT:" & str(substate_ctr);
                        case substate_ctr is
                            when 0 =>
                                control.AC <= CMD_READ;
                            when 1 =>
                                control.AC <= CMD_NOP;
                                control.OUTREG <= CMD_WRITE;
                            when 2 =>
                                control.OUTREG <= CMD_NOP;
                                substate_ctr := state_rst;
                                state_next <= FETCH;
                            when others =>
                        end case;
                    when HALT =>
                        report "HALT: stopping";
                    when SKIPCOND =>
                        report "EXEC:SKIPCOND:" & str(substate_ctr);
                        case substate_ctr is
                            when 0 =>
                                control.IR <= CMD_READ;
                            when 1 =>
                                control.IR <= CMD_NOP;
                                control.AC <= CMD_READ;
                            when 2 =>
                                control.AC <= CMD_NOP;
                                cmp := bus_buffer(ADDRESS_WIDTH-1 downto ADDRESS_WIDTH-2);
                                if cmp = "00" then -- < 0
                                    report "SKIPCOND:compare AC: "& str(bus_buffer) & " < 0" ;
                                    cmp_res := signed(bus_buffer) < to_signed(0, WORD_WIDTH);
                                    report "SKIPCOND: " & boolean'image(cmp_res);
                                elsif cmp = "01" then -- == 0
                                    report "SKIPCOND:compare AC: "& str(bus_buffer) & " = 0";
                                    cmp_res := signed(bus_buffer) = to_signed(0, WORD_WIDTH);
                                    report "SKIPCOND: "& boolean'image(cmp_res);
                                elsif cmp = "10" then -- > 0
                                    report "SKIPCOND:compare AC > 0";
                                    cmp_res := signed(bus_buffer) > to_signed(0, WORD_WIDTH);
                                else
                                    report "SKIPCOND:compare AC ? 0";
                                    cmp_res := false;
                                end if;
                                if cmp_res then
                                    control.PC <= PC_INC;
                                    report "SKIPCOND:INCREMENT PC";
                                else
                                    substate_ctr := state_rst;
                                    state_next <= FETCH;
                                end if;
                            when 3 =>
                                control.PC <= PC_NOP;
                                substate_ctr := state_rst;
                                state_next <= FETCH;
                            when others =>
                        end case;
                    when JUMP =>
                        report "EXEC:JUMP:" & str(substate_ctr);
                        case substate_ctr is
                            when 0 =>
                                control.IR <= CMD_READ;         -- get the adress on the bus
                            when 1 =>
                                control.IR <= CMD_NOP;
                                control.PC <= PC_SET;
                            when 2 =>
                                control.PC <= PC_NOP;
                                substate_ctr := state_rst;
                                state_next <= FETCH;
                            when others =>
                        end case;
                    when UNDEF =>
                        state_next <= FETCH;
                end case;
                substate_ctr := substate_ctr + 1;

            --------------------------------------------------------------------
            when STORE =>            -- push MBR => mem[MAR]
                report "STORE:" & str(substate_ctr);
                case substate_ctr is
                    when 0 =>
                        control.MBR <= CMD_READ;
                        state_next <= STORE;
                    when 1 =>
                        control.MBR <= CMD_NOP;
                        control.MEM <= CMD_WRITE;
                        state_next <= STORE;
                    when 2 =>
                        control.MEM <= CMD_NOP;
                        substate_ctr := state_rst;
                        state_next <= FETCH;
                    when others =>
                end case;
                substate_ctr := substate_ctr + 1;
        end case;
    end process;
end arch;