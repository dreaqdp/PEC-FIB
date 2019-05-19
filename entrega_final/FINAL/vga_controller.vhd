----------------------------------------------------------------------------------
-- Company: FREE
-- Engineer: Nabil Chouba
--
-- Create Date:    20:29:30 11/14/2009
-- Design Name:
-- Module Name:    vga_controller - RTL
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.numeric_std.all;


entity vga_controller is
    port(clk_50mhz      : in  std_logic; -- system clock signal
         reset          : in  std_logic; -- system reset
         blank_out      : out std_logic; -- vga control signal
         csync_out      : out std_logic; -- vga control signal
         red_out        : out std_logic_vector(7 downto 0); -- vga red pixel value
         green_out      : out std_logic_vector(7 downto 0); -- vga green pixel value
         blue_out       : out std_logic_vector(7 downto 0); -- vga blue pixel value
         horiz_sync_out : out std_logic; -- vga control signal
         vert_sync_out  : out std_logic; -- vga control signal
         --
         addr_vga          : in std_logic_vector(12 downto 0);
         we                : in std_logic;
         wr_data           : in std_logic_vector(15 downto 0);
         rd_data           : out std_logic_vector(15 downto 0);
         byte_m            : in std_logic;
         vga_cursor        : in std_logic_vector(15 downto 0);  -- simplemente lo ignoramos, este controlador no lo tiene implementado
         vga_cursor_enable : in std_logic);                     -- simplemente lo ignoramos, este controlador no lo tiene implementado
end vga_controller;

