LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER
--USE ieee.std_logic_arith.all;
USE work.constants_pkg.all;

ENTITY alu IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op : IN STD_LOGIC_VECTOR(op_bits-1 DOWNTO 0);
			 f	 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 z  : OUT STD_LOGIC;
			 div_zero : OUT STD_LOGIC);
END alu;


ARCHITECTURE Structure OF alu IS
component shifter IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 logic : IN STD_LOGIC;
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END component;

component muldiv IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 f	 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END component;

signal result_calc, result_mov, result_cmp, result_muldiv, shift_bus, w_bus, aluout_seq : std_LOGIC_VECTOR(15 downto 0);
signal eval_cmp: boolean;
BEGIN
   shift: shifter port map (x => x, y => y, logic => f(0), w => shift_bus);
	with f select 
	result_calc <= x and y when "000",
						x or  y when "001",
						x xor y when "010",
						not x   when "011",
						std_logic_vector(unsigned(x) - unsigned(y)) when "101",
						shift_bus when "110",
						shift_bus when "111",
						std_logic_vector(unsigned(x) + unsigned(y)) when others; -- suma per add, addi, stores, loads 
						
	with f select
	eval_cmp <=  signed(x) < signed(y) when "000",
						signed(x) <= signed(y) when "001",
						x = y  when "011",
						x < y when "100",
						x <= y when others;
	result_cmp <= x"0001" when eval_cmp else
					  zero_16;
	with f select
	result_mov <= y when "000",
					  y(7 downto 0) & x(7 downto 0) when others;
	
	
	mul_div: muldiv port map (x => x, y => y, f => f, w => result_muldiv);
	
	aluout_seq <= y when (op = op_branch or (op = op_jump and f <= "010")) else -- en cas de bz, bnz o jz, jnz
					  x;  -- agafar ra
					  
	with op select
		w_bus <= result_calc when op_arit_log,
			  result_cmp when op_cmp,
			  result_muldiv when op_muldiv,
			  aluout_seq when op_branch, --bz bnz
			  aluout_seq when op_jump, --jz jnz
			  result_mov when others;
	w <= w_bus;
	z <= '1' when w_bus = zero_16 else
		  '0';
	div_zero <= '1' when y = zero_16 and op = op_muldiv and f(2) = '1' else
					'0';

END Structure;