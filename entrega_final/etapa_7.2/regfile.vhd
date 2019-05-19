LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;        --Esta libreria sera necesaria si usais conversiones TO_INTEGER
USE ieee.std_logic_unsigned.all; --Esta libreria sera necesaria si usais conversiones CONV_INTEGER
USE work.constants_pkg.all;

ENTITY regfile IS
    PORT (clk    : IN  STD_LOGIC;
          wrd    : IN  STD_LOGIC;
          d      : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
          addr_a : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          addr_b : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
			 addr_d : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
          a      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 b      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			 is_rds : IN STD_LOGIC; --0=BR, 1=SBR
			 is_wrs : IN STD_LOGIC; --0=BR, 1=SBR
			 boot   : IN STD_LOGIC; 
			 --is_int : IN STD_LOGIC;
			 is_ei  : IN STD_LOGIC;
			 is_di  : IN STD_LOGIC;
			 is_reti: IN STD_LOGIC;
			 int_en : OUT STD_LOGIC;
			 exception : IN STD_LOGIC;
			 exception_code : IN STD_LOGIC_VECTOR(exception_bits-1 downto 0);
			 is_system : IN STD_LOGIC;
			 addr_m : in std_logic_vector(15 downto 0)
			 );
END regfile;
 

ARCHITECTURE Structure OF regfile IS
    type BR  is array (7 downto 0) of std_logic_vector(15 downto 0);
	 type SBR is array (7 downto 0) of std_logic_vector(15 downto 0);
	 signal regs :  BR;
	 signal sregs: SBR;
	 
BEGIN
	--DECISIO : utilitzem el bus a i d per enviar s5 i PcUp
	--DECISIO : quan hi hagi una inpterrupcio, activem is_rds i addr_a=5 per llegir S5.
	a <= sregs(conv_integer(addr_a)) when is_rds = '1' or is_system = '1' else --system BR
		  regs (conv_integer(addr_a));

	with is_rds select b <=
		sregs(conv_integer(addr_b)) when '1',
		regs (conv_integer(addr_b)) when others;
		
	int_en <= sregs(7)(1);
	
	process (clk)
	begin
		if rising_edge(clk) then
			if boot='1' then
				sregs(0) <= x"0000"; --TODO: NO ESTEM SEGURS, COPIA DE S7?
				sregs(1) <= instr_base;
				sregs(2) <= x"0000";--era 000f
				--s3 : excepcio mem 
				--s4 : tmp programador
				--s5 : @RSG
				--s6 : futuro
				sregs(3) <= x"0000";
				sregs(7) <= x"0000";
			else
				if (is_system = '1' and exception='1' and (exception_code /= x"F" or sregs(7)(1)='1')) then -- si es int i estan enabled
					sregs(0) <= sregs(7);
					sregs(1) <= d;
					sregs(2) <= x"000" & exception_code;
					--a <= sregs(5);
					sregs(3) <= addr_m; -- no la dividim /2, ja que aixi es independent del controlador de memoria
					sregs(7)(1) <= '0';
				elsif wrd='1' then
					--Escriptura (system i normal)
					if (is_wrs='1') then sregs(conv_integer(addr_d)) <= d;
					else regs(conv_integer(addr_d)) <= d;
					end if;
					--Escriptura en el S7
					if (is_ei='1') then sregs(7)(1)<='1';
					elsif (is_di='1') then sregs(7)(1)<='0';
					elsif (is_reti='1') then sregs(7)<=sregs(0);
					end if;
				end if;
			end if;
		end if;
	end process;

END Structure;