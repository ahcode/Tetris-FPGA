library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
USE work.tipos.all;

entity vgacontroller is
    Port ( CLK : in  STD_LOGIC;
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
end vgacontroller;

architecture Behavioral of vgacontroller is
	component printtablero is
	Generic (NF : integer;
				NC : integer);
	Port ( CLK : in  STD_LOGIC;
			 matrixR : in tablero;
			 matrixG : in tablero;
			 matrixB : in tablero;
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
	end component;
	component printlogo is
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
	end component;
	component printnext is
	Generic (NF : integer;
				NC : integer);
	Port ( CLK : in  STD_LOGIC;
			 matrix : in matriz_figura;
			 colores : in std_logic_vector(0 to 2);
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
	end component;
	component Score_display is
	 Generic ( F : integer; C : integer );
    Port ( Column_in : in std_logic_vector(9 downto 0); --current column
           Row_in : in std_logic_vector(9 downto 0);	  --current row
           Score_digit_1 : in std_logic_vector (3 downto 0); --LSD
           Score_digit_2 : in std_logic_vector (3 downto 0); --digit 2
           Score_digit_3 : in std_logic_vector (3 downto 0); --digit 3
           Score_digit_4 : in std_logic_vector (3 downto 0); --MSD
           RGB : out std_logic_vector(2 downto 0)); -- current pixel
			  														 -- colour code
	end component;
	constant hpixels		: std_logic_vector(9 downto 0) := "1100100000";	 --Value of pixels in a horizontal line
	constant vlines		: std_logic_vector(9 downto 0) := "1000001001";	 --Number of horizontal lines in the display
	
	constant hbp			: std_logic_vector(9 downto 0) := "0010010000";	 --Horizontal back porch
	constant hfp			: std_logic_vector(9 downto 0) := "1100010000";	 --Horizontal front porch
	constant	vbp			: std_logic_vector(9 downto 0) := "0000011111";	 --Vertical back porch
	constant vfp			: std_logic_vector(9	downto 0) := "0111111111";	 --Vertical front porch
	
	signal hc, vc			: std_logic_vector(9 downto 0);						 --These are the Horizontal and Vertical counters
	signal clkdiv			: std_logic;												 --Clock divider
	signal vidon			: std_logic;												 --Tells whether or not its ok to display data
	signal vsenable		: std_logic;												 --Enable for the Vertical counter
	
	constant t1h : std_logic_vector(9 downto 0) := "0101011011"; --347
	constant t1v : std_logic_vector(9 downto 0) := "0011100001"; --225
	constant lh : std_logic_vector(9 downto 0) := "0101010100";
	constant lv : std_logic_vector(9 downto 0) := "0001100100";
	constant square_size : std_logic_vector(9 downto 0) := "0000001100"; --10
	constant square_porch : std_logic_vector(9 downto 0) := "0000000001";
	constant tF : integer := 20;
	constant tC : integer := 10;
	constant tmarco : std_logic_vector(9 downto 0) := "0000001010";
	signal t1printR : std_logic;
	signal t1printG : std_logic;
	signal t1printB : std_logic;
	constant logoR : matriz_logo :=
		("0000000000000000000000000",
		"0111000000000111011100000",
		"0010000000000101001000000",
		"0010000000000110001000000",
		"0010000000000101001000000",
		"0010000000000101011100000",
		"0000000000000000000000000");
	constant logoG : matriz_logo :=
		("0000000000000000000000000",
		"0000011101110000011100000",
		"0000010000100000001000000",
		"0000011000100000001000000",
		"0000010000100000001000000",
		"0000011100100000011100000",
		"0000000000000000000000000");
	constant logoB : matriz_logo :=
		("0000000000000000000000000",
		"0000011100000111000001110",
		"0000010000000101000001000",
		"0000011000000110000000100",
		"0000010000000101000000010",
		"0000011100000101000001110",
		"0000000000000000000000000");
	signal logoprintR, logoprintG, logoprintB, nextR, nextG, nextB : STD_LOGIC;
	signal scoreRGB : std_logic_vector(2 downto 0);
begin
	T1 : printtablero
		Generic map(
			NF => tF,
			NC => tC)
		Port map(
			CLK => clkdiv,
			matrixR => mred,
			matrixG => mgrn,
			matrixB => mblu,
			matrix_porch => "001",
			matrix_porch_dim => tmarco,
			h_value => t1h,
			v_value => t1v,
			square_size => square_size,
			square_porch => square_porch,
			hc => hc,
			vc => vc,
			outR => t1printR,
			outG => t1printG,
			outB => t1printB);
	
	LOGO : printlogo
		Generic map(
			NF => 7,
			NC => 25)
		Port map(
			CLK => clkdiv,
			matrixR => logoR,
			matrixG => logoG,
			matrixB => logoB,
			matrix_porch => "111",
			matrix_porch_dim => "0000000011",
			h_value => lh,
			v_value => lv,
			square_size => "0000001010",
			square_porch => square_porch,
			hc => hc,
			vc => vc,
			outR => logoprintR,
			outG => logoprintG,
			outB => logoprintB);

	FN : printnext
		Generic map(
			NF => 4,
			NC => 4)
		Port map(
			CLK => clkdiv,
			matrix => fnext,
			colores => cfnext,
			matrix_porch => "001",
			matrix_porch_dim => tmarco,
			h_value => "1000001000",
			v_value => t1v,
			square_size => square_size,
			square_porch => square_porch,
			hc => hc,
			vc => vc,
			outR => nextR,
			outG => nextG,
			outB => nextB);

	SC : Score_display
		Generic map(
			F => 325,
			C => 500)
		Port map(
			Column_in => hc,
			Row_in => vc,
			Score_digit_1 => sd1,
			Score_digit_2 => sd2,
			Score_digit_3 => sd3,
			Score_digit_4 => sd4,
			RGB => ScoreRGB);
			
	--This cuts the 50Mhz clock in half
	process(CLK)
		begin
			if(CLK = '1' and CLK'EVENT) then
				clkdiv <= not clkdiv;
			end if;
		end process;																			

	--Runs the horizontal counter
	process(clkdiv)
		begin
			if(clkdiv = '1' and clkdiv'EVENT) then
				if hc = hpixels then														 --If the counter has reached the end of pixel count
					hc <= "0000000000";													 --reset the counter
					vsenable <= '1';														 --Enable the vertical counter to increment
				else
					hc <= hc + 1;															 --Increment the horizontal counter
					vsenable <= '0';														 --Leave the vsenable off
				end if;					
		end if;
	end process;

	hs <= '1' when hc(9 downto 7) = "000" else '0';								 --Horizontal Sync Pulse

	process(clkdiv)
	begin
		if(clkdiv = '1' and clkdiv'EVENT and vsenable = '1') then			 --Increment when enabled
			if vc = vlines then															 --Reset when the number of lines is reached
				vc <= "0000000000";
			else vc <= vc + 1;															 --Increment the vertical counter
			end if;
		end if;
	end process;
	
	vs <= '1' when vc(9 downto 1) = "000000000" else '0';						 --Vertical Sync Pulse
	vidon <= '1' when (((hc < hfp) and (hc > hbp)) or ((vc < vfp) and (vc > vbp))) else '0';	--Enable video out when within the porches
	red <= t1printR or logoprintR or nextR or ScoreRGB(0) when vidon = '1' else '0';
	grn <= t1printG or logoprintG or nextG or ScoreRGB(1) when vidon = '1' else '0';
	blu <= t1printB or logoprintB or nextB or ScoreRGB(2) when vidon = '1' else '0';
end Behavioral;