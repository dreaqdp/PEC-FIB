LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY control_l IS
    PORT (ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op     : OUT STD_LOGIC;
          ldpc   : OUT STD_LOGIC;
          wrd    : OUT STD_LOGIC;
          addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END control_l;


ARCHITECTURE Structure OF control_l IS
BEGIN
	op <= ir(8);
	with ir select
		ldpc <= '1' when x"FFFF",
				  '0' when others;
	with ir(15 downto 12) select
		wrd <= '1' when "0101",
				 '0' when others;
	--with ir(8) select
	addr_a <= ir(11 downto 9);
	addr_d <= ir(11 downto 9);
	immed <= ir(8 downto 0);
				
	

END Structure;