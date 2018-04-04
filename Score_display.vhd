------------------------------------------------------------------------
-- Create Date:    15:28:12 12/04/05
------------------------------------------------------------------------ 
-- Module Name:    Score_display - Behavioral
------------------------------------------------------------------------
-- Author: Goga Claudia
--			  Frandos Andrei
------------------------------------------------------------------------
-- Tool versions:  Xilinx ISE v7.1i
------------------------------------------------------------------------
-- Behavioral Description:
------------------------------------------------------------------------
--This source file generates the RGB register that contains the current
--pixel colour that belongs to the score display area.

--The score display area is between the 518 and 595 Column and the
--20 and 29 Row.
--This area is divided thus every digit has his predefined position.
--
--  20 --------------------------------------------------------------
--		| 518           559|560    568|569    577|578    586|587    595|
--		|                  |          |          |		    |			   |
--		|	 SCORE:         |	digit 4	|	digit 3 | digit 2	 |	 digit 1	|
--		|                  |          |          |		    |			   |
--	 29 --------------------------------------------------------------

--The string "SCORE" is defined in the memory location Mem_Score.
--		Mem_Score(Row, Column) - decimal colour code
--
--Every digit is defined in a memory location Mem_0...9
--		Mem_0...9(Row, Column) - decimal colour code
------------------------------------------------------------------------
-- Dependencies:
--  		VGA_signals_generator.vhd
--			Score.vhd
------------------------------------------------------------------------
-- Revision 0.01 - File Created
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Score_display is
	 Generic ( F : integer; C : integer );
    Port ( Column_in : in std_logic_vector(9 downto 0); --current column
           Row_in : in std_logic_vector(9 downto 0);	  --current row
           Score_digit_1 : in std_logic_vector (3 downto 0); --LSD
           Score_digit_2 : in std_logic_vector (3 downto 0); --digit 2
           Score_digit_3 : in std_logic_vector (3 downto 0); --digit 3
           Score_digit_4 : in std_logic_vector (3 downto 0); --MSD
           RGB : out std_logic_vector(2 downto 0)); -- current pixel
			  														 -- colour code
end Score_display;

architecture Behavioral of Score_display is

------------------------------------------------------------------------
-- 				CONSTANT DECLARATIONS
------------------------------------------------------------------------

type INTEGER_VECTOR_1 is array (0 to 8) of integer;
type MATRIX is array (0 to 9) of INTEGER_VECTOR_1;

type INTEGER_VECTOR_2 is array (0 to 41) of integer;
type MATRIX_Score is array (0 to 9) of INTEGER_VECTOR_2;

constant Mem_Score	: MATRIX_Score
:=((0,0,0,2,2,2,2,0,0,0,0,2,2,2,0,0,0,0,2,2,2,0,0,0,0,0,2,2,2,0,0,0,
															  	2,2,2,2,0,0,0,0,0,0),
	(0,0,2,2,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,2,0,0,0,2,0,0,0,2,0,0,
																2,0,0,0,0,0,0,0,0,0),
	(0,2,0,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,0,0,2,0,0,0,0,2,0,
																2,0,0,0,0,0,0,0,0,0),
	(0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,2,0,2,0,0,0,0,2,0,
																2,0,0,0,0,2,0,0,0,0),
	(0,0,2,2,2,0,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,2,0,2,0,0,0,2,0,0,
																2,2,2,2,0,0,0,0,0,0),
	(0,0,0,0,0,2,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,2,0,2,2,2,2,0,0,0,
																2,0,0,0,0,0,0,0,0,0),
	(0,0,0,0,0,0,2,0,2,0,0,0,0,0,0,2,0,0,0,0,0,0,0,2,0,2,0,2,0,0,0,0,
																2,0,0,0,0,0,0,0,0,0),
	(0,0,0,0,0,0,2,0,0,2,0,0,0,0,0,0,2,0,0,0,0,0,2,0,0,2,0,0,2,0,0,0,
																2,0,0,0,0,2,0,0,0,0),
	(0,0,0,0,2,2,0,0,0,0,2,0,0,0,0,0,0,2,0,0,0,2,0,0,0,2,0,0,0,2,0,0,
																2,0,0,0,0,0,0,0,0,0),
	(0,0,2,2,2,0,0,0,0,0,0,2,2,2,0,0,0,0,2,2,2,0,0,0,0,2,0,0,0,0,2,0,
																2,2,2,2,0,0,0,0,0,0));

constant Mem_0 : MATRIX
	:=((0,0,2,2,2,2,2,0,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,0,2,2,2,2,2,0,0));

