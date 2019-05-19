LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE work.constants_pkg.all;

ENTITY unidad_control IS
    PORT (boot      : IN  STD_LOGIC;
          clk       : IN  STD_LOGIC;
          datard_m  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
			 tknbr	  : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
			 pc_alu	  : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
			 int_en 	  : IN STD_LOGIC;
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
			 is_getiid : OUT STD_LOGIC;
			 exception_l : IN STD_LOGIC;
			 exception : OUT STD_LOGIC;
			 exception_code : IN STD_LOGIC_VECTOR(exception_bits-1 downto 0);
			 inval_instr : OUT STD_LOGIC;
			 div_zero_l : IN STD_LOGIC;
			 div_zero : out STD_LOGIC;
			 inval_align: out STD_LOGIC
			 );
END unidad_control;

ARCHITECTURE Structure OF unidad_control IS
COMPONENT control_l IS
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
			 is_rds    :  OUT STD_LOGIC;
			 is_wrs    :  OUT STD_LOGIC;
			 is_ei     :  OUT STD_LOGIC;
			 is_di     :  OUT STD_LOGIC;
			 is_reti   :  OUT STD_LOGIC;
			 is_getiid : OUT STD_LOGIC;
			 inval_instr : OUT STD_LOGIC
			 );
END COMPONENT;

component multi is
	 port(clk       : IN  STD_LOGIC;
		boot      : IN  STD_LOGIC;
		ldpc_l    : IN  STD_LOGIC;
		wrd_l     : IN  STD_LOGIC;
		wr_m_l    : IN  STD_LOGIC;
		w_b       : IN  STD_LOGIC;
		is_rds_l  : IN STD_LOGIC;
		is_wrs_l  : IN STD_LOGIC;
		is_ei_l   : IN STD_LOGIC;
		is_di_l   : IN STD_LOGIC;
		is_reti_l : IN STD_LOGIC;
		is_getiid_l:IN STD_LOGIC;
		int_en 	 : IN STD_LOGIC;
		exception_l : IN STD_LOGIC;
		exception : OUT STD_LOGIC;
--		inval_align_l	: IN STD_LOGIC;
--		inval_align	: OUT STD_LOGIC;
		inval_instr_l	: IN STD_LOGIC;
		inval_instr	: OUT STD_LOGIC;
		div_zero_l: IN STD_LOGIC;
		div_zero  : OUT STD_LOGIC;
		ldpc      : OUT STD_LOGIC;
		wrd       : OUT STD_LOGIC;
		wr_m      : OUT STD_LOGIC;
		ldir      : OUT STD_LOGIC;
		ins_dad   : OUT STD_LOGIC;
		word_byte : OUT STD_LOGIC;
		is_rds    : OUT STD_LOGIC;
		is_wrs    : OUT STD_LOGIC;
		is_ei     : OUT STD_LOGIC;
		is_di     : OUT STD_LOGIC;
		is_reti   : OUT STD_LOGIC;
		is_system : OUT STD_LOGIC;
		is_getiid : OUT STD_LOGIC;
		exception_code : IN STD_LOGIC_VECTOR(exception_bits-1 downto 0)
		);
end component;

signal program_counter : STD_LOGIC_VECTOR(15 DOWNTO 0) := instr_base;
signal reg_ir,next_ir : STD_LOGIC_VECTOR(15 DOWNTO 0) := ir_base;
signal bus_ldpc, bus_wb, bus_wm, bus_wrd, sig_ldpc, sig_ldir: STD_LOGIC;
signal bus_immed : std_LOGIC_VECTOR (15 downto 0);
signal bus_op : STD_LOGIC_VECTOR(op_bits-1 DOWNTO 0);
signal bus_f : STD_LOGIC_VECTOR(2 DOWNTO 0);
signal bus_is_rds, bus_is_wrs, bus_is_ei, bus_is_di, bus_is_reti, bus_is_system, bus_is_getiid: STD_LOGIC;
signal bus_inval_instr, bus_inval_align : STD_LOGIC;
signal bus_is_calls : STD_LOGIC;

BEGIN
		process (clk,boot)
		variable pc_2 : std_LOGIC_VECTOR(15 downto 0);
		begin
			pc_2 := program_counter + 2;
			if rising_edge(clk) then --es podria fer amb dos ifs separats i sobreescribint, boot>halt>implicit
				if boot = '1' then 
					program_counter <= instr_base;
				elsif bus_is_system = '1' then
					program_counter <= pc_alu;
				elsif sig_ldpc = '1' then -- !halt o fetch
					case tknbr is 
						when "00" =>
							program_counter <= pc_2; --sequenciament implicit, pc+2 ja que les instruccions son de 2 bytes 
						when "01" => 
							program_counter <= pc_2 + (bus_immed(14 downto 0) & "0"); -- salts relatius
						when "10" => 
							program_counter <= pc_alu; -- salts absoluts
						when others => -- per quan fem tlb
					end case;
				end if;
			end if;
		end process;
		pc <= program_counter; --actualitzar pc
		pc_up <= program_counter;
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
		
		ctl_l: control_l port map(ir=>reg_ir,
									 op=>bus_op,
									 f =>bus_f,
									 ldpc=>bus_ldpc,
									 wrd=>bus_wrd,
									 addr_a=>addr_a,
									 addr_b => addr_b,
									 addr_d=>addr_d,
									 rb_n => rb_n,
									 immed=> bus_immed,
									 wr_m => bus_wm,
									 in_d => in_d,
									 immed_x2 => immed_x2,
									 word_byte => bus_wb,
									 is_rds => bus_is_rds,
									 is_wrs => bus_is_wrs,
									 is_ei => bus_is_ei,
									 is_di => bus_is_di,
									 is_reti => bus_is_reti,
									 is_getiid => bus_is_getiid,
									 inval_instr => bus_inval_instr
									 ); --decodificador
		immed <= bus_immed;
		addr_io <= bus_immed(7 downto 0);
		op <= bus_op;
		f  <= bus_f;
		rd_in <= '1' when (bus_op = op_io and bus_f(0) = '0') else
					'0';
		wr_out <= '1' when (bus_op = op_io and bus_f(0) = '1') else
					'0';	

	
		mult: multi port map (clk => clk, 
								 boot => boot, 
								 ldpc_l => bus_ldpc, 
								 wrd_l => bus_wrd,
								 wr_m_l => bus_wm,
								 w_b => bus_wb,
								 is_rds_l => bus_is_rds,
								 is_wrs_l => bus_is_wrs,
								 is_ei_l => bus_is_ei,
								 is_di_l => bus_is_di,
								 is_reti_l => bus_is_reti,
								 is_getiid_l => bus_is_getiid,
								 int_en => int_en,
								 exception_l => exception_l,
								 exception => exception,
								 inval_instr_l => bus_inval_instr,
								 inval_instr => inval_instr,
--								 inval_align_l => bus_inval_align,
--								 inval_align => inval_align,
								 div_zero_l => div_zero_l,
								 div_zero => div_zero,
								 ldpc => sig_ldpc,
								 wrd => wrd,
								 wr_m => wr_m,
								 ldir => sig_ldir,
								 ins_dad => ins_dad,
								 word_byte => word_byte,
								 is_rds => is_rds,
								 is_wrs => is_wrs,
								 is_ei => is_ei,
								 is_di => is_di,
								 is_reti => is_reti,
								 is_system => bus_is_system,
								 is_getiid => is_getiid,
								 exception_code => exception_code
								 );
		is_system <= bus_is_system;
		
END Structure;