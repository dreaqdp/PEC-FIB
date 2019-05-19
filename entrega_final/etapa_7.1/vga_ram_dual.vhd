--------------------------------------------------------------------------------
-- Create Date   :    25/08/2008
-- Design Name   :    Ram
-- Developped by :    Nabil Chouba

-- Description   :    Module Ram dual port generic.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity vga_ram_dual is
    generic(d_width    : integer;
            addr_width : integer);
    port(o2     : out STD_LOGIC_VECTOR(d_width - 1 downto 0);
         we1    : in STD_LOGIC;
         clk    : in STD_LOGIC;
         d1     : in STD_LOGIC_VECTOR(d_width - 1 downto 0);
         addr1  : in unsigned(addr_width downto 0);
         addr2  : in unsigned(addr_width - 1 downto 0);
         byte_m : in std_logic);
end vga_ram_dual;


architecture vga_ram_dual_arch of vga_ram_dual is

    type mem_type is array (2**addr_width - 1 downto 0) of  STD_LOGIC_VECTOR (7 downto 0);

    signal mem0 : mem_type;
    signal mem1 : mem_type;

    signal addr_write : unsigned(addr_width  downto 0);
    signal temp : STD_LOGIC_VECTOR(d_width - 1 downto 0);

begin

    addr_write <= "0" & addr1(12 downto 1);

    rwrite_port :  process ( clk )
    begin
        if (clk'event and clk = '1') then
            if (we1 = '1') then
                if (byte_m = '1') then
                    if (addr1(0) = '0') then
                        mem0(conv_integer(addr_write)) <= d1(7 downto 0);  -- escrivim nomes 1 byte (8 bits)
                    else
                        mem1(conv_integer(addr_write)) <= d1(7 downto 0);  -- escrivim nomes 1 byte (8 bits)
                    end if;
                else
                    mem0(conv_integer(addr_write)) <= d1(7 downto 0);   -- escrivim nomes 1 byte (8 bits)
                    mem1(conv_integer(addr_write)) <= d1(15 downto 8);  -- escrivim nomes 1 byte (8 bits)
                end if;
            end if;
            o2(7 downto 0) <= mem0(conv_integer(addr2)) ;
            o2(15 downto 8) <= mem1(conv_integer(addr2)) ;
        end if;
    end process rwrite_port ;

end vga_ram_dual_arch;
