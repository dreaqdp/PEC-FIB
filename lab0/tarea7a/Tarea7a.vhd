  LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
ENTITY Tarea7a IS
 PORT( CLOCK_50 : IN std_logic;
 HEX0 : OUT std_logic_vector(6 downto 0);
 LEDR : OUT std_logic_vector(2 downto 0));
END Tarea7a;

ARCHITECTURE Structure OF Tarea7a IS

component driver7segmentNUM IS
 PORT( control : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END component;
constant c1 : std_LOGIC_VECTOR (24 downto 0) := (24 => '0', others => '1');
constant c2 : std_LOGIC_VECTOR (24 downto 0) := (others => '1');

signal count : std_LOGIC_VECTOR (24 downto 0);
signal old_count : std_logic := '0';
signal count_num : std_LOGIC_VECTOR (2 downto 0) := "000";
BEGIN
	process (CLOCK_50) 
	begin
		if rising_edge(CLOCK_50) then 
			count <= count + 1;
				
			if count = c1 or count = c2 then 
				count_num <= count_num + 1;
			end if;
		end if;
	end process;
	
	
	LEDR <= count_num;
	h0: driver7segmentNUM port map (count_num, HEX0); 
END Structure; 