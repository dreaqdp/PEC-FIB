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
  		    rb_n 	  : OUT STD_LOGIC;
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTOR(in_d_bits-1 DOWNTO 0);
          immed_x2  : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
			 is_rds    : OUT STD_LOGIC;
			 is_wrs    : OUT STD_LOGIC;
			 is_ei     : OUT STD_LOGIC;
			 is_di     : OUT STD_LOGIC;
			 is_reti   : OUT STD_LOGIC;
			 is_getiid : OUT STD_LOGIC;
			 inval_instr : OUT STD_LOGIC;
			 is_calls  : OUT STD_LOGIC;
			 is_mode_sys : IN STD_LOGIC;
			 instr_prot : OUT STD_LOGIC
			 );
END control_l;



ARCHITECTURE Structure OF control_l IS

signal code_op : STD_LOGIC_VECTOR(3 downto 0);
signal extensio_signe: std_logic_vector(9 downto 0); -- l'aprofitarem tant per extendre 8 o 10 bits per l'immed
signal is_special : STD_LOGIC := '0';
signal bus_is_reti, bus_is_rds, bus_is_wrs, bus_is_ei, bus_is_di, bus_is_getiid : std_LOGIC;
signal bus_f : STD_LOGIC_VECTOR(2 downto 0);
signal bus_inval_instr, bus_wrd, bus_wr_m, bus_is_calls : STD_LOGIC;

BEGIN

	code_op <= ir(15 downto 12);
	
	with code_op select
		op <= op_mov when ctl_mov,
				op_cmp when ctl_cmp,
				op_muldiv when ctl_muldiv,
				op_branch when ctl_branch,
				op_jump when ctl_jump,
				op_io when ctl_io,
				op_arit_log when others;
				
	instr_prot <= '1' when is_mode_sys='0' and (bus_is_rds='1' or bus_is_wrs='1' or bus_is_reti='1' or bus_is_getiid='1' or bus_is_ei='1' or bus_is_di='1')
						else '0';
		
	bus_inval_instr <= '1' when (is_mode_sys='1' and bus_is_calls='1') or
									(code_op=ctl_cmp and (bus_f="010" or bus_f="110" or bus_f="111")) or
									(code_op=ctl_muldiv and (bus_f="011" or bus_f="110" or bus_f="111")) or
									(code_op = ctl_float) or
									(code_op = ctl_jump and (bus_f="010" or (ir(5 downto 0)>"000100" and ir(5 downto 0) < "000111"))) or
									(code_op = ctl_ldf or code_op = ctl_stf) or 
									(is_special = '1' and ir(5 downto 0) /= sp_halt and (
																		ir(5)='0' or
																		((ir(0)='1' or ir(1)='1') and ir(5 downto 0)/=sp_di)
																		or (ir(5 downto 0) > sp_wrs)
																	))
									else '0';
	inval_instr <= bus_inval_instr;
	
	is_special <= '1' when code_op=ctl_halt else '0';
	
	bus_is_rds  <= '1' when is_special = '1' and ir(5 downto 0) = sp_rds  else '0';
	is_rds <= bus_is_rds or bus_is_reti; -- RETI i hem de llegir del SBR
	bus_is_wrs  <= '1' when is_special = '1' and ir(5 downto 0) = sp_wrs  else '0';
	bus_is_ei   <= '1' when is_special = '1' and ir(5 downto 0) = sp_ei   else '0';
	bus_is_di   <= '1' when is_special = '1' and ir(5 downto 0) = sp_di   else '0';
	bus_is_reti <= '1' when is_special = '1' and ir(5 downto 0) = sp_reti else '0';
	bus_is_getiid <= '1' when is_special = '1' and ir(5 downto 0) = sp_getiid else '0';
	
	is_wrs <= bus_is_wrs;
	is_ei <= bus_is_ei;
	is_di <= bus_is_di;
	is_reti <= bus_is_reti;
	is_getiid <= bus_is_getiid;
	
	bus_is_calls <= '1' when code_op = ctl_jump and ir (5 downto 0) = "000111" else
					    '0';
	is_calls <= bus_is_calls;
	
	With code_op select
		bus_f <= ir (5 downto 3) when ctl_arit,
			  ir (5 downto 3) when ctl_cmp,
			  ir (5 downto 3) when ctl_muldiv,
			  "00" & ir(8) when ctl_mov,
			  "00" & ir(8)  when ctl_branch,
			  "00" & ir(8)  when ctl_io, -- per a diferenciar input o output, cap utilitat per la alu
			  ir(2 downto 0) when ctl_jump,
			  "100"  when ctl_halt, -- PER LES DE SBR, fem un addi amb 0 # per RETI posar a s7 <- s0
			  "100" when others; -- fer suma per loads/ stores i suma addi
			  -- per getiid ens es igual la alu, utilitzem rd_io
	f <= bus_f;		  
	with ir select
		ldpc <= '0' when x"FFFF", --ldpc es posa a 0 quan "halt"
				  '1' when others;
	
	bus_wrd <= '1' when code_op = ctl_arit else
			 '1' when code_op = ctl_cmp else
			 '1' when code_op = ctl_addi else
			 '1' when code_op = ctl_ld else
			 '1' when code_op = ctl_mov else
			 '1' when code_op = ctl_io and ir(8) = '0' else
			 '1' when code_op = ctl_muldiv else
			 '1' when code_op = ctl_jump and ir(2 downto 0) = "100" else
			 '1' when code_op = ctl_ldB else
			 '1' when code_op = ctl_halt and (ir(4 downto 0) < "10101") else
			 '0';
	wrd <= bus_wrd and (not bus_inval_instr); 			 

	addr_a <= ir (11 downto 9) when code_op = ctl_mov else
				 "001" when bus_is_reti = '1' else -- RETI ha de llegir s1
				 ir (8 downto 6);
				 
	with code_op select
		addr_b <= ir(2 downto 0) when ctl_arit,
					 ir(2 downto 0) when ctl_cmp,
					 ir(2 downto 0) when ctl_muldiv,
					 ir(11 downto 9) when others;
	addr_d <=  ir(11 downto 9);--"111" when code_op = ctl_halt and bus_is_reti = '1' else -- RETI ha de guardar a s7
				
	
	with code_op select -- escriptura a mem
		bus_wr_m <= '1' when ctl_st,
				  '1' when ctl_stB,
				  '0' when others;			  
	wr_m <= bus_wr_m and (not bus_inval_instr);
	
	with code_op select  -- que guardar valor al regfile: alu, mem o pcCurrent
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
				
	extensio_signe <= (others => ir(7)) when (code_op = ctl_mov or code_op = ctl_branch) else
							(others => ir(5));
	with code_op select
		immed <= extensio_signe(7 downto 0) & ir(7 downto 0) when ctl_mov,
					extensio_signe(7 downto 0) & ir(7 downto 0) when ctl_branch,
					extensio_signe(7 downto 0) & ir(7 downto 0) when ctl_io,
					zero_16 when ctl_halt, --per fer una addi 0 amb les instruccions de SBR #, per les RETI tambe
					extensio_signe& ir(5 downto 0) when others; -- extensio de signe

	
	with code_op select
		immed_x2 <= '1' when ctl_ld,
                  '1' when ctl_st,
						'1' when ctl_branch,
					   '0' when others;
	--DECISIO: per defecte no es un word_byte, aixi al proc podem detectar la excepcio de mem alineada estant segurs de que si es un acces a word s'esta fent un load/store.
	with code_op select
		word_byte <= '0' when ctl_ld,
						 '0' when ctl_st,
						 '1' when others;
	
	

END Structure;