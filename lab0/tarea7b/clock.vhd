LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
ENTITY clock IS
 GENERIC (N : integer);
 PORT( CLOCK_50 : IN std_logic;
 contador : in std_logic_vector (N-1 downto 0);
 clk : out std_logic);
END clock;

ARCHITECTURE Structure OF clock IS

signal half_count : std_logic_vector (N-2 downto 0) := contador(N-1 downto 1);
signal clk_s : std_logic := '0';
BEGIN
	process (CLOCK_50)
	begin
		if rising_edge(CLOCK_50) then 
			if half_count = (N-1 => '0') then 
				half_count <= contador (N-1 downto 1);
				clk_s <= not clk_s;
			else half_count <= half_count - 1;
			end if;
		end if;
	end process;
	clk <= clk_s;
END Structure; 