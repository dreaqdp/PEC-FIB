LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
ENTITY driver4display IS
 PORT( number : IN std_logic_vector (15 downto 0);
		 mask : IN std_logic_vector(27 downto 0);
		 HEX0 : OUT std_logic_vector(6 downto 0);
		 HEX1 : OUT std_logic_vector(6 downto 0);
		 HEX2 : OUT std_logic_vector(6 downto 0);
		 HEX3 : OUT std_logic_vector(6 downto 0));
END driver4display;

ARCHITECTURE Structure OF driver4display IS

component driver7segment IS
 PORT( control : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
 		 mask : IN std_logic_vector(6 downto 0);
HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END component;


BEGIN
	-- neguem la mascara perque 1 indica que sapaga el segment, amb una or indiquem quins hex volem apagar

	h0: driver7segment port map (number(3 downto 0), mask(6 downto 0), HEX0);
	h1: driver7segment port map (number(7 downto 4), mask(13 downto 7), HEX1);
	h2: driver7segment port map (number(11 downto 8), mask(20 downto 14), HEX2);
	h3: driver7segment port map (number(15 downto 12), mask(27 downto 21), HEX3);

	
END Structure; 