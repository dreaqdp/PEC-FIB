library ieee;
USE ieee.std_logic_1164.all;
USE work.constants_pkg.all;

entity multi is
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
		is_getiid_l: IN STD_LOGIC;
		int_en 	 : IN STD_LOGIC;
		exception_l : IN STD_LOGIC;
		exception : OUT STD_LOGIC;
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
		exception_code : IN STD_LOGIC_VECTOR(exception_bits-1 downto 0);
		is_calls_l : IN STD_LOGIC;
		is_calls  : OUT STD_LOGIC;
		instr_prot_l : IN STD_LOGIC;
		instr_prot : OUT STD_LOGIC
		);
end entity;

architecture Structure of multi is
	-- Build an enumerated type for the state machine
	type state_type is (NOBOOT ,FETCH, DEWM, SYSTEM);

	-- Register to hold the current state
	signal state   : state_type;
	--
	signal bus_exception : std_logic := '0';
	signal is_calls_dewm : std_LOGIC := '0';

begin
	-- ge: grafo_estados port map (clk, '1', boot, state);

	process (clk, boot)
	begin
		if boot = '1' then
				state <= NOBOOT;
		else 
			if (rising_edge(clk)) then
				case state is
					when NOBOOT=>
						state <= FETCH;
					when FETCH=>
							state <= DEWM;
					when DEWM=>
						if (is_calls_l = '1' or (exception_l = '1' and (exception_code /= ex_intr or int_en='1'))) then
							state <= SYSTEM;
						else
							state <= FETCH;
						end if;
					when SYSTEM=>
						state <= FETCH;
				end case;
			end if;
		end if;
	end process;
	

	with state select 
		ldpc <= ldpc_l when DEWM,
				  '0' when others;
	with state select 
		wrd <= wrd_l when DEWM,
				 '0' when others;
				 
	with state select 
		wr_m <= wr_m_l when DEWM,
				  '0' when others;
	with state select
		ldir <= '1' when FETCH,
				  '0' when others;	
	with state select 
		word_byte <= w_b when DEWM,
				  '0' when others;
	with state select 
		ins_dad <= '1' when DEWM,
				  '0' when others;
	with state select 
		is_rds <= '0' when FETCH,
					 is_rds_l when others;
	with state select 
		is_wrs <= is_wrs_l when DEWM,
				'0' when others;
	with state select 
		is_ei <= is_ei_l when DEWM,
				   '0' when others;
	with state select 
		is_di <= is_di_l when DEWM,
				   '0' when others;
	with state select 
		is_reti <= is_reti_l when DEWM,
				     '0' when others;
	--intr
	with state select
		is_system <= '1' when SYSTEM,
						 '0' when others;
	with state select
		is_getiid <= is_getiid_l when DEWM,
						 '0' when others;
	with state select
		bus_exception <= exception_l when DEWM,
							  '1' when SYSTEM, --pel regfile, per a modifcar el system BR
						     '0' when others;
	exception <= bus_exception;
	
	--7_2_new
	with state select
		div_zero <= div_zero_l when DEWM,
						'0' when others;

	with state select
		inval_instr <= inval_instr_l when DEWM,
						   '0' when others;
	-- memoritzem si hi ha hagut una CALL per a que al cicle de system pugui activar el bit de mode sistema de S(7)
	with state select
		is_calls_dewm <= is_calls_l when DEWM,
							  is_calls_dewm when others;
	with state select
		is_calls <= is_calls_l when DEWM, 
						is_calls_dewm when SYSTEM,
						'0' when others;
	
	with state select
		instr_prot <= instr_prot_l when DEWM,
						  '0' when others;
		
	
end Structure;
