LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.constants_pkg.all;

ENTITY control_l IS
    PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          ldpc      : OUT STD_LOGIC;
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC;
          immed_x2  : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC);
END control_l;



ARCHITECTURE Structure OF control_l IS

signal code_op : STD_LOGIC_VECTOR(3 downto 0);

BEGIN

	code_op <= ir(15 downto 12);
	
	with code_op select
		op <= '0'&ir(8) when ctl_mov,
				"10" when others;
	
	with ir select
		ldpc <= '0' when x"FFFF", --ldpc es posa a 0 quan "halt"
				  '1' when others;
	
	with code_op select
		wrd <= '1' when ctl_mov,
			   '1' when ctl_ld,
			   '1' when ctl_ldb,
			   '0' when others;
	
	with code_op select
		addr_a <= ir (11 downto 9) when ctl_mov,
					 ir (8 downto 6) when others;
	addr_b <= ir(11 downto 9);
	addr_d <= ir(11 downto 9);
	
	with code_op select
		wr_m <= '1' when ctl_st,
				  '1' when ctl_stB,
				  '0' when others;
	
	with code_op select
		in_d <= '1' when ctl_ld,
				  '1' when ctl_ldB,
				  '0' when others;
	
	with code_op select					
		immed <= (6=>ir(6), 5=>ir(5), 4=>ir(4), 3=>ir(3), 2=>ir(2), 1=>ir(1), 0=>ir(0), others=>ir(7)) when ctl_mov,
					(4=>ir(4), 3=>ir(3), 2=>ir(2), 1=>ir(1), 0=>ir(0), others=>ir(5)) when others;

	
	with code_op select
		immed_x2 <= '1' when ctl_ld,
                    '1' when ctl_st,
					'0' when others;
	with code_op select
		word_byte <= '1' when ctl_ldB,
						 '1' when ctl_stB,
						 '0' when others;				
	

END Structure;