----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:34:47 11/13/2017 
-- Design Name: 
-- Module Name:    btncontroller - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity btncontroller is
    Port ( CLK : in STD_LOGIC;
	        btn : in  STD_LOGIC_VECTOR (3 downto 0);
           izq : out STD_LOGIC;
			  der : out STD_LOGIC;
			  rapid : out STD_LOGIC;
			  rota : out STD_LOGIC);
end btncontroller;

architecture Behavioral of btncontroller is

component debounce IS
  GENERIC(
    counter_size  :  INTEGER := 19);
  PORT(
    clk     : IN  STD_LOGIC;
    button  : IN  STD_LOGIC;
    result  : OUT STD_LOGIC);
END component;

begin

	D1 : debounce
		Port map(
			clk => CLK,
			button => btn(3),
			result => rota
		);
		
	D2 : debounce
		Port map(
			clk => CLK,
			button => btn(2),
			result => izq
		);
		
	D3 : debounce
		Port map(
			clk => CLK,
			button => btn(0),
			result => der
		);
	
	D4 : debounce
		Port map(
			clk => CLK,
			button => btn(1),
			result => rapid
		);
end Behavioral;

