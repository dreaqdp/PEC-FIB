library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

package constants_pkg is

constant zero_16 : std_logic_vector(15 downto 0) := x"0000";
constant op_bits : integer := 3;
constant in_d_bits : integer := 2;
constant exception_bits : integer := 4;
--unidad de control
constant instr_base    : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"C000"; --instruccio per defecte
constant ir_base    : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
-- Control_l code op
constant ctl_arit : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
constant ctl_cmp : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0001";
constant ctl_addi : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0010";
constant ctl_ld : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0011";
constant ctl_st : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0100";
constant ctl_mov : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101";
constant ctl_branch : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0110";
constant ctl_io : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0111";
constant ctl_muldiv : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1000";
constant ctl_float : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1001";
constant ctl_jump : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1010";
constant ctl_ldf : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1011";
constant ctl_stf : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1100";
constant ctl_ldB : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1101";
constant ctl_stB : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1110";
constant ctl_halt : STD_LOGIC_VECTOR(3 DOWNTO 0) := "1111";
--Contro_l otros
constant sp_rds  : STD_LOGIC_VECTOR(5 DOWNTO 0) := "101100";
constant sp_wrs  : STD_LOGIC_VECTOR(5 DOWNTO 0) := "110000";
constant sp_ei   : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100000";
constant sp_di   : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100001";
constant sp_reti : STD_LOGIC_VECTOR(5 DOWNTO 0) := "100100";
constant sp_getiid : STD_LOGIC_VECTOR(5 DOWNTO 0) := "101000";
constant sp_halt : STD_LOGIC_VECTOR(5 DOWNTO 0) := "111111";

-- op alu
constant op_arit_log : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "000";
constant op_cmp : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "001";
constant op_mov : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "010";  -- mov i branch
constant op_muldiv : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "011";
constant op_branch : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "100";
constant op_jump : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "101";
constant op_io : std_LOGIC_VECTOR (op_bits - 1 downto 0) := "110"; -- util pel mux de datapath
--constant op_spec: std_LOGIC_VECTOR (op_bits - 1 downto 0) := "111";
--reg file
--constant BR_NO   : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
--constant BR_EI   : STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
--constant BR_DI   : STD_LOGIC_VECTOR (1 DOWNTO 0) := "10";
--constant BR_RETI : STD_LOGIC_VECTOR (1 DOWNTO 0) := "11";
--constant MASK_EN  : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000010";
--constant MASK_DIS : STD_LOGIC_VECTOR (7 downto 0) := "11111101";


constant ex_inv_instr : STD_LOGIC_VECTOR (exception_bits-1 DOWNTO 0) := "0000";
constant ex_inv_align : STD_LOGIC_VECTOR (exception_bits-1 DOWNTO 0) := "0001";
constant ex_div_zero : STD_LOGIC_VECTOR (exception_bits-1 DOWNTO 0) := "0100";
constant ex_calls : STD_LOGIC_VECTOR (exception_bits-1 DOWNTO 0) := "1110"; --added
constant ex_intr : STD_LOGIC_VECTOR (exception_bits-1 DOWNTO 0) := "1111";

end package constants_pkg;