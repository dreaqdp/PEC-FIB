LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE work.constants_pkg.all;

ENTITY controladores_IO IS
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
		 SW : IN STD_LOGIC_VECTOR(9 DOWNTO 0); --9 es el de boot, 8 unused
		 KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 vga_cursor : out std_logic_vector(15 downto 0);
		 vga_cursor_enable : out std_logic); 
END controladores_IO;
ARCHITECTURE Structure OF controladores_IO IS

component driver4display IS
 PORT( number : IN std_logic_vector (15 downto 0);
		 mask : IN std_logic_vector(27 downto 0);
		 HEX0 : OUT std_logic_vector(6 downto 0);
		 HEX1 : OUT std_logic_vector(6 downto 0);
		 HEX2 : OUT std_logic_vector(6 downto 0);
		 HEX3 : OUT std_logic_vector(6 downto 0));
END component;

component keyboard_controller is
 port (clk : in STD_LOGIC;
		 reset : in STD_LOGIC;
		 ps2_clk : inout STD_LOGIC;
		 ps2_data : inout STD_LOGIC;
		 read_char : out STD_LOGIC_VECTOR (7 downto 0);
		 clear_char : in STD_LOGIC;
		 data_ready : out STD_LOGIC);
end component;

   type IO_mem_array is array (32 downto 0) of std_logic_vector(15 downto 0); --TODO: ARRAY SIZE = 256
	signal IO_mem: IO_mem_array;
	signal value_readed: std_logic_vector(15 downto 0);
	signal mask : std_logic_vector(27 downto 0);
	signal mask0, mask1, mask2, mask3 : std_logic_vector(6 downto 0);
	signal bus_reset, bus_data_ready, bus_clear_char: std_logic;
	signal bus_read_char : std_logic_vector(7 downto 0);
	
	signal primerclock : std_logic := '1';
	-- signals pel snake
	signal contador_ciclos : STD_LOGIC_VECTOR(15 downto 0):=x"0000";
	signal contador_milisegundos : STD_LOGIC_VECTOR(15 downto 0):=x"0000";
	--signal tmp_contador_milisegundos : STD_LOGIC_VECTOR(15 downto 0):=x"0000"; --TODO
	
begin
	-- process pel snake
--	 process(CLOCK_50)
--		 begin
--			 if rising_edge(CLOCK_50) then
--				 if contador_ciclos=0 then
--				 contador_ciclos<=x"C350"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos
--					 if contador_milisegundos>0 then
--						contador_milisegundos <= contador_milisegundos-1;
--					 end if;
--				 else
--				 contador_ciclos <= contador_ciclos-1;
--				 end if;
--			 end if;
--	 end process;
	
	process (CLOCK_50, boot)
	begin
		if boot = '0' then
			if rising_edge(CLOCK_50) then
				--SNAKE
				if(contador_ciclos=0) then
					contador_ciclos<=x"C350"; -- tiempo de ciclo=20ns(50Mhz) 1ms=50000ciclos
					if contador_milisegundos>0 then
						contador_milisegundos <= contador_milisegundos-1;
					end if;
				else
					contador_ciclos <= contador_ciclos-1;
				end if;
				
				--TODO : AIXO NO CAL CREC
				if (primerclock = '1') then
					bus_reset <= '1';
					primerclock <= '0';
				else
					bus_reset <= '0';
				end if;
			
			
				bus_clear_char <= '0';
				if (wr_out = '1') then				
					if (addr_io = 16) then -- TREURE AIXO DEL TECLAT DEL PROCESS
						bus_clear_char <= '1'; -- ha arribat un out per indicar reset del teclat
					elsif (addr_io = 21) then -- afegit pel snake
						contador_milisegundos <= wr_io; --tmp per que no s'asigni en dos process diferents
					end if;
					
					if (addr_io /= 7 and addr_io /= 8 and addr_io /= 20) then
						IO_mem(to_integer(unsigned(addr_io))) <= wr_io; --escriptura
					end if;
				end if;
				IO_mem(7) <= x"000" & key;
				IO_mem(8) <= x"00" & sw(7 downto 0);
				bus_reset <= '0';
			end if;
		else
			bus_reset <= '1';
		end if;
	end process;
	
	
	key_ctrl : keyboard_controller port map (clk => CLOCK_50,
														  reset => bus_reset,
														  ps2_clk => ps2_clk,
														  ps2_data => ps2_data,
														  read_char => bus_read_char,
														  clear_char => bus_clear_char,
														  data_ready => bus_data_ready);
														 

	
	-- preparem la mascara per el display, 0 indica que s'apaga el hex; fem mask parcials
	mask0 <= (others => IO_mem(9)(0));
	mask1 <= (others => IO_mem(9)(1));
	mask2 <= (others => IO_mem(9)(2));
	mask3 <= (others => IO_mem(9)(3));
	mask <= mask3 & mask2 & mask1 & mask0;
	driver4disp: driver4display port map (number => IO_mem(10), mask => mask, hex0 => hex0, hex1 => hex1, hex2 => hex2, hex3 => hex3);
	
	-- seleccio d'on lleguim: dels register io o de periferic
	
	--TODO : 0=>BUS_DATA_READY
	with addr_io select
		value_readed <= x"00" & bus_read_char when x"0F", -- ascii teclat
							 (0 => bus_data_ready, others => '0') when x"10", -- tecla pulsada
							 contador_milisegundos when x"15", -- pel snake (sleep)
							 contador_ciclos when x"14", --pel snake (random)
							 IO_mem(to_integer(unsigned(addr_io))) when others;
	rd_io <= value_readed when rd_in = '1'; --lectura
	
	--led_verdes <= "100000" & bus_clear_char & bus_data_ready;
	--led_rojos <= bus_read_char;
	led_verdes <= IO_mem(5)(7 downto 0); 
	led_rojos <= IO_mem(6)(7 downto 0); 
		
	vga_cursor <= x"FFFF";   --com es el controlador VGA1, s'ignoran els valors.
	vga_cursor_enable <='0'; --com es el controlador VGA1, s'ignoran els valors.
END Structure;