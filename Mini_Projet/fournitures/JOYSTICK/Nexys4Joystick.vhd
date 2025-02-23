library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Nexys4Joystick is
  port (
    -- les 16 switchs
    swt : in std_logic_vector (15 downto 0);
    -- les 5 boutons noirs
    btnC, btnU, btnL, btnR, btnD : in std_logic;
    -- horloge
    mclk : in std_logic;
    -- les 16 leds
    led : out std_logic_vector (15 downto 0);
    -- les anodes pour sélectionner les afficheurs 7 segments à utiliser
    an : out std_logic_vector (7 downto 0);
    -- valeur affichée sur les 7 segments (point décimal compris, segment 7)
    ssg : out std_logic_vector (7 downto 0);
	 -- valeur de slave select
	 ss : out std_logic;
	 -- master out slave in
	 mosi : out std_logic;
	 -- master in slave out
	 miso : in std_logic;
	 -- slave clock
	 sck : out std_logic
  );
  
end Nexys4Joystick;

architecture synthesis of Nexys4Joystick is

  -- rappel du (des) composant(s)
  -- À COMPLÉTER
	COMPONENT All7Segments
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		e0 : IN std_logic_vector(3 downto 0);
		e1 : IN std_logic_vector(3 downto 0);
		e2 : IN std_logic_vector(3 downto 0);
		e3 : IN std_logic_vector(3 downto 0);
		e4 : IN std_logic_vector(3 downto 0);
		e5 : IN std_logic_vector(3 downto 0);
		e6 : IN std_logic_vector(3 downto 0);
		e7 : IN std_logic_vector(3 downto 0);          
		an : OUT std_logic_vector(7 downto 0);
		ssg : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	-- MasterJoystick
	COMPONENT MasterJoystick
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		en : IN std_logic;
		miso : IN std_logic;
		led1 : IN std_logic;
		led2 : IN std_logic;          
		X : OUT std_logic_vector(9 downto 0);
		Y : OUT std_logic_vector(9 downto 0);
		btn1 : OUT std_logic;
		btn2 : OUT std_logic;
		btnJ : OUT std_logic;
		ss : OUT std_logic;
		sclk : OUT std_logic;
		mosi : OUT std_logic;
		busy : OUT std_logic
		);
	END COMPONENT;
	-- Diviseur de clock
	COMPONENT diviseurClk
	GENERIC(facteur : natural);
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		nclk : OUT std_logic
		);
	END COMPONENT;
	
	-- Variable de travail
	signal x, y : std_logic_vector(9 downto 0);
	signal nclk, rst : std_logic;

begin
  led(15 downto 4) <= (others => '0');

  -- connexion du (des) composant(s) avec les ports de la carte
  -- À COMPLÉTER 
  rst <= not swt(0);
  
  Inst_diviseurClk: diviseurClk 
  GENERIC MAP (100)
  PORT MAP(
		clk => mclk,
		reset => rst,
		nclk => nclk
	);
  
  Inst_MasterJoystick: MasterJoystick PORT MAP(
		rst => rst, -- Le swithch 1 est le reset
		clk => nclk,
		en => swt(1), -- Enable
		miso => miso,
		led1 => swt(2), -- Commander le led1 de Joystick
		led2 => swt(3), -- Commander le led2 de Joystick
		X => x,
		Y => y,
		btn1 => led(0), -- Button 1 de Joystick commande le led 0 de carte
		btn2 => led(1), -- Button 2 de Joystick commande le led 1 de carte
		btnJ => led(2), -- Button 3 de Joystick commande le led 2 de carte
		ss => ss,
		sclk => sck, -- slave clock li avec la sortie sck de carte
		mosi => mosi,
		busy => led(3) -- On affiche l'etat de MasterJoystick on 
	);

  Inst_All7Segments: All7Segments 
  PORT MAP(
		clk => mclk,
		reset => rst,
		e0 => x(3 downto 0),
		e1 => x(7 downto 4),
		e2 => "00" & x(9 downto 8),
		e3 => "0000",
		e4 => y(3 downto 0),
		e5 => y(7 downto 4),
		e6 => "00" & y(9 downto 8),
		e7 => "0000",
		an => an,
		ssg => ssg
	);
    
end synthesis;
