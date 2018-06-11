library ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use work.txt_util.all;
use work.types.all;

entity testbench is
end testbench;

architecture test of testbench is
    component ram
        generic (
            ADDRESS_WIDTH : integer;
            WORD_WIDTH    : integer
        );
        port (
            clk     :   in std_logic;
            cmd     :   in std_logic;
            address :   in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
            data    :   inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z')
        );

    end component;

    component alu is
        generic (
            WORD_WIDTH : integer
        );
        port (
            clk     : in std_logic;
            cmd     : in std_logic;
            data    : inout std_logic_vector(WORD_WIDTH-1 downto 0);
            alu_in  : in std_logic_vector(WORD_WIDTH-1 downto 0);
            alu_out : out std_logic_vector(WORD_WIDTH-1 downto 0)
        );
    end component;

    component pc
        generic (
            WORD_WIDTH : integer
        );
        port (
            clk      :  in std_logic;
            data_out :  in std_logic; 
            set      :  in std_logic;
            inc      :  in std_logic;
            data     :  inout std_logic_vector(WORD_WIDTH-1 downto 0)
        );
    end component;

    component reg
        generic (
            WORD_WIDTH : integer
        );
        port (
            clk  :  in std_logic;
            cmd  :  in std_logic;
            data :  inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z')
        );
    end component;

    component acreg is
        generic (
            WORD_WIDTH : integer
        );
        port (
            clk     : in std_logic;
            cmd     : in std_logic;
            alu_get : in std_logic;
            data    : inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');
            ac_out  : out std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');
            ac_in   : in std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z')
        );
    end component;

    component ioreg
        generic (
            WORD_WIDTH : integer
        );
        port (
            clk  : in std_logic;
            cmd  : in std_logic;
            data : inout std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z')
        );
    end component;

    component address_reg
        generic (
            ADDRESS_WIDTH : integer
        );
        port (
            clk     : in std_logic;
            cmd     : in std_logic;
            data    : inout std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => 'Z');
            address : out std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => 'Z')
        );
    end component;

    component controller
        generic (
            ADDRESS_WIDTH : integer;
            WORD_WIDTH    : integer
        );
        port (
            clk      : in std_logic;
            data_bus : inout std_logic_vector(WORD_WIDTH-1 downto 0);
            ctrl_out : out control_t
        );
    end component;

    ---------------------------------------
    ---------------------------------------

    constant ADDRESS_WIDTH  : integer := 5;
    constant WORD_WIDTH     : integer := 9;
    constant ADDR_CLR : std_logic_vector(ADDRESS_WIDTH - 1 downto 0) := (others => 'Z');
    constant DATA_CLR : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => 'Z');
    constant clk_period : time := 10 ns;

    -- signals
    signal clk      :   std_logic := '0';
    signal data_bus :   std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');
    signal ac_alu   :   std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');
    signal alu_ac   :   std_logic_vector(WORD_WIDTH-1 downto 0) := (others => 'Z');
    signal control  :   control_t := (pc => "ZZZ", others => 'Z');
    signal mem_addr :   std_logic_vector(ADDRESS_WIDTH-1 downto 0) := (others => 'Z');

begin
    -----------
    --  RAM  --
    -----------
    memory: ram
    generic map (
        ADDRESS_WIDTH => ADDRESS_WIDTH,
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => control.mem,
        address => mem_addr,
        data => data_bus
    );

    -----------
    --  ALU  --
    -----------
    the_alu: alu
    generic map (
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => control.ALU,
        data => data_bus,
        alu_in => ac_alu,
        alu_out => alu_ac
    );

    ----------
    --  AC  --
    ----------
    ac: acreg
    generic map (
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => control.AC,
        alu_get => control.ALU2AC,
        data => data_bus,
        ac_out => ac_alu,
        ac_in => alu_ac
    );


    ----------
    --  PC  --
    ----------
    progc: pc
    generic map (
        WORD_WIDTH => ADDRESS_WIDTH
    )
    port map (
        clk => clk,
        set => control.PC(2),
        inc => control.PC(1),
        data_out => control.PC(0),
        data => data_bus(ADDRESS_WIDTH-1 downto 0)
    );

    -----------
    --  MAR  --
    -----------
    mar: address_reg
    generic map (
        ADDRESS_WIDTH => ADDRESS_WIDTH
    )
    port map (
        clk => clk,
        cmd => control.mar,
        data => data_bus(ADDRESS_WIDTH-1 downto 0),
        address => mem_addr
    );

    -----------
    --  MBR  --
    -----------
    mbr: reg
    generic map (
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => control.MBR,
        data => data_bus
    );

    ---------
    -- IR  --
    ---------
    ir: reg
    generic map (
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => control.IR,
        data => data_bus
    );

    -------------
    --  InReg  --
    -------------
    inreg: ioreg
    generic map (
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => control.inreg,
        data => data_bus
    );

    --------------
    --  OutReg  --
    --------------
    outreg: ioreg
    generic map (
        WORD_WIDTH => WORD_WIDTH
    )
    port map (
        clk => clk,
        cmd => control.outreg,
        data => data_bus
    );

    ------------
    --  CTRL  --
    ------------
    ctrl: controller
    generic map (
        ADDRESS_WIDTH => 5,
        WORD_WIDTH => 9
    )
    port map (
        clk => clk,
        data_bus => data_bus,
        ctrl_out => control
    );

------------------------
------------------------

    clk_process : process
    begin
        clk <= '1';
        wait for clk_period / 2;
        clk <= '0';
        wait for clk_period / 2;
    end process;

    test_process : process
    begin
        wait for clk_period * 100;
        wait;
    end process;
end test;