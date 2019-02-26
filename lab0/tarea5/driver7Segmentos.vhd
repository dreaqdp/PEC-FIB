LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY driver7Segmentos IS
 PORT( codigoCaracter : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
 bitsCaracter : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END driver7Segmentos;
ARCHITECTURE Structure OF driver7Segmentos IS
BEGIN
	with codigoCaracter select
	bitsCaracter <= 	"0001001" when "000",
							"1000000" when "001",
							"1000111" when "010",
							"0001000" when "011",
							"0111111" when others;
END Structure;