architecture vga_controller_rtl of vga_controller is
    component vga_sync
    port(clk_25mhz      : in std_logic;
         reset          : in std_logic;
         video_on       : out std_logic;
         horiz_sync_out : out std_logic;
         vert_sync_out  : out std_logic;
         pixel_row      : out std_logic_vector(9 downto 0);
         pixel_column   : out std_logic_vector(9 downto 0));
    end component;

    component vga_font_rom
    port(clk  : in std_logic;
         addr : in std_logic_vector(11 downto 0);
         data : out std_logic_vector(7 downto 0));
    end component;

    component vga_ram_dual
    generic(d_width    : integer;
            addr_width : integer);
    port (o2     : out STD_LOGIC_VECTOR(d_width - 1 downto 0);
          we1    : in STD_LOGIC;
          clk    : in STD_LOGIC;
          d1     : in STD_LOGIC_VECTOR(d_width - 1 downto 0);
          addr1  : in unsigned(addr_width downto 0);
          addr2  : in unsigned(addr_width - 1 downto 0);
          byte_m : in std_logic);
    end component;

    -- pixel signal
    signal video_on     : std_logic;
    signal valid_screen : std_logic;
    signal pixel        : std_logic;

    -- pixel position
    signal pixel_row    : std_logic_vector(9 downto 0);
    signal pixel_column : std_logic_vector(9 downto 0);

    -- rom signal
    signal rom_addr : std_logic_vector(11 downto 0);
    signal rom_data : std_logic_vector(7 downto 0);

    -- ram signal
    signal ram_q2    : STD_LOGIC_VECTOR (15 downto 0);
    signal ram_addr2 : STD_LOGIC_VECTOR (11 downto 0);

    signal aux1_ram_addr2 : STD_LOGIC_VECTOR (11 downto 0);
    signal aux2_ram_addr2 : STD_LOGIC_VECTOR (11 downto 0);

    -- counter signal
    signal counter_dec : STD_LOGIC;
    signal counter_inc : STD_LOGIC;
    signal counter_rst : STD_LOGIC;

    --divisor de reloj
    signal clk_25mhz    : std_logic;

    --para la conversion de la codificacion de los colores: de 2 bits a 8 bits
    signal bitsRojo : std_logic_vector(1 downto 0);
    signal bitsVerde : std_logic_vector(1 downto 0);
    signal bitsAzul : std_logic_vector(1 downto 0);

    signal color_rojo : std_logic_vector(7 downto 0);
    signal color_verde : std_logic_vector(7 downto 0);
    signal color_azul : std_logic_vector(7 downto 0);


    begin
        --Clock divider /2. Pixel clock is 25MHz
        clk_25mhz <= '0'           when reset = '1' else
                     not clk_25mhz when rising_edge(clk_50mhz);

        u_vga_sync : vga_sync
        port map (
            clk_25mhz      => clk_25mhz,
            reset          => reset,
            video_on       => video_on,
            horiz_sync_out => horiz_sync_out,
            vert_sync_out  => vert_sync_out,
            pixel_row      => pixel_row,
            pixel_column   => pixel_column
        );

        u_font_rom : vga_font_rom
        port map (
            clk  => clk_25mhz,
            addr => rom_addr,
            data => rom_data
        );

        U_MonitorRam: vga_ram_dual
        generic map (d_width    => 16,
                     addr_width => 12)  -- 12 bits ==> 4096 words ==> 8192 bytes ==> Mem_VGA[0xA000-0xBFFF]
        port map (
            clk    => clk_25mhz ,
            --write
            we1    => we,
            d1     => wr_data,
            addr1  => unsigned(addr_vga),
            byte_m => byte_m,
            --read
            o2     => ram_q2,
            addr2  => unsigned(ram_addr2)
        );



    -- allow the display of rgb color pixel
    red_out   <= color_rojo  when pixel='1' and  video_on = '1' and valid_screen = '1' else (others=>'0');
    green_out <= color_verde when pixel='1' and  video_on = '1' and valid_screen = '1' else (others=>'0');
    blue_out  <= color_azul  when pixel='1' and  video_on = '1' and valid_screen = '1' else (others=>'0');

    valid_screen <= '1' when (pixel_column(9  downto 3)<= 79) else '0';

    -- get char that must be displayed on this region
    -- calcula la @ de memoria de la pantalla multiplicanco la fila por 80 (80=5*16) y sumandole la columna
    aux1_ram_addr2 <= "00000"&pixel_column(9  downto 3) when (pixel_column(9  downto 3)<= 79) else (others=>'0'); -- calcula la columna
    aux2_ram_addr2 <="00"&std_logic_vector(unsigned(pixel_row(8  downto 4)) * 5);        -- calcula @ parcial de la fila actual multiplicandola por 5
    ram_addr2 <= (aux2_ram_addr2(7  downto 0)&"0000") + aux1_ram_addr2;                 -- calcula @ final multiplicando de @parcial de la fila actual por 16 y sumandole la columna

    -- decode the ram char to displayed it on the screen
    rom_addr <=  ram_q2(7 downto 0) & pixel_row(3 downto 0) ;

    -- ????? No se puede leer el contenido de la memoria de la VGA desde el procasador SISA a no ser que arreglemos esto
    rd_data <= ram_q2;

    -- display the row : data rom data pixel by pixel
    pixel <= rom_data(0) when pixel_column(2 downto 0) = "000" else
             rom_data(7) when pixel_column(2 downto 0) = "001" else
             rom_data(6) when pixel_column(2 downto 0) = "010" else
             rom_data(5) when pixel_column(2 downto 0) = "011" else
             rom_data(4) when pixel_column(2 downto 0) = "100" else
             rom_data(3) when pixel_column(2 downto 0) = "101" else
             rom_data(2) when pixel_column(2 downto 0) = "110" else
             rom_data(1) when pixel_column(2 downto 0) = "111" else
             '0' ;

    --formato color almacenado en la memoria de la VGA (se usan solo 6 bits, 2 por color)
    bitsRojo  <= ram_q2(9 downto 8);
    bitsVerde <= ram_q2(11 downto 10);
    bitsAzul  <= ram_q2(13 downto 12);

    --DE1 (solo usa los bits del '3 downto 0')
    color_rojo <= "00000000" when bitsRojo="00" else     -- valor 0  (0%)
                  "00000101" when bitsRojo="01" else     -- valor 5  (33%)
                  "00001010" when bitsRojo="10" else     -- valor 10 (66%)
                  "00001111";                            -- valor 15 (100%)

    color_verde <= "00000000" when bitsverde="00" else     -- valor 0  (0%)
                   "00000101" when bitsverde="01" else     -- valor 5  (33%)
                   "00001010" when bitsverde="10" else     -- valor 10 (66%)
                   "00001111";                             -- valor 15 (100%)

    color_azul <= "00000000" when bitsAzul="00" else     -- valor 0  (0%)
                  "00000101" when bitsAzul="01" else     -- valor 5  (33%)
                  "00001010" when bitsAzul="10" else     -- valor 10 (66%)
                  "00001111";                            -- valor 15 (100%)

    -- we not use blank_out and csync_out
    blank_out <= '1';
    csync_out <= '1';

end vga_controller_rtl;

