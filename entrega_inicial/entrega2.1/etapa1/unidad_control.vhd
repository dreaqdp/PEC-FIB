LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY unidad_control IS
    PORT (boot   : IN  STD_LOGIC;
          clk    : IN  STD_LOGIC;
          ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op     : OUT STD_LOGIC;
          wrd    : OUT STD_LOGIC;
          addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          pc     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
END unidad_control;

ARCHITECTURE Structure OF unidad_control IS

		COMPONENT control_l IS
			 PORT (ir     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
					 op     : OUT STD_LOGIC;
					 ldpc   : OUT STD_LOGIC;
					 wrd    : OUT STD_LOGIC;
					 addr_a : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
					 addr_d : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
					 immed  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0));
		END COMPONENT;

		constant instr_base    : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"C000"; --instruccio per defecte
		signal program_counter : STD_LOGIC_VECTOR(15 DOWNTO 0) := instr_base;
		signal sig_ldpc: STD_LOGIC;

BEGIN

		process (clk)
		begin
			if rising_edge(clk) then --es podria fer amb dos ifs separats i sobreescribint, boot>halt>implicit
				if boot = '1' then 
					program_counter <= instr_base; 
				elsif sig_ldpc = '1' then --no hi ha halt
					program_counter <= program_counter + 2; --sequenciament implicit, pc+2 ja que les instruccions son de 2 bytes
				else 
					program_counter <= program_counter; --no se si es millor posar tots els casos o treure aquest
				end if;
			end if;
		end process;
		pc <= program_counter; --actualitzar pc
		c: control_l port map(ir=>ir,op=>op,ldpc=>sig_ldpc,wrd=>wrd,addr_a=>addr_a,addr_d=>addr_d,immed=>immed); --decodificador

END Structure;