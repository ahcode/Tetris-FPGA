library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

USE work.tipos.all;

entity tetris is
    Port ( CLK : in  STD_LOGIC;
			  reset : in STD_LOGIC;
			  izq, der, rapid, rota : in STD_LOGIC;
			  mred : out tablero;
			  mgrn : out tablero;
			  mblu : out tablero;
			  sd1, sd2, sd3, sd4 : out std_logic_vector(3 downto 0);
			  fnext : out matriz_figura;
			  cfnext : out std_logic_vector(0 to 2));
end tetris;

architecture Behavioral of tetris is

constant nfiguras : integer := 7;

--FSM
Type Estados is (INI,GEN,CAE,ESP,CFIN,FIJA,CL1,CL2,CL3,CL4, FIN);
signal Estado_actual, Estado_siguiente : Estados;
signal nfig, baja, fijaf, quita, gameover : STD_LOGIC;
signal lquita : integer range 0 to 19;

--Score
signal punt, punt10, lastpunt, lastpunt10 : STD_LOGIC;
signal scored1, scored2, scored3, scored4 : std_logic_vector(3 downto 0) := "0000";

--Tablero
signal tred, tgrn, tblu : tablero := (others => (others=>'0'));
signal tfigura : tablero := (others => (others=>'0'));
constant zeros : STD_LOGIC_VECTOR(0 to 9) := (others => '0');
constant ones : STD_LOGIC_VECTOR(0 to 9) := (others => '1');
constant mfin : tablero := (others => (others => '1'));

--Figuras, rotaciones, colores y tamaños
type figuras is array (0 to nfiguras-1, 0 to 3) of matriz_figura;
constant fig : figuras := (( -- Constante que almacena las figuras y sus rotaciones
		("0000", "0000", "0000", "1111"),
		("1000", "1000", "1000", "1000"), --Palo
		("0000", "0000", "0000", "1111"),
		("1000", "1000", "1000", "1000")
		),(
		("0000", "0000", "0100", "1110"), --T
		("0000", "1000", "1100", "1000"),
		("0000", "0000", "1110", "0100"),
		("0000", "0100", "1100", "0100")
		),(
		("0000", "0000", "1100", "1100"), --Cubo
		("0000", "0000", "1100", "1100"),
		("0000", "0000", "1100", "1100"),
		("0000", "0000", "1100", "1100")
		),(
		("0000", "0000", "1000", "1110"), --L1
		("0000", "1100", "1000", "1000"),
		("0000", "0000", "1110", "0010"),
		("0000", "0100", "0100", "1100")
		),(
		("0000", "0000", "0010", "1110"), --L2
		("0000", "1000", "1000", "1100"),
		("0000", "0000", "1110", "1000"),
		("0000", "1100", "0100", "0100")
		),(
		("0000", "0000", "0110", "1100"), --Rara1
		("0000", "1000", "1100", "0100"),
		("0000", "0000", "0110", "1100"),
		("0000", "1000", "1100", "0100")
		),(
		("0000", "0000", "1100", "0110"), --Rara2
		("0000", "0100", "1100", "1000"),
		("0000", "0000", "1100", "0110"),
		("0000", "0100", "1100", "1000")
		));
type colores is array (0 to nfiguras-1) of std_logic_vector (0 to 2);
constant col : colores := ("011","101","110","001","010","111","100");
type sizes is array (0 to nfiguras-1, 0 to 1) of integer range 1 to 4;
constant siz : sizes := ((1,4),(2,3),(2,2),(2,3),(2,3),(2,3),(2,3));
signal fActual : integer range 0 to nfiguras-1 := 0;
signal rActual : integer range 0 to 3 := 0;
signal fSiguiente : integer range 0 to nfiguras-1 := 0;
signal hpos : integer range 0 to 10 := 3;
signal vpos : integer range -4 to 16 := -4;

--Contadores de frecuencia
constant cf1 : STD_LOGIC_VECTOR(19 downto 0) := "10001110011010100101";
constant cfrapid : STD_LOGIC_VECTOR(19 downto 0) := "00010100010110000101";
signal cbaja : STD_LOGIC_VECTOR(19 downto 0) := (others => '0');
signal cfbaja : STD_LOGIC_VECTOR(19 downto 0) := cf1;
signal ticbaja : STD_LOGIC;

--Botones
signal izq_last, der_last, rota_last : STD_LOGIC := '0';

signal it : integer range 0 to 29;
signal clkdiv : std_logic;
signal rand : integer range 0 to 6;

