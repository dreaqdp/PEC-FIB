LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER

ENTITY regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END regfile;


ARCHITECTURE Structure OF regfile IS
    signal regs: std_LOGIC_VECTOR (127 downto 0);
	 
BEGIN
	process (clk)

	begin
		if rising_edge(clk) then
			if wrd='1' then regs (to_INTEGER(unsigned(addr_d & "1111")) downto (to_INTEGER(unsigned(addr_d & "0000")))) <= d;
			else a <= regs(to_INTEGER(unsigned(addr_a & "1111")) downto (to_INTEGER(unsigned(addr_a & "0000"))));
			end if;
		end if;
	end process;
	
    -- Aqui iria la definicion del comportamiento del banco de registros
    -- Os puede ser util usar la funcion "conv_integer" o "to_integer"
    -- Una buena (y limpia) implementacion no deberia ocupar de 7 o 8 lineas

END Structure;