LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY driver7segment IS
 PORT( control : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 mask : IN std_logic_vector(6 downto 0);
HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END driver7segment;
ARCHITECTURE Structure OF driver7segment IS

signal conv : std_logic_vector(6 downto 0);

BEGIN
	-- primer mirem quin numero s'hauria de "pintar" teoricament
	with control select
	conv <=  "1000000" when "0000",
				"1111001" when "0001",
				"0100100" when "0010",
				"0110000" when "0011",
				"0011001" when "0100",
				"0010010" when "0101",
				"0000010" when "0110",
				"1111000" when "0111",
				"0000000" when "1000",
				"0011000" when "1001",
				"0001000" when "1010",
				"0000011" when "1011",
				"1000110" when "1100",
				"0100001" when "1101",
				"0000110" when "1110",
				"0001110" when others;
	-- amb la mascara comprovem si s'ha de mostrar el num o no (mask negada perque 1 apaga el segment)
	HEX0 <= conv or (not mask);
				
				
END Structure; 