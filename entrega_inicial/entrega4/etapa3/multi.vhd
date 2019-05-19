library ieee;
USE ieee.std_logic_1164.all;

entity multi is
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
end entity;

architecture Structure of multi is
component grafo_estados is
	port(
		clk		 : in	std_logic;
		input	 	 : in	std_logic;
		reset	 	 : in	std_logic;
		output	 : out	std_logic_vector(0 downto 0) -- canviar en funcio del #estats
	);
end component;

	-- Build an enumerated type for the state machine
	type state_type is (NOBOOT ,FETCH, DEWM);

	-- Register to hold the current state
	signal state   : state_type;

begin
-- proces canvi d'estat
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
						state <= FETCH;
				end case;
			end if;
		end if;
	end process;

	
	with state select 
		ldpc <= ldpc_l when DEWM,
				  '0' when others;
	with state select 
		wrd <= '0' when FETCH,
				wrd_l when others;
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


end Structure;
