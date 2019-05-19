LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE work.constants_pkg.all;

ENTITY interrupt_controller IS
    PORT (clk    : IN  STD_LOGIC;
			 boot   : IN STD_LOGIC; 
			 inta   : IN STD_LOGIC; 
			 key_intr : IN STD_LOGIC;
			 ps2_intr : IN STD_LOGIC;
			 switch_intr : IN STD_LOGIC;
			 timer_intr : IN STD_LOGIC;
			 intr   : OUT STD_LOGIC;
			 key_inta : OUT STD_LOGIC;
			 ps2_inta : OUT STD_LOGIC;
			 switch_inta : OUT STD_LOGIC;
			 timer_inta : OUT STD_LOGIC;
			 iid : OUT STD_LOGIC_VECTOR(7 downto 0)
			 );
END interrupt_controller;


ARCHITECTURE Structure OF interrupt_controller IS

--DECISION: id_intr podria ser una màscara (tants bits com interrupcions) i simplificar
--          el codi, pero seria menys escalable.
signal id_intr : STD_LOGIC_VECTOR(2 downto 0) := "111";
-- id values : 
--000 : timer
--001 : key
--010 : switch
--011 : ps2
--1xx : nothing


signal contador : std_logic_vector(2 downto 0) := "100"; --100 es rising edge i 000 es falling edge

BEGIN

	process(clk,boot)
	variable cont : std_logic_vector(2 downto 0);
	begin
		if boot = '0' then
			if rising_edge(clk) then
				intr <= not id_intr(2); --si afegim més interrupcions, s'hauria de canviar.
				--default values
				timer_inta <= '0';
				key_inta <= '0';
				switch_inta <= '0';
				ps2_inta <= '0';
				if (inta='1') then
					case id_intr is
						when "000" => timer_inta <= '1';
						when "001" => key_inta <= '1';
						when "010" => switch_inta <= '1';
						when "011" => ps2_inta <= '1';
						when others => --no hauria de passar, no pot arribar un inta si no hi ha hagut una interrupció previa...
					end case;
					--iid <= "00000" & id_intr; --li retornem el iid al procesador quan ens envia un inta
				end if;
				
				--emulem el clock del procesador dividint el clock50 entre 8
				contador <= contador + 1;
				if contador = "100" then
					if (inta='1') then
						iid <= "00000" & id_intr;
					end if;
				end if;		
			end if;
		else 
			contador <= "100";
		end if;
	end process;
	
--	new_intr <= not new_intr when (timer_intr or key_intr or switch_intr or ps2_intr)='1' else new_intr;
--	
	id_intr <= "000" when timer_intr='1' else 
				  "001" when key_intr='1' else
				  "010" when switch_intr='1' else
				  "011" when ps2_intr='1' else
				 -- id_intr when new_intr /= reset_intr else -- per a mantenenir el id de la intr anterior/ que sesta atenent
				  "111";

END Structure;