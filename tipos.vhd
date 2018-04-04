library IEEE;
use IEEE.STD_LOGIC_1164.all;

package tipos is
	type tablero is array (0 to 19) of std_logic_vector (0 to 9);
	type matriz_logo is array (0 to 6) of std_logic_vector (0 to 24);
	type matriz_figura is array (0 to 3) of std_logic_vector (0 to 3);
end tipos;