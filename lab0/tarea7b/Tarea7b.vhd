LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
ENTITY Tarea7b IS
 PORT( CLOCK_50 : IN std_logic;
 KEY : IN std_logic_vector (0 downto 0);
 HEX0 : OUT std_logic_vector(6 downto 0);
 HEX1 : OUT std_logic_vector(6 downto 0);
 HEX2 : OUT std_logic_vector(6 downto 0);
 HEX3 : OUT std_logic_vector(6 downto 0));
END Tarea7b;

ARCHITECTURE Structure OF Tarea7b IS

component clock IS
 GENERIC (N : integer);
 PORT( CLOCK_50 : IN std_logic;
 contador : in std_logic_vector (N-1 downto 0);
 clk : out std_logic);
END component;

component driver4display IS
 PORT( number : IN std_logic_vector (15 downto 0);
 HEX0 : OUT std_logic_vector(6 downto 0);
 HEX1 : OUT std_logic_vector(6 downto 0);
 HEX2 : OUT std_logic_vector(6 downto 0);
 HEX3 : OUT std_logic_vector(6 downto 0));
END component;
signal clk : std_logic;
signal num : std_logic_vector (15 downto 0);

BEGIN
	process (clk) 
	begin
		if rising_edge(clk) then num <= num + 1;
		end if;
	end process;
	
	c: clock
		generic map (25)
		port map (CLOCK_50 => CLOCK_50, contador => std_logic_vector(to_unsigned(25000000, 25)), clk => clk);
	d: driver4display port map (num, HEX0, HEX1, HEX2, HEX3);
	--num <= "0000000000000000";
	-- when KEY(0)='0' else num;
	
END Structure; 