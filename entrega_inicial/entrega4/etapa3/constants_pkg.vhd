library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package constants_pkg is

constant zero_16 : std_logic_vector(15 downto 0) := x"0000";
constant op_bits : integer := 2;
constant max_addr : std_logic_vector (15 downto 0) := x"BFFE"; -- pel memory controller

-- Control_l code op
constant ctl_arit : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
constant ctl_cmp : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
constant ctl_addi : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
constant ctl_ld : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
constant ctl_st : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
constant ctl_mov : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
constant ctl_muldiv : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
constant ctl_ldB : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
constant ctl_stB : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
constant ctl_halt : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";

-- op alu
constant op_arit_log : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "00";
constant op_cmp : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "01";
constant op_mov : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "10";
constant op_muldiv : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "11";



end package constants_pkg;