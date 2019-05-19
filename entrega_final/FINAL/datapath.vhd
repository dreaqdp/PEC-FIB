LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE work.constants_pkg.all;

ENTITY datapath IS
    PORT (clk    		 : IN STD_LOGIC;
          op		    : IN STD_LOGIC_VECTOR(op_bits-1 DOWNTO 0);
			 f			    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          wrd    		 : IN STD_LOGIC;
          addr_a		 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b		 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d		 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		    rb_n			 : IN STD_LOGIC;
          immed  		 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 immed_x2    : IN  STD_LOGIC; 
			 datard_m    : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 ins_dad     : IN  STD_LOGIC;
			 pc     		 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 in_d    	 : IN  STD_LOGIC_VECTOR(in_d_bits-1 DOWNTO 0);
			 rd_io		 : IN  STD_LOGIC_VECTOR(15 downto 0);
			 is_rds      : IN STD_LOGIC;
			 is_wrs      : IN STD_LOGIC;
			 is_ei       : IN STD_LOGIC;
			 is_di       : IN STD_LOGIC;
			 is_reti     : IN STD_LOGIC;
			 PC_up       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 boot 		 : IN STD_LOGIC;
			 is_system   : IN STD_LOGIC;			 
			 is_getiid   : IN STD_LOGIC;
			 tknbr		 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 pc_alu		 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 addr_m  	 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 data_wr     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_io		 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 int_en 		 : OUT STD_LOGIC;
			 div_zero    : OUT STD_LOGIC;
			 exception	 : IN STD_LOGIC;
			 exception_code : IN STD_LOGIC_VECTOR(exception_bits-1 downto 0);
			 is_mode_sys : out std_logic	 
			 );
END datapath;


ARCHITECTURE Structure OF datapath IS

component regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 is_rds : IN STD_LOGIC; 
			 is_wrs : IN STD_LOGIC; 
			 boot   : IN STD_LOGIC;  
			 is_ei  : IN STD_LOGIC;
			 is_di  : IN STD_LOGIC;
			 is_reti: IN STD_LOGIC;	 
			 int_en : OUT STD_LOGIC;
			 exception : IN STD_LOGIC;
			 exception_code : IN STD_LOGIC_VECTOR(exception_bits-1 downto 0);
			 is_system : IN STD_LOGIC;
			 addr_m    : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 is_mode_sys : out std_logic
			 );
END component;

component alu IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op : IN STD_LOGIC_VECTOR(op_bits-1 DOWNTO 0);
			 f	 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 z  : OUT STD_LOGIC;
			 div_zero : OUT STD_LOGIC);
END component;

signal bus_w, bus_a, bus_alu_mem, bus_d_op, bus_d, pc_2, bus_immed, bus_b, bus_y, bus_addr_m : std_LOGIC_VECTOR (15 downto 0);
signal bus_addr_a : std_logic_vector (2 downto 0);
signal bus_z : std_logic;

BEGIN
	with in_d select -- possibilitat de que guardar a reg:
		bus_alu_mem <= bus_w when "00", -- alu
						  datard_m when others; -- valor memoria (load)
	with immed_x2 select
		bus_immed <= immed when '0', -- no instr mem
						 immed(14 downto 0)&'0' when others; -- load/store 
	with ins_dad select
		bus_addr_m <= pc when '0',
					 bus_w when others;
	pc_2 <= pc + 2;
	-- seleccionar que guardem, finalment, al banc de registres

	bus_d_op <= pc_2 when op=op_jump else -- jal o call
					rd_io when op=op_io or is_getiid='1' else-- in de periferics o llegir id (getiid)
					bus_alu_mem; -- alu o load
	with is_system select
		bus_d <= bus_d_op when '0',
					PC_up when others; -- per guardar PC
	with is_system select
		bus_addr_a <= addr_a when '0',
						  "101" when others; -- per llegir S5

	reg0: regfile port map (clk => clk, 
									wrd => wrd, 
									d => bus_d, 
									addr_a => bus_addr_a,
									addr_b => addr_b,
									addr_d => addr_d,
									a => bus_a,
									b => bus_b,
									is_rds => is_rds,
									is_wrs => is_wrs,
									boot => boot,
									--is_int => is_system,
									is_ei => is_ei,
									is_di => is_di,
									is_reti => is_reti,
									int_en => int_en,
									exception => exception,
									exception_code => exception_code,
									is_system => is_system,
									addr_m => bus_addr_m,
									is_mode_sys => is_mode_sys
									);
	with rb_n select
		bus_y <= bus_immed when '0',
				 bus_b when others;
	alu0: alu port map (x => bus_a, y => bus_y, op => op, f => f, w => bus_w, z => bus_z, div_zero => div_zero);
	-- 0 pc implicit, 1 pc salt relatiu, 2 pc calculat a la alu, 3 tlb
	tknbr <= "01" when (exception='0' or exception_code/=ex_inv_instr) and (op = op_branch and ((f(0) xor bus_z) = '1')) else -- el bit de menor pes en cas de bz es '0' i en el cas de bnz es '1'
				"10" when (exception='0' or exception_code/=ex_inv_instr) and ((op = op_jump and (((f(0) xor bus_z) = '1') or f >= "100")) or (is_reti = '1') or (is_system = '1')) else -- igual ^ per jz i jnz, sempre haura de saltar per jmp, jal i call # per RETI hem de guardar el valor de s1 (bus_a)
				"00"; -- implicit
				-- falta 11, pel futur
	data_wr <= bus_b;
	PC_alu <= bus_a;
	wr_io <= bus_b;
	addr_m <= bus_addr_m;

END Structure;
