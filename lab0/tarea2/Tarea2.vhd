LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
ENTITY Tarea2 IS
 PORT( SW : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
 KEY : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
 LEDR : OUT STD_LOGIC_VECTOR(0 DOWNTO 0));
END Tarea2;
ARCHITECTURE Structure OF Tarea2 IS
BEGIN
	LEDR(0)<=not KEY(to_integer(unsigned(SW)));
END Structure; 
