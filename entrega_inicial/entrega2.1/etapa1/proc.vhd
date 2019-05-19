LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY proc IS
    PORT (boot     : IN  STD_LOGIC;
          clk      : IN  STD_LOGIC;
          datard_m : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_m   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END proc;


ARCHITECTURE Structure OF proc IS

COMPONENT unidad_control IS
    PORT (boot   : IN  STD_LOGIC;
          clk    : IN  STD_LOGIC;
          ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op     : OUT STD_LOGIC;
          wrd    : OUT STD_LOGIC;
          addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END COMPONENT;

COMPONENT datapath IS
    PORT (clk    : IN STD_LOGIC;
          op     : IN STD_LOGIC;
          wrd    : IN STD_LOGIC;
          addr_a : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  : IN STD_LOGIC_VECTOR(15 DOWNTO 0));
END COMPONENT;

signal sig_op,sig_wrd : STD_LOGIC;
signal sig_addr_a, sig_addr_d : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal sig_immed,sig_pc  : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN

	uc: unidad_control port map(boot=>boot, clk=>clk, ir=>datard_m, op=>sig_op, wrd=>sig_wrd,
										 addr_a=>sig_addr_a, addr_d=>sig_addr_d, immed=>sig_immed, pc=>addr_m);
										 
	dp: datapath port map (clk=>clk, op=>sig_op, wrd=>sig_wrd, addr_a=>sig_addr_a, addr_d=>sig_addr_d, immed=>sig_immed);
										
	 
END Structure;