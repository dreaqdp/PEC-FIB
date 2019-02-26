-------------------------------------------------------
-- Test bench for ROM
-------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_arith.all;
    use ieee.std_logic_unsigned.all;
    
entity test_rom is
end entity;
architecture test of test_rom is

    signal address :std_logic_vector (15 downto 0) := (others=>'0');
    signal read_en :std_logic := '0';
    signal ce      :std_logic := '0';
    signal data    :std_logic_vector (15 downto 0) := (others=>'0');
    signal clk     :std_logic := '0';
    signal iniciacio :std_logic := '0';

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

begin

    clk <= not clk after 10 ns;
    
    process
	variable var_addr : integer := 0;
	begin
		iniciacio <= '1' after 5 ns, '0' after 15 ns;
		wait for 20 ns;
		var_addr:=49152;  -- X"C000" ==> 49152; 
		for i in 0 to 255 loop
            address <= conv_std_logic_vector(var_addr, 16);
            read_en <= '1' after 5 ns, '0' after 15 ns;
            ce      <= '1' after 5 ns, '0' after 15 ns;
			var_addr:=var_addr+2;
            wait for 20 ns;
        end loop;
    end process;

   mem0 : memory
      port map (
         clk      => clk,
         addr     => address,
         wr_data  => X"0000",
         rd_data  => data,
         we       => '0',
         byte_m   => '0',
         boot     => iniciacio
      );

end architecture;


