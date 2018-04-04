library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE work.tipos.all;

entity game is
	Port ( CLK : in  STD_LOGIC;
		  reset : in STD_LOGIC;
		  btni : in STD_LOGIC_VECTOR(3 downto 0);
		  btne : in STD_LOGIC_VECTOR(3 downto 0);
		  PS2C : in STD_LOGIC;
		  PS2D : in STD_LOGIC;
		  btne_enable : in STD_LOGIC;
		  KB_enable : in STD_LOGIC;
		  music : in STD_LOGIC;
		  hs : out  STD_LOGIC;
		  vs : out  STD_LOGIC;
		  red : out  STD_LOGIC;
		  grn : out  STD_LOGIC;
		  blu : out  STD_LOGIC;
		  buzzer1 : out STD_LOGIC;
		  buzzer2 : out STD_LOGIC);
end game;

architecture Behavioral of game is

component tetris is
    Port ( CLK : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  izq, der, rapid, rota : in STD_LOGIC;
			  mred : out tablero;
			  mgrn : out tablero;
			  mblu : out tablero;
			  sd1, sd2, sd3, sd4 : out std_logic_vector(3 downto 0);
			  fnext : out matriz_figura;
			  cfnext : out std_logic_vector(0 to 2));
end component;

component vgacontroller is
	port(   CLK : in  STD_LOGIC;
           mred : in tablero;
           mgrn : in tablero;
           mblu : in tablero;
			  sd1, sd2, sd3, sd4 : in std_logic_vector(3 downto 0);
			  fnext : in matriz_figura;
			  cfnext : in std_logic_vector(0 to 2);
           red : out  STD_LOGIC;
           grn : out  STD_LOGIC;
           blu : out  STD_LOGIC;
           hs : out  STD_LOGIC;
           vs : out  STD_LOGIC);
end component;

component btncontroller is
    Port ( CLK : in STD_LOGIC;
	        btn : in  STD_LOGIC_VECTOR (3 downto 0);
           izq : out STD_LOGIC;
			  der : out STD_LOGIC;
			  rapid : out STD_LOGIC;
			  rota : out STD_LOGIC);
end component;

component keyboard2btn is
    Port ( CLK : in  STD_LOGIC;
			  PS2C : in STD_LOGIC;
			  PS2D : in STD_LOGIC;
			  RESET : in STD_LOGIC;
			  izq : out STD_LOGIC;
			  der : out STD_LOGIC;
			  rapid : out STD_LOGIC;
			  rota : out STD_LOGIC);
end component;

component musiccontroller is
    Port ( CLK : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
           Enable : in  STD_LOGIC;
           B1 : out  STD_LOGIC;
           B2 : out  STD_LOGIC);
end component;

signal mredP1, mgrnP1, mbluP1 : tablero;
signal izqP1, derP1, rapidP1, rotaP1 : STD_LOGIC;
signal btn : STD_LOGIC_VECTOR(3 downto 0);
signal izqB, derB, rapidB, rotaB : STD_LOGIC;
signal izqK, derK, rapidK, rotaK : STD_LOGIC;
signal fnext : matriz_figura;
signal cfnext : std_logic_vector(0 to 2);
signal scored1, scored2, scored3, scored4 : std_logic_vector(3 downto 0);
begin
	P1: tetris
		Port map(
			CLK => CLK,
			reset => reset,
			izq => izqP1,
			der => derP1,
			rapid => rapidP1,
			rota => rotaP1,
			mred => mredP1,
			mgrn => mgrnP1,
			mblu => mbluP1,
			sd1 => scored1,
			sd2 => scored2,
			sd3 => scored3,
			sd4 => scored4,
			fnext => fnext,
			cfnext => cfnext
		);
	
--	mredP1 <= (others => (others => '1'));
--	mgrnP1 <= (others => (others => '1'));
--	mbluP1 <= (others => (others => '1'));
--	fnext <= (others => (others => '0'));
--	cfnext <= "111";
	
	btn <= btne when btne_enable = '1' else btni;
	
	VGAC: vgacontroller
		Port map( 
			CLK => CLK,
			mred => mredP1,
			mgrn => mgrnP1,
			mblu => mbluP1,
			sd1 => scored1,
			sd2 => scored2,
			sd3 => scored3,
			sd4 => scored4,
			fnext => fnext,
			cfnext => cfnext,
			red => red,
			grn => grn,
			blu => blu,
			hs => hs,
			vs => vs
		);
	
	BTNC: btncontroller
		Port map(
			CLK => CLK,
			btn => btn,
			izq => izqB,
			der => derB,
			rapid => rapidB,
			rota => rotaB
		);

	KB: keyboard2btn
		Port map(
			CLK => CLK,
			RESET => reset,
			PS2C => PS2C,
			PS2D => PS2D,
			izq => izqK,
			der => derK,
			rapid => rapidK,
			rota => rotaK
		);

	MUSC: musiccontroller
		Port map(
			CLK => CLK,
			reset => reset,
			Enable => music,
			B1 => buzzer1,
			B2 => buzzer2
		);
		
	izqP1 <= izqK when KB_enable = '1' else izqB;
	derP1 <= derK when KB_enable = '1' else derB;
	rapidP1 <= rapidK when KB_enable = '1' else rapidB;
	rotaP1 <= rotaK when KB_enable = '1' else rotaB;
end Behavioral;

