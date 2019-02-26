LIBRARY ieee;
USE ieee.std_logic_1164.all;
ENTITY Tarea5 IS
 PORT( SW : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
 KEY : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
 HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
END Tarea5;
ARCHITECTURE Structure OF Tarea5 IS
 COMPONENT Mux4 IS
 PORT( Control : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
 Bus0 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
 Bus1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
 Bus2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
 Bus3 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
 Salida : OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
 END COMPONENT;

 COMPONENT driver7Segmentos IS
 PORT( codigoCaracter : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
 bitsCaracter : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
 END COMPONENT;

 SIGNAL bus_enlace : STD_LOGIC_VECTOR(2 DOWNTO 0);

BEGIN
 Multiplexor : Mux4
 Port Map( Control => not KEY,
 Bus0 => SW(2 downto 0),
 Bus1 => SW(5 downto 3),
 Bus2 => SW(8 downto 6),
 Bus3 => "111",
 Salida => bus_enlace);
 Visor : driver7Segmentos
 Port Map( codigoCaracter => bus_enlace,
 bitsCaracter => HEX0);
END Structure; 