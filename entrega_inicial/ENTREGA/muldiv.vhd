LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_signed.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER
USE work.constants_pkg.all;

ENTITY muldiv IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 f	 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END muldiv;


ARCHITECTURE Structure OF muldiv IS
	--signal unsig_x, unsig_y : unsigned 
	signal bus_mul_s : signed(31 downto 0);
	signal bus_mul_u : unsigned(31 downto 0);
BEGIN
bus_mul_s <= signed(x)*signed(y);
bus_mul_u <= unsigned(x)*unsigned(y);
	with f select
	w <= std_logic_vector(bus_mul_u(15 downto 0)) when "000",
						  std_logic_vector(bus_mul_s(31 downto 16)) when "001",
						  std_logic_vector(bus_mul_u(31 downto 16)) when "010",
						  std_logic_vector(signed(x)/signed(y)) when "100",
						  std_logic_vector(unsigned(x)/unsigned(y)) when others; -- de moment ignorem el overflow
END Structure;