constant Mem_1 : MATRIX
	:=((0,0,0,0,0,2,0,0,0),
		(0,0,0,0,2,2,0,0,0),
		(0,0,0,2,0,2,0,0,0),
		(0,0,2,0,0,2,0,0,0),
		(0,0,0,0,0,2,0,0,0),
		(0,0,0,0,0,2,0,0,0),
		(0,0,0,0,0,2,0,0,0),
		(0,0,0,0,0,2,0,0,0),
		(0,0,0,0,0,2,0,0,0),
		(0,0,0,0,0,2,0,0,0));

constant Mem_2 : MATRIX
	:=((0,0,0,2,2,2,0,0,0),
		(0,0,2,0,0,0,2,0,0),
		(0,2,0,0,0,0,0,2,0),
		(0,0,0,0,0,0,0,2,0),
		(0,0,0,0,0,0,2,0,0),
		(0,0,0,0,0,2,0,0,0),
		(0,0,0,0,2,0,0,0,0),
		(0,0,0,2,0,0,0,0,0),
		(0,0,2,0,0,0,0,2,0),
		(0,2,2,2,2,2,2,2,0));

constant Mem_3 : MATRIX
	:=((0,0,2,2,2,2,2,2,0),
		(0,0,2,0,0,0,2,0,0),
		(0,0,0,0,0,2,0,0,0),
		(0,0,0,0,2,2,2,0,0),
		(0,0,0,2,2,0,0,2,0),
		(0,0,0,0,0,0,0,2,0),
		(0,0,0,0,0,0,0,2,0),
		(0,0,0,0,0,0,2,0,0),
		(0,0,2,0,0,2,0,0,0),
		(0,0,0,2,2,0,0,0,0));

constant Mem_4 : MATRIX
	:=((0,0,0,0,0,2,0,0,0),
		(0,0,0,0,2,0,0,0,0),
		(0,0,0,2,0,0,0,0,0),
		(0,0,2,0,0,0,2,0,0),
		(0,2,0,0,0,0,2,0,0),
		(0,2,2,2,2,2,2,2,0),
		(0,0,0,0,0,0,2,0,0),
		(0,0,0,0,0,0,2,0,0),
		(0,0,0,0,0,0,2,0,0),
		(0,0,0,0,0,0,2,0,0));

constant Mem_5 : MATRIX
	:=((0,0,2,2,2,2,2,2,0),
		(0,0,2,0,0,0,0,2,0),
		(0,0,2,0,0,0,0,0,0),
		(0,0,2,0,2,2,2,0,0),
		(0,0,2,2,0,0,0,2,0),
		(0,0,0,0,0,0,0,2,0),
		(0,0,0,0,0,0,0,2,0),
		(0,0,2,0,0,0,0,2,0),
		(0,0,0,2,0,0,2,0,0),
		(0,0,0,0,2,2,0,0,0));

constant Mem_6 : MATRIX
	:=((0,0,0,0,0,0,2,0,0),
		(0,0,0,0,0,2,0,0,0),
		(0,0,0,0,2,0,0,0,0),
		(0,0,0,2,0,0,0,0,0),
		(0,0,2,2,2,2,2,0,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,0,2,2,2,2,2,0,0));

constant Mem_7 : MATRIX
	:=((0,0,2,2,2,2,2,2,0),
		(0,0,2,0,0,0,0,2,0),
		(0,0,0,0,0,0,0,2,0),
		(0,0,0,0,0,0,2,0,0),
		(0,0,0,0,0,2,0,0,0),
		(0,0,0,0,2,0,0,0,0),
		(0,0,0,2,0,0,0,0,0),
		(0,0,2,0,0,0,0,0,0),
		(0,0,2,0,0,0,0,0,0),
		(0,0,2,0,0,0,0,0,0));

constant Mem_8 : MATRIX
	:=((0,0,2,2,2,2,2,0,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,0,2,2,2,2,2,0,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,0,2,2,2,2,2,0,0));

constant Mem_9 : MATRIX
	:=((0,0,2,2,2,2,2,0,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,0,2,2,2,2,2,2,0),
		(0,0,0,0,0,0,0,2,0),
		(0,0,0,0,0,0,0,2,0),
		(0,2,0,0,0,0,0,2,0),
		(0,0,2,2,2,2,2,0,0));

begin

------------------------------------------------------------------------
--				 MODULE IMPLEMENTATION
------------------------------------------------------------------------

Score_display: process (Column_in,Row_in,Score_digit_1,Score_digit_2,
		               	Score_digit_3,Score_digit_4)

begin
RGB<="000"; --default value assignement to avoid latches
if Column_in >= C and Column_in <= C+78 then
if Column_in<C+42 then  --"SCORE:" display
			RGB<=conv_std_logic_vector(Mem_Score(conv_integer(Row_in)-F)
											     (conv_integer(Column_in)-C),3);			
