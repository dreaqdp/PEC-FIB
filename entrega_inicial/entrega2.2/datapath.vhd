LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY datapath IS
    PORT (clk    		 : IN STD_LOGIC;
          op     		 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
          wrd    		 : IN STD_LOGIC;
          addr_a		 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_b		 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d		 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
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
          op : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
          w  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END component;

signal sig_w, sig_ax, sig_in_reg, sig_immed : std_LOGIC_VECTOR (15 downto 0);

BEGIN
	with in_d select
		sig_in_reg <= sig_w when '0', -- alu
						  datard_m when others; -- valor memoria (store)
	with immed_x2 select
		sig_immed <= immed when '0', -- no instr mem
						 immed(14 downto 0)&'0' when others; -- load/store 
	with ins_dad select
		addr_m <= pc when '0',
					 sig_w when others;
		
						
	
	reg0: regfile port map (clk => clk, 
									wrd => wrd, 
									d => sig_in_reg, 
									addr_a => addr_a,
									addr_b => addr_b,
									addr_d => addr_d,
									a => sig_ax,
									b => data_wr);
	
	alu0: alu port map (x => sig_ax, y => sig_immed, op => op, w => sig_w);


END Structure;




