library ieee;
use ieee.std_logic_1164.all;

package constants_pkg is

constant max_addr : std_logic_vector (15 downto 0) := x"BFFE"; -- pel memory controller
-- Control_l code op
constant ctl_mov : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
constant ctl_ld : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
constant ctl_ldB : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
constant ctl_st : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
constant ctl_stB : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";

-- op alu
constant alu_movi : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
constant alu_movhi : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
constant alu_addi : STD_LOGIC_VECTOR(1 DOWNTO 0) := "10";


end package constants_pkg;