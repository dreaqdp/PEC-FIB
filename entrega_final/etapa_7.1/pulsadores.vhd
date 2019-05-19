LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE work.constants_pkg.all;

ENTITY pulsadores IS
    PORT (clk    : IN  STD_LOGIC;
			 boot   : IN STD_LOGIC; 
			 inta   : IN STD_LOGIC; 
			 keys   : IN STD_LOGIC_VECTOR(3 DOWNTO 0); 
			 intr   : OUT STD_LOGIC;
			 read_key : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
			 );
END pulsadores;


ARCHITECTURE Structure OF pulsadores IS

signal mem_val : std_logic_vector(3 downto 0);
signal pending : std_logic := '0'; --Hi ha una petició en curs (no hi ha resposta del proc)
	 
BEGIN

	process (clk, mem_val, keys, pending, inta)
	begin
		if rising_edge(clk) then
			if boot='1' then
				mem_val <= keys;
				pending <= '0';
			else
				if (pending='0' and (mem_val /= keys)) then
					intr <= '1';
					mem_val <= keys;
					read_key <= keys;
					pending <= '1';
				end if;
				if(inta='1') then
					pending <= '0';
					intr <= '0';
				end if;
			end if;
		end if;
	end process;

END Structure;