begin
	
	fnext <= (others => (others => '0')) when reset = '1' or gameover = '1' else fig(fSiguiente,0);
	cfnext <= col(fSiguiente);
	cfbaja <= cfrapid when rapid = '1' else cf1;
	
	--Divisor de frecuencia para bajar la figura
	process (clkdiv, reset)
	begin
		if reset='1' then
			cbaja <= (others => '0');
		elsif clkdiv'Event and clkdiv = '1' then
			if cbaja > cfbaja then
				cbaja <= (others => '0');
			else
				cbaja <= cbaja + 1;
			end if;
		end if;
	end process;
	
	ticbaja <= '1' when cbaja = cfbaja else '0'; --Cada tic baja la figura actual 1 línea
	
	--Process que describe el registro de estados
	Process(clkdiv, Reset)
	begin
		if Reset = '1' then
			Estado_actual <= INI;
		elsif clkdiv'Event and clkdiv = '1' then
			Estado_actual <= Estado_siguiente;
		end if;
	end Process;
	
	--Process que describe los estados
	Process(Estado_actual, Reset, ticbaja, tfigura, tred, tgrn, tblu, vpos)
	begin
		fijaf <= '0';
		nfig <= '0';
		baja <= '0';
		quita <= '0';
		lquita <= 0;
		gameover	<= '0';
		punt <= '0';
		punt10 <= '0';
		case Estado_actual is
			when INI =>
				Estado_siguiente <= GEN;
			when GEN =>
				nfig <= '1';
				Estado_siguiente <= CAE;
			when CAE =>
				baja <= '1';
				Estado_siguiente <= ESP;
			when ESP =>
				if ticbaja = '1' then
					Estado_siguiente <= CFIN;
				else
					Estado_siguiente <= ESP;
				end if;
			when CFIN =>
				--Comprueba si la figura choca o ha llegado al final
				if vpos = 16 or
					(((vpos+1) >= 0) and (((tred(vpos+1) or tgrn(vpos+1) or tblu(vpos+1)) and tfigura(vpos)) /= zeros)) or
					(((vpos+2) >= 0) and (((tred(vpos+2) or tgrn(vpos+2) or tblu(vpos+2)) and tfigura(vpos+1)) /= zeros)) or
					(((vpos+3) >= 0) and (((tred(vpos+3) or tgrn(vpos+3) or tblu(vpos+3)) and tfigura(vpos+2)) /= zeros)) or
					(((vpos+4) >= 0) and (((tred(vpos+4) or tgrn(vpos+4) or tblu(vpos+4)) and tfigura(vpos+3)) /= zeros)) then
					if vpos = -2 then
						Estado_siguiente <= FIN;
					else
						Estado_siguiente <= FIJA;
					end if;
				else
					Estado_siguiente <= CAE;
				end if;
			when FIJA =>
				fijaf <= '1';
				Estado_siguiente <= CL1;
				punt <= '1';
			when CL1 =>
				if (tred(vpos) or tgrn(vpos) or tblu(vpos)) = ones then
					punt10 <= '1';
					quita <= '1';
					lquita <= vpos;
				end if;
				Estado_siguiente <= CL2;
			when CL2 =>
				if (tred(vpos+1) or tgrn(vpos+1) or tblu(vpos+1)) = ones then
					punt10 <= '1';
					quita <= '1';
					lquita <= vpos+1;
				end if;
				Estado_siguiente <= CL3;
			when CL3 =>
				if (tred(vpos+2) or tgrn(vpos+2) or tblu(vpos+2)) = ones then
					punt10 <= '1';
					quita <= '1';
					lquita <= vpos+2;
				end if;
				Estado_siguiente <= CL4;
			when CL4 =>
				if (tred(vpos+3) or tgrn(vpos+3) or tblu(vpos+3)) = ones then
					punt10 <= '1';
					quita <= '1';
					lquita <= vpos+3;
				end if;
				Estado_siguiente <= GEN;
			when FIN =>
				gameover <= '1';
				Estado_siguiente <= FIN;
			when others =>
				Estado_siguiente <= INI;
		end case;
	end process;
	
	--Process que fija las figuras y elimina líneas
	process(clkdiv, fijaf, quita, lquita, reset)
	begin
		if reset = '1' then
			tred <= (others => (others => '0'));
			tgrn <= (others => (others => '0'));
			tblu <= (others => (others => '0'));
		elsif clkdiv'event and clkdiv = '1' then
			if fijaf = '1' then
				for i in 0 to 19 loop
					if col(fActual)(0) = '1' then
						tred(i) <= tred(i) or tfigura(i);
					end if;
					if col(fActual)(1) = '1' then
						tgrn(i) <= tgrn(i) or tfigura(i);
					end if;
					if col(fActual)(2) = '1' then
						tblu(i) <= tblu(i) or tfigura(i);
					end if;
				end loop;
			elsif quita = '1' then
				tred(0 to lquita) <= ("0000000000") & tred(0 to lquita-1);
				tgrn(0 to lquita) <= ("0000000000") & tgrn(0 to lquita-1);
				tblu(0 to lquita) <= ("0000000000") & tblu(0 to lquita-1);
			end if;
		end if;
	end process;
	
	--Process que genera otra figura
	process(nfig, rand, reset)
	begin
		if reset = '1' then
			fSiguiente <= rand;
		elsif nfig'event and nfig = '1' then
			fActual <= fSiguiente;
			fSiguiente <= rand;
		end if;
	end process;
	
	--Process que baja la figura
	process(baja, reset, nfig)
	begin
		if reset = '1' then
			vpos <= -4;
		elsif nfig = '1' then
			vpos <= -2;
		elsif baja'event and baja = '1' then
			vpos <= vpos + 1;
		end if;
	end process;
	
	--Process que mueve la figura a izquierda y derecha
	process(clkdiv,izq,der,vpos,reset)
	begin
		if reset = '1' then
			hpos <= 3;
			izq_last <= '0';
			der_last <= '0';
		elsif clkdiv'event and clkdiv = '1' then 
			if izq = '1' and izq_last = '0' and hpos /= 0 then
				--Comprueba que la siguiente posicion no choca con otra figura
				if (((tred(vpos) or tgrn(vpos) or tblu(vpos)) and tfigura(vpos)(1 to 9) & "0") = zeros) and
					(((tred(vpos+1) or tgrn(vpos+1) or tblu(vpos+1)) and tfigura(vpos+1)(1 to 9) & "0") = zeros) and
					(((tred(vpos+2) or tgrn(vpos+2) or tblu(vpos+2)) and tfigura(vpos+2)(1 to 9) & "0") = zeros) and
					(((tred(vpos+3) or tgrn(vpos+3) or tblu(vpos+3)) and tfigura(vpos+3)(1 to 9) & "0") = zeros) then
					hpos <= hpos-1;
				end if;
			end if;
			if der = '1' and der_last = '0' and tfigura(vpos)(9) = '0' and tfigura(vpos+1)(9) = '0' and
				tfigura(vpos+2)(9) = '0' and tfigura(vpos+3)(9) = '0' then
				if (((tred(vpos) or tgrn(vpos) or tblu(vpos)) and ("0" & tfigura(vpos)(0 to 8))) = zeros) and
					(((tred(vpos+1) or tgrn(vpos+1) or tblu(vpos+1)) and ("0" & tfigura(vpos+1)(0 to 8))) = zeros) and
					(((tred(vpos+2) or tgrn(vpos+2) or tblu(vpos+2)) and ("0" & tfigura(vpos+2)(0 to 8))) = zeros) and
					(((tred(vpos+3) or tgrn(vpos+3) or tblu(vpos+3)) and ("0" & tfigura(vpos+3)(0 to 8))) = zeros) then
					hpos <= hpos+1;
				end if;
			end if;
			if nfig = '1' then
				hpos <= 3;
			end if;
			izq_last <= izq;
			der_last <= der;
		end if;
	end process;
	
	--Process que rota la figura
	process(clkdiv, rota, vpos, reset)
	variable rot : integer range 0 to 3;
	variable C : integer range 1 to 4;
	begin
		if reset = '1' then
			rActual <= 0;
			rota_last <= '0';
		elsif clkdiv'event and clkdiv = '1' then 
			if nfig = '1' then
				rActual <= 0;
			elsif rota = '1' and rota_last = '0' then 
				if 10-hpos >= siz(fActual,0) and 10-hpos >= siz(fActual,1) then
					if rActual = 3 then
						rot := 0;
					else
						rot := rActual + 1;
					end if;
					C := siz(fActual,(rot+1) mod 2);
					--Comprueba que la siguiente posicion no choca con otra figura
					if (((tred(vpos)(hpos to C-1) or tgrn(vpos)(hpos to C-1) or tblu(vpos)(hpos to C-1)) and fig(fActual,rot)(0)(0 to C-1)) = zeros) and
						(((tred(vpos+1)(hpos to C-1) or tgrn(vpos+1)(hpos to C-1) or tblu(vpos+1)(hpos to C-1)) and fig(fActual,rot)(1)(0 to C-1)) = zeros) and
						(((tred(vpos+2)(hpos to C-1) or tgrn(vpos+2)(hpos to C-1) or tblu(vpos+2)(hpos to C-1)) and fig(fActual,rot)(2)(0 to C-1)) = zeros) and
						(((tred(vpos+3)(hpos to C-1) or tgrn(vpos+3)(hpos to C-1) or tblu(vpos+3)(hpos to C-1)) and fig(fActual,rot)(3)(0 to C-1)) = zeros)
						then
							rActual <= rot;
					end if;
				end if;
			end if;
			rota_last <= rota;
		end if;
	end process;
	
	--Process que coloca la figura en una matriz grande dependiendo de vpos y hpos
	process(clk, reset, vpos, hpos, fActual, rActual)
	begin
		if reset = '1' then
			tfigura <= (others => (others => '0'));
		elsif clk'event and clk = '1' then
			if it >= 5 and it < 25 then
				if (it-5) >= vpos and (it-5) < vpos+4 then
					if hpos > 0 then
						tfigura(it-5)(0 to hpos-1) <= (others => '0');
					end if;
					if hpos < 6 then
						tfigura(it-5)(hpos to hpos+3) <= fig(fActual,rActual)(it-5-vpos);
						tfigura(it-5)(hpos+4 to 9) <= (others => '0');
					else
						tfigura(it-5)(hpos to 9) <= fig(fActual,rActual)(it-5-vpos)(0 to 9-hpos);
					end if;
				else
					tfigura(it-5) <=  (others => '0');
				end if;
			end if;
		end if;
	end process;
	
	--Process que cambia el iterador para actualizar la matriz y generar clkdiv
	process(clk, reset)
	begin
		if reset = '1' then
			it <= 0;
		elsif clk'event and clk = '1' then
			if it < 29 then
				it <= it + 1;
			else
				it <= 0;
			end if;
		end if;
	end process;
	
	--Process que asigna la salida
	process(clkdiv, reset)
	begin
		if reset = '1' then
			mred <= mfin;
			mgrn <= mfin;
			mblu <= mfin;
		elsif clkdiv'event and clkdiv = '1' then
			if gameover = '1' then
				mred <= mfin;
				mgrn <= mfin;
				mblu <= mfin;
			else
				for i in 0 to 19 loop
					if col(fActual)(0) = '1' then
						mred(i) <= tfigura(i) or tred(i);
					else
						mred(i) <= tred(i);
					end if;
					if col(fActual)(1) = '1' then
						mgrn(i) <= tfigura(i) or tgrn(i);
					else
						mgrn(i) <= tgrn(i);
					end if;
					if col(fActual)(2) = '1' then
						mblu(i) <= tfigura(i) or tblu(i);
					else
						mblu(i) <= tblu(i);
					end if;
				end loop;
			end if;
		end if;
	end process;
	
	--Process que genera un número aleatorio
	process(clk)
	begin
		if clk'event and clk = '1' then
			if rand = 6 then
				rand <= 0;
			else
				rand <= rand + 1;
			end if;
		end if;
	end process;
	
	--Process que aumenta el score
	process(clkdiv, reset, punt, punt10)
	begin
		if reset = '1' then
			scored1 <= "0000";
			scored2 <= "0000";
			scored3 <= "0000";
			scored4 <= "0000";
		elsif clkdiv = '1' and clkdiv'event then
			if punt = '1' then
				if scored1 < 9 then
					scored1 <= scored1 + 1;
				elsif scored2 < 9 then
					scored1 <= "0000";
					scored2 <= scored2 + 1;
				elsif scored3 < 9 then
					scored1 <= "0000";
					scored2 <= "0000";
					scored3 <= scored3 + 1;
				elsif scored4 < 9 then
					scored1 <= "0000";
					scored2 <= "0000";
					scored3 <= "0000";
					scored4 <= scored4 + 1;
				end if;
			elsif punt10 = '1' then
				if scored2 < 9 then
					scored2 <= scored2 + 1;
				elsif scored3 < 9 then
					scored2 <= "0000";
					scored3 <= scored3 + 1;
				elsif scored4 < 9 then
					scored2 <= "0000";
					scored3 <= "0000";
					scored4 <= scored4 + 1;
				else
					scored1 <= "1001";
				end if;
			end if;
		end if;
	end process;
	
	sd1 <= scored1;
	sd2 <= scored2;
	sd3 <= scored3;
	sd4 <= scored4;
	
	clkdiv <= '1' when it = 0 else '0';
	
end Behavioral;

