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
			 tknbr		 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			 pc_alu		 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 addr_m  	 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 data_wr     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_io		 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
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
			 b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END component;

component alu IS
    PORT (x  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          y  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op : IN STD_LOGIC_VECTOR(op_bits-1 DOWNTO 0);
			 f	 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 z  : OUT STD_LOGIC);
END component;

signal bus_w, bus_a, bus_alu_mem, bus_d, pc_2, bus_immed, bus_b, bus_y : std_LOGIC_VECTOR (15 downto 0);
signal bus_z : std_logic;

BEGIN
	with in_d select -- possibilitat de que guardar a reg:
		bus_alu_mem <= bus_w when "00", -- alu
						  datard_m when others; -- valor memoria (load)
	with immed_x2 select
		bus_immed <= immed when '0', -- no instr mem
						 immed(14 downto 0)&'0' when others; -- load/store 
	with ins_dad select
		addr_m <= pc when '0',
					 bus_w when others;
	pc_2 <= pc + 2;
	-- seleccionar que guardem, finalment, al banc de registres
	with op select
		bus_d <= pc_2 when op_jump, -- jal o call
					rd_io when op_io, -- in de periferics
					bus_alu_mem when others; -- alu o load
						
	
	reg0: regfile port map (clk => clk, 
									wrd => wrd, 
									d => bus_d, 
									addr_a => addr_a,
									addr_b => addr_b,
									addr_d => addr_d,
									a => bus_a,
									b => bus_b);
	with rb_n select
		bus_y <= bus_immed when '0',
				 bus_b when others;
	alu0: alu port map (x => bus_a, y => bus_y, op => op, f => f, w => bus_w, z => bus_z);
	tknbr <= "01" when (op = op_branch and ((f(0) xor bus_z) = '1')) else -- el bit de menor pes en cas de bz es '0' i en el cas de bnz es '1'
				"10" when (op = op_jump and (((f(0) xor bus_z) = '1') or f >= "100")) else -- igual ^ per jz i jnz, sempre haura de saltar per jmp, jal i call
				"00"; -- implicit
				-- falta 11, pel futur
	data_wr <= bus_b;
	PC_alu <= bus_a;
	wr_io <= bus_b;



    -- Aqui iria la declaracion del "mapeo" (PORT MAP) de los nombres de las entradas/salidas de los componentes
    -- En los esquemas de la documentacion a la instancia del banco de registros le hemos llamado reg0 y a la de la alu le hemos llamado alu0

END Structure;




