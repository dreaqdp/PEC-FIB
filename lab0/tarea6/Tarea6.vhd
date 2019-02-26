LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
ENTITY Tarea6 IS
 PORT( KEY : IN std_logic_vector(0 downto 0);
 SW : IN std_logic_vector(0 downto 0);
 HEX0 : OUT std_logic_vector(6 downto 0);
 HEX1 : OUT std_logic_vector(6 downto 0);
 HEX2 : OUT std_logic_vector(6 downto 0);
 HEX3 : OUT std_logic_vector(6 downto 0);
 LEDR : OUT std_logic_vector(2 downto 0));
END Tarea6;

ARCHITECTURE Structure OF Tarea6 IS
component driver7Segmentos
	PORT( codigoCaracter : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
	bitsCaracter : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
end component;
--signal code0, code1, code2, code3 : std_LOGIC_VECTOR (2 downto 0); 
signal codes : std_LOGIC_VECTOR (11 downto 0);
signal count : std_logic_vector (2 downto 0) := "000";
BEGIN
		LEDR <= count;
		with count select
			codes <= "000001010011" when "000",
						"001010011111" when "001",
						"010011111111" when "010",
						"011111111111" when "011",
						"111111111111" when "100",
						"111111111000" when "101",
						"111111000001" when "110",
						"111000001010" when others;	
		h0: driver7Segmentos port map (codes(2 downto 0), HEX0);
		h1: driver7Segmentos port map (codes(5 downto 3), HEX1);
		h2: driver7Segmentos port map (codes(8 downto 6), HEX2);
		h3: driver7Segmentos port map (codes(11 downto 9), HEX3);
		process (key(0)) begin
			if falling_edge (key(0)) then 
				if (SW="0") then count <= count + 1;
				else count <= count - 1;
				end if;
			end if;
		end process;
		
END Structure; 