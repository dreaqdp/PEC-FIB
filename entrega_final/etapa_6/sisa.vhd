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
			 LEDG      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); 
			 LEDR      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
          HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			 HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			 HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			 HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			 SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			 KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			 ps2_clk : inout std_logic;
			 ps2_dat : inout std_logic;
			 VGA_R : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); 
			 VGA_G : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); 
			 VGA_B : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); 
			 VGA_HS : OUT STD_LOGIC; 
			 VGA_VS : OUT STD_LOGIC			 			 
			 ); 
END sisa;

ARCHITECTURE Structure OF sisa IS
component MemoryController is
    port (CLOCK_50  : in  std_logic;
	      addr      : in  std_logic_vector(15 downto 0);
          wr_data   : in  std_logic_vector(15 downto 0);
          rd_data   : out std_logic_vector(15 downto 0);
          we        : in  std_logic;
          byte_m    : in  std_logic;
          -- seÃƒÂ±ales para la placa de desarrollo
          SRAM_ADDR : out   std_logic_vector(17 downto 0);
          SRAM_DQ   : inout std_logic_vector(15 downto 0);
          SRAM_UB_N : out   std_logic;
          SRAM_LB_N : out   std_logic;
          SRAM_CE_N : out   std_logic := '1';
          SRAM_OE_N : out   std_logic := '1';
          SRAM_WE_N : out   std_logic := '1';
			 vga_addr : out std_logic_vector(12 downto 0);
			 vga_we : out std_logic;
			 vga_wr_data : out std_logic_vector(15 downto 0);
			 vga_rd_data : in std_logic_vector(15 downto 0);
			 vga_byte_m : out std_logic );
end component;

component proc IS
    PORT (boot     : IN  STD_LOGIC;
          clk      : IN  STD_LOGIC;
          datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rd_io	 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_m     : OUT STD_LOGIC;
			 word_byte: OUT STD_LOGIC;
			 wr_io	 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			 addr_io  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			 rd_in 	 : OUT STD_LOGIC;
			 wr_out   : OUT STD_LOGIC
			 );
END component;

component clock IS
 GENERIC (N : integer);
 PORT( CLOCK_50 : IN std_logic;
 contador : in std_logic_vector (N-1 downto 0);
 clk : out std_logic);
END component;

component controladores_IO IS
 PORT (boot : IN STD_LOGIC;
		 CLOCK_50 : IN std_logic;
		 addr_io : IN std_logic_vector(7 downto 0);
		 wr_io : in std_logic_vector(15 downto 0);
		 rd_io : out std_logic_vector(15 downto 0);
		 wr_out : in std_logic;
		 rd_in : in std_logic;
		 ps2_clk : inout std_logic;
		 ps2_data : inout std_logic; 
		 led_verdes : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 led_rojos : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
		 KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 vga_cursor : out std_logic_vector(15 downto 0);
		 vga_cursor_enable : out std_logic);
END component;

component vga_controller is
    port(clk_50mhz      : in  std_logic; -- system clock signal
         reset          : in  std_logic; -- system reset
         blank_out      : out std_logic; -- vga control signal
         csync_out      : out std_logic; -- vga control signal
         red_out        : out std_logic_vector(7 downto 0); -- vga red pixel value
         green_out      : out std_logic_vector(7 downto 0); -- vga green pixel value
         blue_out       : out std_logic_vector(7 downto 0); -- vga blue pixel value
         horiz_sync_out : out std_logic; -- vga control signal
         vert_sync_out  : out std_logic; -- vga control signal
         --
         addr_vga          : in std_logic_vector(12 downto 0);
         we                : in std_logic;
         wr_data           : in std_logic_vector(15 downto 0);
         rd_data           : out std_logic_vector(15 downto 0);
         byte_m            : in std_logic;
         vga_cursor        : in std_logic_vector(15 downto 0);  -- simplemente lo ignoramos, este controlador no lo tiene implementado
         vga_cursor_enable : in std_logic);                     -- simplemente lo ignoramos, este controlador no lo tiene implementado
