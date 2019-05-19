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
-- dividim el contador entre 2, fem shift left traient-li el bit de menys pes
-- fem aquesta divisio perque volem calcular el canvi de flanc, que ocorre cada mig periode (sent el periode el valor del parametre d'entrada contador)
signal half_count : std_logic_vector (N-2 downto 0) := (others=>'0');--contador(N-1 downto 1);
signal clk_s : std_logic := '0';
BEGIN
	
	process (CLOCK_50)
	begin
		if rising_edge(CLOCK_50) then 
			if half_count = (contador(N-1 downto 1)) then 
				half_count <= (others=>'0'); -- reiniciar contador quan s'arriba a 0
				clk_s <= not clk_s; -- canvi de flanc
			else half_count <= half_count + 1;
			end if;
		end if;
	end process;

	clk <= clk_s;
END Structure; 