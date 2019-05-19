LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE work.constants_pkg.all;

ENTITY timer IS
    PORT (CLOCK_50    : IN  STD_LOGIC;
			 boot   : IN STD_LOGIC; 
			 inta   : IN STD_LOGIC; 
			 intr   : OUT STD_LOGIC
			 );
END timer;


ARCHITECTURE Structure OF timer IS

signal contador : std_logic_vector(23 downto 0) := x"000000"; --maxim 25 divisions
signal pending : std_logic := '0';	 
BEGIN

	process(CLOCK_50)
	begin
		if boot='1' then
				contador <= x"000000";
				pending <= '0';
		elsif rising_edge(CLOCK_50) then
			contador <= contador + 1;
			if (pending='0' and contador(21) = '1') then
				pending <= '1';
				contador <= x"000000";
			end if;
			if (inta='1') then
				pending <= '0';	
			end if;
		end if;
	end process;
	intr <= pending;
	

END Structure;