library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
USE work.tipos.all;

entity printlogo is
	Generic (NF : integer;
				NC : integer);
	Port ( CLK : in  STD_LOGIC;
			 matrixR : in matriz_logo;
			 matrixG : in matriz_logo;
			 matrixB : in matriz_logo;
			 matrix_porch : in std_logic_vector(0 to 2);
			 matrix_porch_dim : in std_logic_vector(9 downto 0);
			 h_value : in std_logic_vector(9 downto 0);
			 v_value : in std_logic_vector(9 downto 0);
			 square_size : in std_logic_vector(9 downto 0);
			 square_porch : in std_logic_vector(9 downto 0);
			 hc : in std_logic_vector(9 downto 0);
			 vc : in std_logic_vector(9 downto 0);
			 outR : out std_logic;
			 outG : out std_logic;
			 outB : out std_logic);
end printlogo;

architecture Behavioral of printlogo is
signal i : integer range 0 to NF-1;
signal j : integer range 0 to NC-1;
signal sqh_count : std_logic_vector(9 downto 0);
signal sqv_count : std_logic_vector(9 downto 0);
signal sq : STD_LOGIC;
begin
	-- sq está a 1 cuando vc y hc están dentro de la matriz a imprimir
	sq <= '1' when (vc >= v_value and vc < v_value + std_logic_vector(signed(square_size) * NF) and hc >= h_value and hc < h_value + std_logic_vector(signed(square_size) * NC)) else '0';
	-- sqh_count y sqv_count almacenan la posición actual dentro de un cuadrado de la matriz
	sqh_count <= hc - h_value - std_logic_vector(signed(square_size) * j);
	sqv_count <= vc - v_value - std_logic_vector(signed(square_size) * i);
	
	process(CLK)
	begin
		if CLK = '1' and CLK'EVENT then
			if sq = '1' then
				if (hc = h_value + std_logic_vector(signed(square_size) * NC) -1) then
					j <= 0;
					if (vc = v_value + std_logic_vector(signed(square_size) * NF) -1) then
						i <= 0;
					elsif sqv_count = square_size-1 and v_value /= vc then
						i <= i + 1;
					end if;
				elsif sqh_count = square_size-1 then
					j <= j + 1;
				end if;
			end if;
		end if;
	end process;
	
	outR <= matrixR(i)(j) when
				sq = '1' and
				sqh_count >= square_porch and
				sqh_count < square_size - square_porch and
				sqv_count >= square_porch and
				sqv_count < square_size - square_porch
			else '1' when
				sq = '0' and
				matrix_porch(0) = '1' and
				vc >= v_value - matrix_porch_dim and
				vc < v_value + std_logic_vector(signed(square_size) * NF) + matrix_porch_dim and 
				hc >= h_value - matrix_porch_dim and
				hc < h_value + std_logic_vector(signed(square_size) * NC) + matrix_porch_dim
			else '0';
	
	outG <= matrixG(i)(j) when
				sq = '1' and
				sqh_count >= square_porch and
				sqh_count < square_size - square_porch and
				sqv_count >= square_porch and
				sqv_count < square_size - square_porch
			else '1' when
				sq = '0' and
				matrix_porch(1) = '1' and
				vc >= v_value - matrix_porch_dim and
				vc < v_value + std_logic_vector(signed(square_size) * NF) + matrix_porch_dim and 
				hc >= h_value - matrix_porch_dim and
				hc < h_value + std_logic_vector(signed(square_size) * NC) + matrix_porch_dim
			else '0';
	
	outB <= matrixB(i)(j) when
				sq = '1' and
				sqh_count >= square_porch and
				sqh_count < square_size - square_porch and
				sqv_count >= square_porch and
				sqv_count < square_size - square_porch
			else '1' when
				sq = '0' and
				matrix_porch(2) = '1' and
				vc >= v_value - matrix_porch_dim and
				vc < v_value + std_logic_vector(signed(square_size) * NF) + matrix_porch_dim and 
				hc >= h_value - matrix_porch_dim and
				hc < h_value + std_logic_vector(signed(square_size) * NC) + matrix_porch_dim
			else '0';
	
end Behavioral;

