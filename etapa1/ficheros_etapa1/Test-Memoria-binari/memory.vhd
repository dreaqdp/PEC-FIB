library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;
   use ieee.std_logic_textio.all;
   use std.textio.all;


entity memory is
   port (
      clk          : in std_logic;
      addr         : in std_logic_vector(15 downto 0);
      wr_data      : in std_logic_vector(15 downto 0);
      rd_data      : out std_logic_vector(15 downto 0);
      we           : in std_logic;
      byte_m       : in std_logic;
      boot         : in std_logic
   );
end entity;

architecture comportament of memory is

    -- RAM block 8x2^16
   type BLOQUE_RAM is array (2 ** 16 - 1 downto 0) of std_logic_vector(7 downto 0);
   signal mem          : BLOQUE_RAM;

   -- Registres i xarxes
   signal addr1        : std_logic_vector(15 downto 0);
   signal lowByte      : std_logic_vector(7 downto 0);

    -- Instructions to read a text file into RAM --
    procedure Load_FitxerDadesMemoria (signal data_word :inout BLOQUE_RAM) is
        -- Open File in Read Mode
        file romfile   :text open read_mode is "contingut.memoria.bin.rom";
        variable lbuf  :line;
        variable i     :integer := 49152;  -- X"C000" ==> 49152 adreca inicial S.O.
        variable fdata :std_logic_vector (7 downto 0);
    begin
        while not endfile(romfile) loop
            -- read data from input file
            readline(romfile, lbuf);
            read(lbuf, fdata);
            data_word(i) <= fdata;
            i := i+1;
        end loop;
    end procedure;
	
begin
   
   -- Assignacions continues
    addr1 <= addr + "0000000000000001";

	lowByte <= mem(conv_integer(addr));

	-- lectura asincrona
	-- si llegim un sol byte (byte_m=1), aleshores extenem el signe
    rd_data <= lowByte(7) & lowByte(7) & lowByte(7) & lowByte(7) & lowByte(7) & lowByte(7) & lowByte(7) & lowByte(7) & mem(conv_integer(addr)) when (byte_m = '1') else
	           (mem(conv_integer(addr1)) & lowByte);
			   
	-- Comportament inicialitzacio i escritura sincrona
    process (clk)
    begin
      if (clk'event and clk = '1') then
		if boot = '1' then
			-- Procedural Call --
			Load_FitxerDadesMemoria(mem);
		else
			if (we = '1') then
              if (byte_m = '1') then
                 mem(conv_integer(addr))  <= wr_data(7 downto 0);  -- escrivim nomes 1 byte (8 bits)
              else
                 mem(conv_integer(addr))  <= wr_data(7 downto 0);  -- escrivim 2 bytes (16 bits)
                 mem(conv_integer(addr1)) <= wr_data(15 downto 8);
              end if;
			end if;
		 end if;
	   end if;
    end process;
   
end comportament;


