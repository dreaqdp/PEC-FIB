LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;

ENTITY unidad_control IS
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
END unidad_control;

ARCHITECTURE Structure OF unidad_control IS
component control_l IS
    PORT (ir        : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          op        : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
          ldpc      : OUT STD_LOGIC;
          wrd       : OUT STD_LOGIC;
          addr_a    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_d    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
          immed     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
          wr_m      : OUT STD_LOGIC;
          in_d      : OUT STD_LOGIC;
          immed_x2  : OUT STD_LOGIC;
          word_byte : OUT STD_LOGIC);
END component;
component multi is
	 port(clk       : IN  STD_LOGIC;
		boot      : IN  STD_LOGIC;
		ldpc_l    : IN  STD_LOGIC;
		wrd_l     : IN  STD_LOGIC;
		wr_m_l    : IN  STD_LOGIC;
		w_b       : IN  STD_LOGIC;
		ldpc      : OUT STD_LOGIC;
		wrd       : OUT STD_LOGIC;
		wr_m      : OUT STD_LOGIC;
		ldir      : OUT STD_LOGIC;
		ins_dad   : OUT STD_LOGIC;
		word_byte : OUT STD_LOGIC);
end component;

constant instr_base    : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"C000"; --instruccio per defecte
constant ir_base    : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
signal program_counter : STD_LOGIC_VECTOR(15 DOWNTO 0) := instr_base;
signal reg_ir,next_ir : STD_LOGIC_VECTOR(15 DOWNTO 0) := ir_base;
signal bus_ldpc, bus_wb, bus_wm, bus_wrd, sig_ldpc, sig_ldir: STD_LOGIC;

BEGIN

		process (clk,boot)
		begin
			if rising_edge(clk) then --es podria fer amb dos ifs separats i sobreescribint, boot>halt>implicit
				if boot = '1' then 
					program_counter <= instr_base;
				elsif sig_ldpc = '1' then -- !halt o fetch
					program_counter <= program_counter + 2; --sequenciament implicit, pc+2 ja que les instruccions son de 2 bytes 
				end if;
			end if;
		end process;
		pc <= program_counter; --actualitzar pc

		process (clk)
		begin
			if rising_edge(clk) then --es podria fer amb dos ifs separats i sobreescribint, boot>halt>implicit
				if boot = '1' then
					next_ir <= ir_base;
				elsif sig_ldir = '1' then
					next_ir <= datard_m;
				else next_ir <= reg_ir;
				end if;
			end if;
		end process;
		reg_ir <= next_ir;

		c: control_l port map(ir=>reg_ir,
									 op=>op,
									 ldpc=>bus_ldpc,
									 wrd=>bus_wrd,
									 addr_a=>addr_a,
									 addr_b => addr_b,
									 addr_d=>addr_d,
									 immed=>immed,
									 wr_m => bus_wm,
									 in_d => in_d,
									 immed_x2 => immed_x2,
									 word_byte => bus_wb); --decodificador
		m: multi port map (clk => clk, 
								 boot => boot, 
								 ldpc_l => bus_ldpc, 
								 wrd_l => bus_wrd,
								 wr_m_l => bus_wm,
								 w_b => bus_wb,
								 ldpc => sig_ldpc,
								 wrd => wrd,
								 wr_m => wr_m,
								 ldir => sig_ldir,
								 ins_dad => ins_dad,
								 word_byte => word_byte);
		
END Structure;