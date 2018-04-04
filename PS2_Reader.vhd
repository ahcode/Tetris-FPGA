------------------------------------------------------------------------
-- Create Date:    22:33:35 11/25/05
------------------------------------------------------------------------ 
-- Module Name:    PS2_Reader - Behavioral
------------------------------------------------------------------------
-- Author: Goga Claudia
--			  Frandos Andrei
------------------------------------------------------------------------
-- Tool versions:  Xilinx ISE v7.1i
------------------------------------------------------------------------
-- Behavioral Description:
------------------------------------------------------------------------
--This source file contains the state machine that reads data from the 
--PS2 Keyboard. 
--The data is stored in an 8 bit shift register.
--The keyboard sends data to the host in 11-bit words that contain a '0'
--start bit, followed by 8- bits of scan code (LSB first), followed by 
--an odd parity bit and terminated with a '1' stop bit.

-----------Port Descrpition---------------------------------------------
--CLK - System Clock = 50MHz
--CE - Chip enable signal - 500KHz 
--PS2C - PS2
--PS2D - PS2 Data
--RESET - is the reset signal connected to button Btn1 of the DIO4 
--		  extension	board. This button when pressed resets the state
--		  machine to the idle state.
--DOUT - is an 8 bit data register
--		 - contains the key scan codes received from the PS2 Keyboard
--CHAR - is a flag; when set shows that 1 byte is completely received 
--			without error

-----------State machine Description------------------------------------
--idle: - waiting to receive a valid start bit to begin reception
--shift_data: - shifting the received bits into the register until
--				    the the last 8'th data bit is received (cnt=7). 
--check_parity: - the parity bit is checked
--check_stopbit: - the stopbit is checked
--frame_error: - There is a stopbit error. The state machine returns
--					  to the idle state.
--parity_error - There is a parity bit error.T he state machine returns
--					  to the idle state. 
--end_char - The reception is succesful. In this state the CHAR flag is
--				 set to '1'
--
--State encodings:
--  		The type of encoding is ONE-HOT
--
--			State   |  Code
--    -----------------------
--       idle	  |	000000
--	  shift_data  |	000001
--	 check_parity |   000010
--  check_stopbit|	000100
--	  frame_error |   001000
--	 parity_error |   010000
--	   end _char  |   100000
	
------------------------------------------------------------------------
-- Dependencies:
--				none
------------------------------------------------------------------------
-- Revision 0.01 - File Created
------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity PS2_Reader is
    Port ( CLK  : in std_logic; --System Clock = 50 MHz
			  CE: in std_logic;	-- Count enable 500KHz
	 		  PS2C : in std_logic;--PS2 
           PS2D : in std_logic;--PS2 data
			  RESET: in std_logic;-- Reset signal, connected to button B1
			  DOUT : out std_logic_vector(7 downto 0);--out data register
           CHAR : out std_logic);--='1' when 1 byte is completely 
			  								-- received
end PS2_Reader;

architecture Behavioral of PS2_Reader is

------------------------------------------------------------------------
--				 SIGNAL and CONSTANT DECLARATIONS
------------------------------------------------------------------------
--The following constants define the state codes for the PS2 Keyboard 
--reader. 
--The type of encoding is ONE_HOT.
constant idle:         std_logic_vector (5 downto 0):="000000";
constant shift_data:   std_logic_vector (5 downto 0):="000001";
constant check_parity: std_logic_vector (5 downto 0):="000010";
constant check_stopbit:std_logic_vector (5 downto 0):="000100";
constant frame_error:  std_logic_vector (5 downto 0):="001000";
constant parity_error: std_logic_vector (5 downto 0):="010000";
constant end_char:     std_logic_vector (5 downto 0):="100000";

--state register and next state register for the FSM
signal state, next_state: std_logic_vector (5 downto 0):=idle;

signal D_PS2C: std_logic:='0'; -- debounced PS2C
signal Q1, Q2: std_logic:='0';

--shift register; stores the received bits
signal REG: std_logic_vector(7 downto 0):=X"00";

