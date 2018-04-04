----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:07:58 11/28/2017 
-- Design Name: 
-- Module Name:    musiccontroller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity musiccontroller is
    Port ( CLK : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           Enable : in  STD_LOGIC;
           B1 : out  STD_LOGIC;
           B2 : out  STD_LOGIC);
end musiccontroller;

architecture Behavioral of musiccontroller is
type notas is array(integer range <>) of std_logic_vector(16 downto 0);
constant n : notas(0 to 13) := (
	"11111001001000000", --0 SOL
	"11000101101110110", --1 SI
	"10111010101000100", --2 DO
	"10100110010001011", --3 RE
	"10011100111100001", --4 MIb
	"10001011110100010", --5 FA
	"01111100100100000", --6 SOL
	"01110101100100101", --7 LA
	"01101000101111101", --8 SIb
	"01100010110111011", --9 SI
	"01011101010100010", --10 DO
	"01010011001000101", --11 RE
	"01001110011110000", --12 MIb
	"01000101111010001" --13FA
	);

signal c1, c2 : std_logic_vector(16 downto 0) := (others => '0');
signal cf1 : std_logic_vector(15 downto 0);
signal cf2 : std_logic_vector(16 downto 0);
signal outB1, outB2 : std_logic;

constant cftempo : std_logic_vector(23 downto 0) := "100001101010001011101001";
signal ctempo : std_logic_vector(23 downto 0) := (others => '0');
signal it : integer := 0;

type orden is array (0 to 63) of integer range -1 to 13;
constant orden1 : orden := (6,6,3,4,5,5,4,3,2,2,2,4,6,6,5,4,3,3,3,4,5,5,6,6,4,4,2,2,2,2,-1,-1,5,5,5,7,10,10,8,7,6,6,6,2,6,6,5,4,3,3,3,4,5,5,6,6,4,4,2,2,2,2,-1,-1);
constant orden2 : orden := (0,6,0,6,0,6,0,6,2,10,2,10,2,10,2,10,1,9,1,9,0,6,0,6,2,10,2,10,2,2,3,4,5,13,5,13,5,13,5,13,2,10,2,10,2,10,2,10,0,6,0,6,0,6,0,6,2,10,2,10,2,10,2,10);
begin

	process(clk, reset)
	begin
		if reset = '1' then
			outB1 <= '0';
		elsif clk = '1' and clk'event then
			if it = -1 then
				outB1 <= '0';
			else
				if c1 >= "0" & cf1 then
					c1 <= (others => '0');
					outB1 <= not outB1;
				else
					c1 <= c1 + 1;
				end if;
			end if;
		end if;
	end Process;
	
	process(clk, reset)
	begin
		if reset = '1' then
			outB2 <= '0';
		elsif clk = '1' and clk'event then
			if c2 >= cf2 then
				c2 <= (others => '0');
				outB2 <= not outB2;
			else
				c2 <= c2 + 1;
			end if;
		end if;
	end Process;
	
	process(clk, reset, Enable)
	begin
		if reset = '1' or Enable = '0' then
			ctempo <= (others => '0');
			it <= 0;
		elsif clk = '1' and clk'event then
			if ctempo = cftempo then
				ctempo <= (others => '0');
				if it = 63 then
					it <= 0;
				else
					it <= it + 1;
				end if;
			else
				ctempo <= ctempo + 1;
			end if;
		end if;
	end Process;
	
	cf1 <= n(orden1(it))(16 downto 1);
	cf2 <= n(orden2(it));
	B1 <= outB1 when enable = '1' else '0';
	B2 <= outB2 when enable = '1' else '0';

end Behavioral;

