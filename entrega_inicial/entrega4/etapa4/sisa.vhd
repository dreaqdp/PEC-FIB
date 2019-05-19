LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;   

ENTITY sisa IS
    PORT (CLOCK_50  : IN    STD_LOGIC;
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
          SRAM_WE_N : out   std_logic := '1';
          SW        : in std_logic_vector(9 downto 9));
END sisa;

ARCHITECTURE Structure OF sisa IS
component MemoryController is
    port (CLOCK_50  : in  std_logic;
	      addr      : in  std_logic_vector(15 downto 0);
          wr_data   : in  std_logic_vector(15 downto 0);
          rd_data   : out std_logic_vector(15 downto 0);
          we        : in  std_logic;
          byte_m    : in  std_logic;
          -- señales para la placa de desarrollo
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
          SRAM_WE_N : out   std_logic := '1');
end component;

component proc IS
    PORT (boot     : IN  STD_LOGIC;
          clk      : IN  STD_LOGIC;
          datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_m     : OUT STD_LOGIC;
			 word_byte: OUT STD_LOGIC
			 );
END component;

component clock IS
 GENERIC (N : integer);
 PORT( CLOCK_50 : IN std_logic;
 contador : in std_logic_vector (N-1 downto 0);
 clk : out std_logic);
END component;

signal clk_bus, word_byte_bus, wr_m_bus: std_logic;
signal datard_bus, addr_bus, datawr_bus : std_logic_vector(15 downto 0);
BEGIN
	clk_c: clock generic map (4)
					 port map (CLOCK_50 => CLOCK_50, contador => std_logic_vector(to_unsigned(8, 4)), clk => clk_bus);
	
	proc0: proc port map (boot => sw(9),
							clk => clk_bus,
							datard_m => datard_bus,
							addr_m => addr_bus,
							data_wr => datawr_bus,
							wr_m => wr_m_bus,
							word_byte => word_byte_bus);							
	ctr_mem: memorycontroller port map (CLOCK_50 => CLOCK_50,
											 addr => addr_bus,
											 wr_data => datawr_bus,
											 rd_data => datard_bus,
											 we => wr_m_bus,
											 byte_m => word_byte_bus,
											 SRAM_ADDR => SRAM_ADDR,
											 SRAM_DQ => SRAM_DQ,
											 SRAM_UB_N => SRAM_UB_N,
											 SRAM_LB_N => SRAM_LB_N,
											 SRAM_CE_N => SRAM_CE_N,
											 SRAM_OE_N => SRAM_OE_N,
											 SRAM_WE_N => SRAM_WE_N);
END Structure;