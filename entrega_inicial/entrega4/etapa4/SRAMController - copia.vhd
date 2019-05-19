library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SRAMController is
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
          WR          : in    std_logic;
          byte_m      : in    std_logic := '0');
end SRAMController;

architecture comportament of SRAMController is

type state_type is (Esc0,Esc1);
signal extensio_signe: std_logic_vector(7 downto 0);
signal writing : std_logic_vector(0 downto 0);
signal state   : state_type := Esc0;-- Register to hold the current state
begin
	SRAM_CE_N <= '0';
	SRAM_OE_N <= '0';
   SRAM_ADDR <= "000" & address(15 downto 1);

	SRAM_WE_N <= '0' when (state=Esc1 and WR='1') else '1';
	--llegir words
	SRAM_LB_N <= '1' when (WR='1' and byte_m='1' and address(0)='1') else '0';
	SRAM_UB_N <= '1' when (WR='1' and byte_m='1' and address(0)='0') else '0';

	SRAM_DQ <="ZZZZZZZZZZZZZZZZ" when (WR='0') else --lectures
				 dataToWrite(7 downto 0) & "ZZZZZZZZ" when (WR='1' and byte_m='1' and address(0)='1') else --escriptura byte alt
				 dataToWrite; --escriptura word o byte baix

	extensio_signe <= (others=>SRAM_DQ(7)) when address(0)='0' else
							(others=>SRAM_DQ(15));
	
	dataReaded <=  extensio_signe&SRAM_DQ(7 downto 0) when (byte_m='1' and address(0)='0') else   -- llegir byte parell
						extensio_signe&SRAM_DQ(15 downto 8)	when (byte_m='1' and address(0)='1') else   -- llegir byte senar
						SRAM_DQ;	-- llegir word
						
	process(clk, WR)
	begin
		if WR = '0' then
			writing <= "1";
		elsif rising_edge(clk) then
			case state is
				when Esc0 => 
					if writing = "1" then
						state <= Esc1;
						writing <= "0";
					else state <= Esc0;
					end if;
				when others => 
					state <= Esc0;
					
			end case;
			
		end if;
	end process;
	
end comportament;
