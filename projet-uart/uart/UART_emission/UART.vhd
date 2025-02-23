library IEEE;
use IEEE.std_logic_1164.all;

entity UARTunit is
  port (
    clk, reset : in  std_logic;
    cs, rd, wr : in  std_logic;
    RxD        : in  std_logic;
    TxD        : out std_logic;
    IntR, IntT : out std_logic;         
    addr       : in  std_logic_vector(1 downto 0);
    data_in    : in  std_logic_vector(7 downto 0);
    data_out   : out std_logic_vector(7 downto 0));
end UARTunit;


 architecture UARTunit_arch of UARTunit is

  -- a completer avec l'interface des differents composants
  -- de l'UART
   -- Unite de controle
	COMPONENT ctrlUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		rd : IN std_logic;
		cs : IN std_logic;
		DRdy : IN std_logic;
		FErr : IN std_logic;
		OErr : IN std_logic;
		BufE : IN std_logic;
		RegE : IN std_logic;          
		IntR : OUT std_logic;
		IntT : OUT std_logic;
		ctrlReg : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;
	
	-- L'unite d'horloge
	COMPONENT clkUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;          
		enableTX : OUT std_logic;
		enableRX : OUT std_logic
		);
	END COMPONENT;
	
	-- Unite de transmission
	COMPONENT TxUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		enable : IN std_logic;
		ld : IN std_logic;
		data : IN std_logic_vector(7 downto 0);          
		txd : OUT std_logic;
		regE : OUT std_logic;
		bufE : OUT std_logic
		);
	END COMPONENT;
	
	-- Unite de reception
	COMPONENT RxUnit
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		enable : IN std_logic;
		read : IN std_logic;
		rxd : IN std_logic;          
		data : OUT std_logic_vector(7 downto 0);
		Ferr : OUT std_logic;
		OErr : OUT std_logic;
		DRdy : OUT std_logic
		);
	END COMPONENT;

	
  -- a completer par les signaux internes manquants
	signal lecture, ecriture : std_logic;
	signal donnees_recues : std_logic_vector(7 downto 0);
	signal registre_controle : std_logic_vector(7 downto 0);
	signal enableRx, enableTx : std_logic; -- Horloge de reception et d'envoie
	signal FErr, OErr, BfE, RegE, DRdy : std_logic;


  begin  -- UARTunit_arch

    lecture <= '1' when cs = '0' and rd = '0' else '0';
    ecriture <= '1' when cs = '0' and wr = '0' else '0';
    data_out <= donnees_recues when lecture = '1' and addr = "00"
                else registre_controle when lecture = '1' and addr = "01"
                else "00000000";
  
    -- a completer par la connexion des differents composants
	 -- Instanciation de  L'unite d'emission 
	 Inst_ctrlUnit: ctrlUnit PORT MAP(
		clk => clk,
		reset => reset,
		rd => rd,
		cs => cs,
		DRdy => DRdy,
		FErr => FErr,
		OErr => OErr,
		BufE => BfE,
		RegE => RegE,
		IntR => IntR,
		IntT => IntT,
		ctrlReg => registre_controle
	);
	
	 -- Instantiantion de L'unite d'horloge clkUnit
	 Inst_clkUnit: clkUnit PORT MAP(
		clk => clk,
		reset => reset,
		enableTX => enableTx, -- Horloge de transmission
		enableRX => enableRx -- Horloge de reception
	);
	
	-- Instantiation de L'unité de transmission
	Inst_TxUnit: TxUnit PORT MAP(
		clk => clk,
		reset => reset,
		enable => enableTx,
		ld => ecriture,
		txd => TxD,
		regE => regE,
		bufE => BfE,
		data => data_in
	);
	
	-- Instantiation de L'unité de reception
	 Inst_RxUnit: RxUnit PORT MAP(
		clk => clk,
		reset => reset,
		enable => enableRx,
		read => rd,
		rxd => RxD,
		data => donnees_recues,
		Ferr => FErr,
		OErr => OErr,
		DRdy => DRdy
	);

  end UARTunit_arch;
