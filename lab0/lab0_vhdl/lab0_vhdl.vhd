LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY lab0_vhdl IS
 PORT( KEY : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
 LEDG : OUT STD_LOGIC_VECTOR(2 DOWNTO 2));
END lab0_vhdl;
ARCHITECTURE Structure OF lab0_vhdl IS
BEGIN
 LEDG(2) <= not(KEY(0)) and not(KEY(1));
END Structure; 