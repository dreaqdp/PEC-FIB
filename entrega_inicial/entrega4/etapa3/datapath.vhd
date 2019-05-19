LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
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
			 in_d    	 : IN  STD_LOGIC;
			 addr_m  	 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 data_wr     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
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

signal bus_w, bus_a, bus_in_reg, bus_immed, bus_b, bus_y : std_LOGIC_VECTOR (15 downto 0);

BEGIN
	with in_d select
		bus_in_reg <= bus_w when '0', -- alu
						  datard_m when others; -- valor memoria (store)
	with immed_x2 select
		bus_immed <= immed when '0', -- no instr mem
						 immed(14 downto 0)&'0' when others; -- load/store 
	with ins_dad select
		addr_m <= pc when '0',
					 bus_w when others;
		
						
	
	reg0: regfile port map (clk => clk, 
									wrd => wrd, 
									d => bus_in_reg, 
									addr_a => addr_a,
									addr_b => addr_b,
									addr_d => addr_d,
									a => bus_a,
									b => bus_b);
	with rb_n select
		bus_y <= bus_immed when '0',
				 bus_b when others;
	
	alu0: alu port map (x => bus_a, y => bus_y, op => op, f => f, w => bus_w); -- z no inclosa
	data_wr <= bus_b;

END Structure;