elsif Column_in<C+51 then	--digit 4 display = MSD
	case (Score_digit_4)	is
		when "0000" =>
			RGB<=conv_std_logic_vector(Mem_0(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-42),3);
		when "0001" =>
			RGB<=conv_std_logic_vector(Mem_1(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-42),3);	
		when "0010" =>
			RGB<=conv_std_logic_vector(Mem_2(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-42),3);	
		when "0011" =>
			RGB<=conv_std_logic_vector(Mem_3(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-42),3);
		when "0100" =>
			RGB<=conv_std_logic_vector(Mem_4(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-42),3);
		when "0101" =>
			RGB<=conv_std_logic_vector(Mem_5(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-42),3);
		when "0110" =>
			RGB<=conv_std_logic_vector(Mem_6(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-42),3);
		when "0111" =>
			RGB<=conv_std_logic_vector(Mem_7(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-42),3);
		when "1000" =>
			RGB<=conv_std_logic_vector(Mem_8(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-42),3);
		when "1001" =>
			RGB<=conv_std_logic_vector(Mem_9(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-42),3);
		when others =>	 RGB<="000";
	end case;
elsif Column_in<C+60 then	  --digit 3 dispaly
	case (Score_digit_3) is
		when "0000" =>
			RGB<=conv_std_logic_vector(Mem_0(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-51),3);
		when "0001" =>
			RGB<=conv_std_logic_vector(Mem_1(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-51),3);	
		when "0010" =>
			RGB<=conv_std_logic_vector(Mem_2(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-51),3);	
		when "0011" =>
			RGB<=conv_std_logic_vector(Mem_3(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-51),3);
		when "0100" =>
			RGB<=conv_std_logic_vector(Mem_4(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-51),3);
		when "0101" =>
			RGB<=conv_std_logic_vector(Mem_5(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-51),3);
		when "0110" =>
			RGB<=conv_std_logic_vector(Mem_6(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-51),3);
		when "0111" =>
			RGB<=conv_std_logic_vector(Mem_7(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-51),3);
		when "1000" =>
			RGB<=conv_std_logic_vector(Mem_8(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-51),3);
		when "1001" =>
			RGB<=conv_std_logic_vector(Mem_9(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-51),3);
		when others =>	RGB<="000";
	end case;			
elsif Column_in<C+69 then
	case (Score_digit_2) is		 --digit 2 display
		when "0000" =>
			RGB<=conv_std_logic_vector(Mem_0(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-60),3);
		when "0001" =>
			RGB<=conv_std_logic_vector(Mem_1(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-60),3);	
		when "0010" =>
			RGB<=conv_std_logic_vector(Mem_2(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-60),3);	
		when "0011" =>
			RGB<=conv_std_logic_vector(Mem_3(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-60),3);
		when "0100" =>
			RGB<=conv_std_logic_vector(Mem_4(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-60),3);
		when "0101" =>
			RGB<=conv_std_logic_vector(Mem_5(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-60),3);
		when "0110" =>
			RGB<=conv_std_logic_vector(Mem_6(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-60),3);
		when "0111" =>
			RGB<=conv_std_logic_vector(Mem_7(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-60),3);
		when "1000" =>
			RGB<=conv_std_logic_vector(Mem_8(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-60),3);
		when "1001" =>
			RGB<=conv_std_logic_vector(Mem_9(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-60),3);
		when others => RGB<="000";
	end case;
else
	case (Score_digit_1) is		 --digit 1 display = LSD
		when "0000" =>
			RGB<=conv_std_logic_vector(Mem_0(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-69),3);
		when "0001" =>
			RGB<=conv_std_logic_vector(Mem_1(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-69),3);	
		when "0010" =>
			RGB<=conv_std_logic_vector(Mem_2(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-69),3);	
		when "0011" =>
			RGB<=conv_std_logic_vector(Mem_3(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-69),3);
		when "0100" =>
			RGB<=conv_std_logic_vector(Mem_4(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-69),3);
		when "0101" =>
			RGB<=conv_std_logic_vector(Mem_5(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-69),3);
		when "0110" =>
			RGB<=conv_std_logic_vector(Mem_6(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-69),3);
		when "0111" =>
			RGB<=conv_std_logic_vector(Mem_7(conv_integer(Row_in)-F)
								   				(conv_integer(Column_in)-C-69),3);
		when "1000" =>
			RGB<=conv_std_logic_vector(Mem_8(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-69),3);
		when "1001" =>
			RGB<=conv_std_logic_vector(Mem_9(conv_integer(Row_in)-F)
													(conv_integer(Column_in)-C-69),3);
		when others => RGB<="000"; 
	end case;
end if;
else
	RGB <= "000";
end if;

end process Score_display;																						  													   

end Behavioral;
