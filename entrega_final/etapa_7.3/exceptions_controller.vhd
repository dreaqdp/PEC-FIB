LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_unsigned.all;
USE work.constants_pkg.all;

ENTITY exceptions_controller IS
    PORT  (intr : IN STD_LOGIC;
			  inval_instr : IN STD_LOGIC;
			  inval_align : IN STD_LOGIC;
			  div_zero : IN STD_LOGIC;
			  exception_code : OUT STD_LOGIC_VECTOR(exception_bits-1 downto 0);
			  exception : OUT STD_LOGIC;
			  is_calls : in std_logic;
			  mem_prot : in std_logic; -- mode sys
			  instr_prot : IN STD_LOGIC
			  );
END exceptions_controller;


ARCHITECTURE Structure OF exceptions_controller IS


BEGIN


exception <= intr or inval_instr or div_zero or inval_align or is_calls or mem_prot or instr_prot;	

exception_code <= ex_intr when intr='1' else
						ex_inv_instr when inval_instr = '1' else 
						ex_inv_align when inval_align = '1' else
						ex_mem_prot when mem_prot  = '1' else
						ex_calls when is_calls = '1' else
						ex_instr_prot when instr_prot = '1' else
						ex_div_zero;
				  
END Structure;