end component;

signal clk_bus, word_byte_bus, wr_m_bus, bus_rd_in, bus_wr_out : std_logic;
signal datard_bus, addr_bus, datawr_bus, bus_wr_io, bus_rd_io : std_logic_vector(15 downto 0);
signal bus_addr_io : std_logic_vector(7 downto 0);

signal bus_vga_addr : std_logic_vector(12 downto 0);
signal bus_vga_we, bus_vga_byte_m, bus_vga_cursor_enable : std_logic;
signal bus_vga_wr_data, bus_vga_rd_data, bus_vga_cursor : std_logic_vector(15 downto 0);
signal bus_vga_r, bus_vga_g, bus_vga_b : std_logic_vector(7 downto 0);
--Signal clk_aux: std_logic_vector(22 downto 0);
	
BEGIN
	clk_c: clock generic map (4)
					 port map (CLOCK_50 => CLOCK_50, contador => std_logic_vector(to_unsigned(8, 4)), clk => clk_bus);
	
--process (CLOCK_50,SW(9)) begin
--	if SW(9)='1' then
--		clk_aux<="00000000000000000000000";
--	else
--		if rising_edge(CLOCK_50) then
--			clk_aux <= clk_aux-1;
--		end if;
--	end if;
--end process;	
--clk_bus<=clk_aux(3);
	
	proc0: proc port map (boot => SW(9),
							clk => clk_bus,
							datard_m => datard_bus,
							rd_io => bus_rd_io,
							addr_m => addr_bus,
							data_wr => datawr_bus,
							wr_m => wr_m_bus,
							word_byte => word_byte_bus,
							wr_io	=> bus_wr_io,
							addr_io => bus_addr_io,
							rd_in => bus_rd_in,
							wr_out => bus_wr_out);
							
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
											 SRAM_WE_N => SRAM_WE_N,
											 vga_addr => bus_vga_addr,
											 vga_we => bus_vga_we,
											 vga_wr_data => bus_vga_wr_data,
											 vga_rd_data => bus_vga_rd_data,
											 vga_byte_m => bus_vga_byte_m);
											 
	ctr_io: controladores_IO port map (boot => sw(9),
												  CLOCK_50 => CLOCK_50,
												  addr_io => bus_addr_io,
												  wr_io => bus_wr_io,
												  rd_io => bus_rd_io,
												  wr_out => bus_wr_out,
												  rd_in => bus_rd_in,
												  ps2_clk => ps2_clk,
												  ps2_data => ps2_dat,
												  led_verdes => LEDG, 
												  led_rojos => LEDR,
												  hex0 => hex0,
												  hex1 => hex1,
												  hex2 => hex2,
												  hex3 => hex3,
												  sw => sw,
												  key => key,
												  vga_cursor => bus_vga_cursor,
												  vga_cursor_enable => bus_vga_cursor_enable
												  );

	VGA_R <= bus_vga_r(3 downto 0);											  
	VGA_G <= bus_vga_g(3 downto 0);	
	VGA_B <= bus_vga_b(3 downto 0);	
	
	vga_ctrl: vga_controller port map (clk_50mhz => CLOCK_50,
												  reset => sw(9),
												  red_out => bus_vga_r,
												  green_out => bus_vga_g,
												  blue_out => bus_vga_b,
												  horiz_sync_out => VGA_HS,
												  vert_sync_out => VGA_VS,
												  addr_vga => bus_vga_addr,
												  we => bus_vga_we,
												  wr_data => bus_vga_wr_data,  
												  rd_data => bus_vga_rd_data, 
												  byte_m => bus_vga_byte_m,
												  vga_cursor => bus_vga_cursor,
												  vga_cursor_enable => bus_vga_cursor_enable);
												  

END Structure;