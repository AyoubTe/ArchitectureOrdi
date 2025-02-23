library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity UART_FPGA_N4 is
  port (
  -- ne garder que les ports utiles ?
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
    -- ligne série (à rajouter)
	 txd : out std_logic ;
	 rxd : in std_logic
  );
end UART_FPGA_N4;

architecture synthesis of UART_FPGA_N4 is

  -- rappel du (des) composant(s)
  -- À COMPLÉTER 
 	COMPONENT UARTunit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		cs : IN std_logic;
		rd : IN std_logic;
		wr : IN std_logic;
		RxD : IN std_logic;
		addr : IN std_logic_vector(1 downto 0);
		data_in : IN std_logic_vector(7 downto 0);          
		TxD : OUT std_logic;
		IntR : OUT std_logic;
		IntT : OUT std_logic;
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;


	COMPONENT echoUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		IntR : IN std_logic;
		IntT : IN std_logic;
		data_in : IN std_logic_vector(7 downto 0);          
		cs : OUT std_logic;
		rd : OUT std_logic;
		wr : OUT std_logic;
		addr : OUT std_logic_vector(1 downto 0);
		data_out : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	COMPONENT diviseurClk 
	GENERIC(facteur : natural);
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		nclk : OUT std_logic
		);
	END COMPONENT;
  
  signal nclk, reset : std_logic;
  signal cs_inter, rd_inter, wr_inter, intR_inter, intT_inter : std_logic;
  signal addr_inter : std_logic_vector(1 downto 0);
  signal d1, d2 : std_logic_vector(7 downto 0);
  
begin
	-- valeurs des sorties (à modifier)
	
  -- convention afficheur 7 segments 0 => allumé, 1 => éteint
  ssg <= (others => '1');
  -- aucun afficheur sélectionné
  an(7 downto 0) <= (others => '1');
  -- 16 leds éteintes
  led(15 downto 0) <= (others => '0');

  -- connexion du (des) composant(s) avec les ports de la carte
  -- À COMPLÉTER 
	reset <= not btnC;
	
  	Inst_diviseurClk: diviseurClk 
	GENERIC MAP(645) -- Pour obtenir une horloge de fréquence 155khz
	PORT MAP(
		clk => mclk,
		reset => reset,
		nclk => nclk
	);
	
	Inst_echoUnit: echoUnit PORT MAP(
		clk => nclk,
		reset => reset,
		cs => cs_inter,
		rd => rd_inter,
		wr => wr_inter,
		IntR => intR_inter,
		IntT => intT_inter,
		addr => addr_inter,
		data_in => d1,
		data_out => d2
	);
  
  Inst_UARTunit: UARTunit PORT MAP(
		clk => nclk,
		reset => reset,
		cs => cs_inter,
		rd => rd_inter,
		wr => wr_inter,
		RxD => rxd,
		TxD => txd,
		IntR => intR_inter,
		IntT => intT_inter,
		addr => addr_inter,
		data_in => d2,
		data_out => d1
	);
    
end synthesis;
