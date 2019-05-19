library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.all;
USE work.constants_pkg.all;   

entity MemoryController is
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
end MemoryController;

architecture comportament of MemoryController is
component SRAMController is
    port (clk         : in    std_logic;
          -- señales para la placa de desarrollo
          SRAM_ADDR   : out   std_logic_vector(17 downto 0);
          SRAM_DQ     : inout std_logic_vector(15 downto 0);
          SRAM_UB_N   : out   std_logic;
          SRAM_LB_N   : out   std_logic;
          SRAM_CE_N   : out   std_logic := '1';
          SRAM_OE_N   : out   std_logic := '1';
          SRAM_WE_N   : out   std_logic := '1';
          -- señales internas del procesador
          address     : in    std_logic_vector(15 downto 0) := "0000000000000000";
          dataReaded  : out   std_logic_vector(15 downto 0);
          dataToWrite : in    std_logic_vector(15 downto 0);
          WR          : in    std_logic; -- write = 1
          byte_m      : in    std_logic := '0');
end component;

component clock IS
 GENERIC (N : integer);
 PORT( CLOCK_50 : IN std_logic;
 contador : in std_logic_vector (N-1 downto 0);
 clk : out std_logic);
END component;

signal clk_bus, we_valid: std_logic;

begin
	-- comprovar que l'adreça es valida
	with addr < max_addr select
		we_valid <= we when true,
					   '0' when others;
	
	
	SRAM: SRAMController port map (clk => CLOCK_50,--clk_bus,
						 SRAM_ADDR => SRAM_ADDR,
						 SRAM_DQ => SRAM_DQ,
						 SRAM_UB_N => SRAM_UB_N,
						 SRAM_LB_N => SRAM_LB_N,
						 SRAM_CE_N => SRAM_CE_N,
						 SRAM_OE_N => SRAM_OE_N,
						 SRAM_WE_N => SRAM_WE_N,
						 address => addr,
						 dataReaded => rd_data,
						 dataToWrite => wr_data,
						 WR => we_valid,
						 byte_m => byte_m);
end comportament;
