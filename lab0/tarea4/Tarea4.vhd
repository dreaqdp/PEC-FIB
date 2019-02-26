LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY Tarea4 IS
 PORT( SW : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END Tarea4;
ARCHITECTURE Structure OF Tarea4 IS
BEGIN
	with SW select
	HEX0 <=  "1000000" when "000",
				"1111001" when "001",
				"0100100" when "010",
				"0110000" when "011",
				"0011001" when "100",
				"0010010" when "101",
				"0000010" when "110",
				"1111000" when "111";
				
				
END Structure; 