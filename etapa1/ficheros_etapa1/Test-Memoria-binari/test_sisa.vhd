library ieee;
   use ieee.std_logic_1164.all;


entity test_sisa is
end test_sisa;

architecture comportament of test_sisa is
   component memory is
      port (
         clk          : in std_logic;
         addr         : in std_logic_vector(15 downto 0);
         wr_data      : in std_logic_vector(15 downto 0);
         rd_data      : out std_logic_vector(15 downto 0);
         we           : in std_logic;
         byte_m       : in std_logic;
		 boot         : in std_logic
		 );
   end component;
   
   component proc is
      port (
         clk          : in std_logic;
         boot         : in std_logic;
         datard_m     : in std_logic_vector(15 downto 0);
         addr_m       : out std_logic_vector(15 downto 0)
      );
   end component;
   
   -- Registres (entrades) i cables
   signal clk          : std_logic := '0';
   signal addr         : std_logic_vector(15 downto 0);
   signal rd_data      : std_logic_vector(15 downto 0);
   signal wr_data      : std_logic_vector(15 downto 0);
   signal reset_ram    : std_logic := '0';
   signal reset_proc   : std_logic := '1';
	
begin
   
   -- Instanciacions de moduls
   proc0 : proc
      port map (
         clk       => clk,
         boot      => reset_proc,
         datard_m  => rd_data,
         addr_m    => addr
      );
   
   mem0 : memory
      port map (
         clk      => clk,
         addr     => addr,
         wr_data  => wr_data,
         rd_data  => rd_data,
         we       => '0',
         byte_m   => '0',
         boot     => reset_ram
      );
   
   -- De moment no escrivim
   
   -- Descripcio del comportament
	clk <= not clk after 10 ns;
	reset_ram <= '1' after 5 ns, '0' after 15 ns;    -- reseteamos la Ram en el primer ciclo
	reset_proc <= '1' after 25 ns, '0' after 35 ns;  -- reseteamos el procesador en el segundo ciclo

--    process
--	begin
--		reset_ram <= '1' after 5 ns, '0' after 15 ns;    -- reseteamos la Ram en el primer ciclo
--		reset_proc <= '1' after 25 ns, '0' after 35 ns;  -- reseteamos el procesador en el segundo ciclo
--      wait for 40 ns;
--		for i in 0 to 255 loop
--            read_en <= '1' after 5 ns, '0' after 15 ns;
--            wait for 20 ns;
--        end loop;
--    end process;


	
end comportament;


