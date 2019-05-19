LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY proc IS
    PORT (boot     : IN  STD_LOGIC;
          clk      : IN  STD_LOGIC;
          datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 data_wr  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 wr_m     : OUT STD_LOGIC;
			 word_byte: OUT STD_LOGIC
			 );
END proc;


ARCHITECTURE Structure OF proc IS

COMPONENT unidad_control IS
    PORT (boot      : IN  STD_LOGIC;
          clk       : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          ins_dad   : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC;
          immed_x2  : OUT STD_LOGIC;
          wr_m      : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC);
END COMPONENT;

COMPONENT datapath IS
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
END COMPONENT;

signal bus_wrd, bus_ins_dad, bus_in_d, bus_immed_x2 : STD_LOGIC;
signal bus_op : STD_LOGIC_VECTOR(1 DOWNTO 0);
signal bus_addr_a, bus_addr_b, bus_addr_d : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal bus_immed,bus_pc  : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

	ucontrol: unidad_control port map(boot=> boot,
										 clk=> clk,
										 datard_m => datard_m, 
										 op=> bus_op, 
										 wrd=> bus_wrd,
										 addr_a=> bus_addr_a,
										 addr_b=> bus_addr_b,
										 addr_d=> bus_addr_d, 
										 immed=> bus_immed,
										 pc=> bus_pc,
										 ins_dad => bus_ins_dad,
										 in_d => bus_in_d,
										 immed_x2 => bus_immed_x2,
										 wr_m => wr_m,
										 word_byte => word_byte								 
										 );
										
										 
	datapath0: datapath port map (clk=> clk,
								  op=> bus_op, 
								  wrd=> bus_wrd, 
								  addr_a=> bus_addr_a,
								  addr_b=> bus_addr_b, 
								  addr_d=> bus_addr_d, 
								  immed=> bus_immed,
								  immed_x2=> bus_immed_x2,
								  datard_m=> datard_m,
								  ins_dad=> bus_ins_dad,
								  pc=> bus_pc,
								  in_d=> bus_in_d,
								  addr_m=>addr_m,
								  data_wr=>data_wr
								  );
								  								
	 
END Structure;





