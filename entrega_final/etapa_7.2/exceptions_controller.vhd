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
			  exception : OUT STD_LOGIC
			  );
END exceptions_controller;


ARCHITECTURE Structure OF exceptions_controller IS


BEGIN

--exception_code <= x"F";
exception <= intr or inval_instr or div_zero or inval_align;
--exception <= '1' when intr='1' or inval_instr='1' or div_zero='1' or inval_align='1' else '0';
--exception <= intr;

exception_code <= ex_intr when intr='1' else
						ex_inv_instr when inval_instr = '1' else 
						ex_inv_align when inval_align = '1' else
						ex_div_zero;
				  
END Structure;