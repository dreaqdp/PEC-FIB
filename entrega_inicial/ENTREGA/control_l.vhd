LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.constants_pkg.all;

ENTITY control_l IS
    PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op		  : OUT STD_LOGIC_VECTOR(op_bits-1 DOWNTO 0);
			 f			  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          ldpc      : OUT STD_LOGIC;
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		  rb_n 		: OUT STD_LOGIC;
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTOR(in_d_bits-1 DOWNTO 0);
          immed_x2  : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC);
END control_l;



ARCHITECTURE Structure OF control_l IS

signal code_op : STD_LOGIC_VECTOR(3 downto 0);

BEGIN

	code_op <= ir(15 downto 12);
	
	with code_op select
		op <= op_mov when ctl_mov,
				op_cmp when ctl_cmp,
				op_muldiv when ctl_muldiv,
				op_branch when ctl_branch,
				op_jump when ctl_jump,
				op_arit_log when others;
				
	With code_op select
		f <= ir (5 downto 3) when ctl_arit,
			  ir (5 downto 3) when ctl_cmp,
			  ir (5 downto 3) when ctl_muldiv,
			  "00" & ir(8) when ctl_mov,
			  "00" & ir(8)  when ctl_branch,
			  ir(2 downto 0) when ctl_jump,
			  "100" when others; -- fer suma per loads/ stores i suma addi
	with ir select
		ldpc <= '0' when x"FFFF", --ldpc es posa a 0 quan "halt"
				  '1' when others;
	
	-- permis escriptura
	wrd <= '0' when code_op = ctl_st else
			 '0' when code_op = ctl_stB else
			 '0' when code_op = ctl_halt else
			 '0' when code_op = ctl_branch else
			 '0' when (code_op = ctl_jump and ir(2 downto 0) < "100" ) else -- si es jz, jnz, jmp
			 '1';
				 
	with code_op select
		addr_a <= ir (11 downto 9) when ctl_mov,
					 ir (8 downto 6) when others;
	
	with code_op select
		addr_b <= ir(2 downto 0) when ctl_arit,
					 ir(2 downto 0) when ctl_cmp,
					 ir(2 downto 0) when ctl_muldiv,
					 ir(11 downto 9) when others;
	addr_d <= ir(11 downto 9);
	
	with code_op select -- escriptura a mem
		wr_m <= '1' when ctl_st,
				  '1' when ctl_stB,
				  '0' when others;
	
	with code_op select  -- guardar valor al regfile: alu, mem o pcCurrent
		in_d <= "01" when ctl_ld,
				  "01" when ctl_ldB,
				  "10" when ctl_jump,
				  "00" when others;
	
	with code_op select -- 0 passar immed a la alu, 1 passar reg b
		rb_n <= '1' when ctl_arit,
				'1' when ctl_cmp,
				'1' when ctl_muldiv,
				'1' when ctl_branch,
				'1' when ctl_jump,
				'0' when others;
	with code_op select
		immed <= (6=>ir(6), 5=>ir(5), 4=>ir(4), 3=>ir(3), 2=>ir(2), 1=>ir(1), 0=>ir(0), others=>ir(7)) when ctl_mov,
					(6=>ir(6), 5=>ir(5), 4=>ir(4), 3=>ir(3), 2=>ir(2), 1=>ir(1), 0=>ir(0), others=>ir(7)) when ctl_branch,
					(4=>ir(4), 3=>ir(3), 2=>ir(2), 1=>ir(1), 0=>ir(0), others=>ir(5)) when others; -- extensio de signe

	
	with code_op select
		immed_x2 <= '1' when ctl_ld,
                  '1' when ctl_st,
						'1' when ctl_branch,
					   '0' when others;
	with code_op select
		word_byte <= '1' when ctl_ldB,
						 '1' when ctl_stB,
						 '0' when others;

END Structure;