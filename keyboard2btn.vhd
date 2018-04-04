library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keyboard2btn is
    Port ( CLK : in  STD_LOGIC;
			  PS2C : in STD_LOGIC;
			  PS2D : in STD_LOGIC;
			  RESET : in STD_LOGIC;
			  izq : out STD_LOGIC;
			  der : out STD_LOGIC;
			  rapid : out STD_LOGIC;
			  rota : out STD_LOGIC);
end keyboard2btn;

architecture Behavioral of keyboard2btn is
component PS2_Reader is
    Port ( CLK  : in std_logic; --System Clock = 50 MHz
			  CE: in std_logic;	-- Count enable 500KHz
	 		  PS2C : in std_logic;--PS2 
           PS2D : in std_logic;--PS2 data
			  RESET: in std_logic;-- Reset signal, connected to button B1
			  DOUT : out std_logic_vector(7 downto 0);--out data register
           CHAR : out std_logic);--='1' when 1 byte is completely 
			  								-- received
end component;

signal CE : std_logic;
constant cfinal : std_logic_vector(6 downto 0) := "1100100";
signal c : std_logic_vector(6 downto 0) := (others => '0');
constant extbyte : std_logic_vector(7 downto 0) := X"E0";
constant releasebyte : std_logic_vector(7 downto 0) := X"F0";
constant izqbyte : std_logic_vector(7 downto 0) := X"6B";
constant derbyte : std_logic_vector(7 downto 0) := X"74";
constant upbyte : std_logic_vector(7 downto 0) := X"75";
constant downbyte : std_logic_vector(7 downto 0) := X"72";
signal release : std_logic := '0';
signal extended : std_logic := '0';
signal char : std_logic;
signal data : std_logic_vector(7 downto 0);

begin
KB : PS2_Reader
	Port map(
		CLK => CLK,
		CE => CE,
		RESET => RESET,
		PS2C => PS2C,
		PS2D => PS2D,
		DOUT => data,
		CHAR => char
	);

process(clk, reset)
begin
	if reset = '1' then
		c <= (others => '0');
	elsif clk'event and clk = '1' then
		if c = cfinal then
			c <= (others => '0');
		else
			c <= c + 1;
		end if;
	end if;
end process;

CE <= '1' when c = cfinal else '0';

process(CE, reset, data, char)
begin
	if reset = '1' then
		izq <= '0';
		der <= '0';
		rapid <= '0';
		rota <= '0';
		release <= '0';
		extended <= '0';
	elsif CE'event and CE = '1' then
		if char = '1' then
			if data = releasebyte then
				release <= '1';
			elsif data = extbyte then
				extended <= '1';
			elsif extended = '1' and data = upbyte then
				rota <= '1' nand release;
				extended <= '0';
				release <= '0';
			elsif extended = '1' and data = downbyte then
				rapid <= '1' nand release;
				extended <= '0';
				release <= '0';
			elsif extended = '1' and data = izqbyte then
				izq <= '1' nand release;
				extended <= '0';
				release <= '0';
			elsif extended = '1' and data = derbyte then
				der <= '1' nand release;
				extended <= '0';
				release <= '0';
			else
				release <= '0';
				extended <= '0';
			end if;
		end if;
	end if;
end process;
end Behavioral;

