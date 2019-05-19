LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.constants_pkg.all;

ENTITY proc IS
    PORT (boot     : IN  STD_LOGIC;
          clk      : IN  STD_LOGIC;
          datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 rd_io	 : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 intr 	 : IN STD_LOGIC;
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_m     : OUT STD_LOGIC;
			 word_byte: OUT STD_LOGIC;
			 wr_io	 : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			 addr_io  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			 rd_in 	 : OUT STD_LOGIC;
			 wr_out   : OUT STD_LOGIC;
			 inta 	 : OUT STD_LOGIC
			 );
END proc;


ARCHITECTURE Structure OF proc IS

COMPONENT unidad_control IS
    PORT (boot      : IN  STD_LOGIC;
          clk       : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 tknbr	  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			 pc_alu	  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 int_en    : IN STD_LOGIC;
			 intr 	  : IN STD_LOGIC;
          op        : OUT STD_LOGIC_VECTOR(op_bits-1 DOWNTO 0);
			 f			  : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		    rb_n 		: OUT STD_LOGIC;
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          ins_dad   : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC_VECTOR(in_d_bits-1 DOWNTO 0);
          immed_x2  : OUT STD_LOGIC;
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC;
			 addr_io   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
			 rd_in	  : OUT STD_LOGIC;
			 wr_out	  : OUT STD_LOGIC;
			 is_rds    : OUT STD_LOGIC;
			 is_wrs    : OUT STD_LOGIC;
			 is_ei     : OUT STD_LOGIC;
			 is_di     : OUT STD_LOGIC;
			 is_reti   : OUT STD_LOGIC;
			 PC_up     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 is_system : OUT STD_LOGIC;
			 is_getiid : OUT STD_LOGIC
			 );
END COMPONENT;

COMPONENT datapath IS
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
			 int_en 		 : OUT STD_LOGIC
			 );
END COMPONENT;

signal bus_wrd, bus_ins_dad, bus_immed_x2, bus_rb_n : STD_LOGIC;
signal bus_op : STD_LOGIC_VECTOR(op_bits - 1 DOWNTO 0);
signal bus_in_d : std_logic_vector (in_d_bits-1 downto 0);
signal bus_tknbr : std_logic_vector (1 downto 0);
signal bus_addr_a, bus_addr_b, bus_addr_d, bus_f : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal bus_immed, bus_pc, bus_pc_alu, bus_pc_up  : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal bus_is_rds, bus_is_wrs, bus_is_ei, bus_is_di, bus_is_reti, bus_int_en, bus_is_system, bus_is_getiid : STD_LOGIC;


BEGIN

	inta <= bus_is_getiid;
	uc: unidad_control port map(boot=> boot,
										 clk=> clk,
										 datard_m => datard_m, 
										 tknbr => bus_tknbr,
										 pc_alu => bus_pc_alu,
										 int_en => bus_int_en,
										 intr => intr,
										 op=> bus_op, 
										 f => bus_f,
										 wrd=> bus_wrd,
										 addr_a=> bus_addr_a,
										 addr_b=> bus_addr_b,
										 addr_d=> bus_addr_d,
										 rb_n => bus_rb_n,
										 immed=> bus_immed,
										 pc=> bus_pc,
										 ins_dad => bus_ins_dad,
										 in_d => bus_in_d,
										 immed_x2 => bus_immed_x2,
										 wr_m => wr_m,
										 word_byte => word_byte,
										 addr_io => addr_io,
										 rd_in => rd_in,
										 wr_out => wr_out,
										 is_rds => bus_is_rds,
										 is_wrs => bus_is_wrs,
										 is_ei => bus_is_ei,
										 is_di => bus_is_di,
										 is_reti => bus_is_reti,
										 pc_up => bus_pc_up,
										 is_system => bus_is_system,
										 is_getiid => bus_is_getiid
										 );					
										 
	dp: datapath port map (clk=> clk,
								  op=> bus_op, 
								  f => bus_f, 
								  wrd=> bus_wrd, 
								  addr_a=> bus_addr_a,
								  addr_b=> bus_addr_b, 
								  addr_d=> bus_addr_d, 
								  rb_n => bus_rb_n,
								  immed=> bus_immed,
								  immed_x2=> bus_immed_x2,
								  datard_m=> datard_m,
								  ins_dad=> bus_ins_dad,
								  pc=> bus_pc,
								  in_d=> bus_in_d, 
								  rd_io => rd_io,
								  is_rds => bus_is_rds,
								  is_wrs => bus_is_wrs,
								  is_ei => bus_is_ei,
								  is_di => bus_is_di,
								  is_reti => bus_is_reti,
								  tknbr => bus_tknbr,
								  pc_alu => bus_pc_alu,
								  addr_m=>addr_m,
								  data_wr=>data_wr,
								  wr_io => wr_io,
								  pc_up => bus_pc_up,
								  boot => boot,
								  int_en => bus_int_en,
								  is_system => bus_is_system,
								  is_getiid => bus_is_getiid
								  );					  								
	 
END Structure;