signal ptysum: std_logic:='0';	--parity sum
signal ptycheck: std_logic:='0';	-- parity check bit

signal cnt: integer range 0 to 7:=0; -- counter

--The attribute lines below prevent the ISE compiler to extract and 
--optimize the state machines. The states will be implemented as 
--described in the constant declaration above.
attribute fsm_extract : string;
attribute fsm_extract of state: signal is "no"; 
attribute fsm_extract of next_state: signal is "no"; 

attribute fsm_encoding : string;
attribute fsm_encoding of state: signal is "user"; 
attribute fsm_encoding of next_state: signal is "user"; 

attribute signal_encoding : string;
attribute signal_encoding of state: signal is "user"; 
attribute signal_encoding of next_state: signal is "user";

begin

------------------------------------------------------------------------
--				 MODULE IMPLEMENTATION
------------------------------------------------------------------------

debounce: process (CLK, CE, PS2C, Q1, Q2)
begin
	if CLK'event and CLK='1' and CE='1' then
		 Q1<=PS2C;
		 Q2<=Q1;
	end if;
end process debounce;

D_PS2C<= (NOT Q1) and Q2;

-----------------SYNCRONISATION PROCESS---------------------------------

regstate: process (CLK, CE, next_state, RESET)
begin
	if RESET='1' then
			 state<=idle;	 -- state machine reset
	elsif CLK'EVENT and CLK='1' and CE='1' then
			 state<=next_state;
	end if;
end process regstate;

--------------------state TRANSITIONS-----------------------------------

transition: process (state, D_PS2C, PS2D, cnt, ptycheck)
begin
case state is
	when idle=>-- idle
		if D_PS2C='1' and PS2D='0' then -- check start bit
			 next_state<=shift_data;
		else
			 next_state<=idle;
		end if;

	when shift_data=>-- shift in data
		if D_PS2C='1' and cnt=7 then
			 next_state<=check_parity; -- go and check parity
		else
			 next_state<=shift_data;
		end if;

	when check_parity=>-- check parity
		if D_PS2C='1' and PS2D=ptycheck then
			 next_state<=check_stopbit; -- valid parity bit 
			 									 -- go and check stopbit
		elsif D_PS2C='1' then
			 next_state<=parity_error; -- parity error
		else
			 next_state<=check_parity;
		end if;

	when check_stopbit=>-- check stopbit;
		if D_PS2C='1' and PS2D='1' then
			 next_state<=end_char; -- valid stopbit, end Char
		elsif D_PS2C='1' then
			 next_state<=frame_error; -- Frame Error
		else
			 next_state<=check_stopbit;
		end if;

	when frame_error=>-- Frame Error	
		next_state<=idle;

	when parity_error=>-- Parity Error
		next_state<=idle;

	when end_char=>-- end Char
		next_state<=idle;

	when others => next_state<=idle;
end case;
end process transition;


------Counting bits and registering when state=shift_data--------------- 

regin: process (CLK, CE, D_PS2C, PS2D, cnt, ptysum, state)
begin
if state/=shift_data then 
		cnt<=0;
		ptysum<='0';
elsif CLK'EVENT and CLK='1' and CE='1' then
	if D_PS2C='1' then
		ptysum<=ptysum XOR PS2D;-- calculating the parity sum
		REG(7 downto 0)<=PS2D&REG(7 downto 1);--shifting data into 
														  --register
		if cnt=7 then
			cnt<=0;
		else
			cnt<=cnt+1;
		end if;
	end if;
end if;
end process regin;

------------------PARITIY SUM-------------------------------------------

parity_sum: process (CLK, CE, D_PS2C, PS2D, cnt, state, ptysum)
begin
if CLK'EVENT and CLK='1' and CE='1' then
	if state=shift_data and D_PS2C='1' and cnt=7 then
			ptycheck<=(NOT ptysum) XOR PS2D; --parity check bit
	end if;
end if;
end process parity_sum; 

----------------OUTPUT ASSIGNEMENT--------------------------------------

DOUT<=REG;
CHAR<='1' when state=end_char else '0';

end Behavioral;
