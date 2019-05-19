LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER
USE work.constants_pkg.all;

ENTITY shifter IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 logic : IN STD_LOGIC;
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END shifter;


ARCHITECTURE Structure OF shifter IS
	--signal unsig_x, unsig_y : unsigned 
	
	signal aux_y: std_logic_vector(4 downto 0);
	
BEGIN
	aux_y <= y(4 downto 0);
	w <= to_stdlogicvector(to_bitvector(x) sll to_integer(signed(aux_y))) when ((logic = '1') or (aux_y(4)='0')) else
	     to_stdlogicvector(to_bitvector(x) sla to_integer(signed(aux_y)));

END Structure;