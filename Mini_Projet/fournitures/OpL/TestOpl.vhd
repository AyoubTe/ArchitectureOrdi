library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TestOpl is
end TestOpl;

architecture behavior of TestOpl is

  -- Composants à tester
  component MasterOpl
    port(
      rst : in std_logic;
      clk : in std_logic;
      en : in std_logic;
      v1 : in std_logic_vector(7 downto 0);
      v2 : in std_logic_vector(7 downto 0);
      miso : in std_logic;
      ss : out std_logic;
      sclk : out std_logic;
      mosi : out std_logic;
      val_xor : out std_logic_vector(7 downto 0);
      val_and : out std_logic_vector(7 downto 0);
      val_or : out std_logic_vector(7 downto 0);
      busy : out std_logic
    );
  end component;

  component SlaveOpl
    port(
      sclk : in std_logic;
      mosi : in std_logic;
      ss : in std_logic;
      miso : out std_logic
    );
  end component;

  -- Signaux pour connecter Master et Slave
  signal rst : std_logic := '0';
  signal clk : std_logic := '0';
  signal en : std_logic := '0';
  signal v1, v2 : std_logic_vector(7 downto 0) := (others => 'U');
  signal ss, sclk, mosi : std_logic;
  signal val_xor, val_and, val_or : std_logic_vector(7 downto 0);
  signal busy : std_logic;
  signal miso : std_logic;

  -- Définition de la période d'horloge
  constant clk_period : time := 10 ns;

begin

  -- Instanciation du MasterOpl
  uut_master: MasterOpl
    port map(
      rst => rst,
      clk => clk,
      en => en,
      v1 => v1,
      v2 => v2,
      miso => miso,
      ss => ss,
      sclk => sclk,
      mosi => mosi,
      val_xor => val_xor,
      val_and => val_and,
      val_or => val_or,
      busy => busy
    );

  -- Instanciation du SlaveOpl
  uut_slave: SlaveOpl
    port map(
      sclk => sclk,
      mosi => mosi,
      ss => ss,
      miso => miso
    );

  -- Génération de l'horloge
  clk_process : process
  begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process;

  -- Génération des stimuli
  stim_proc: process
  begin
    wait for 1 ns;  
    rst <= '1';
    wait for clk_period;
    
    -- insert stimulus here
    -- 1 Echange
    v1 <= "11110101";
    v2 <= "10000001";
    
    wait for clk_period*10;  
    
    en <= '1';
    wait for clk_period*3;
    en <= '0';
    wait until busy = '0';
    
    -- 2 eme echange
    v1 <= "10011001";
    v2 <= "01111110";
    
    wait for clk_period*10; 
    en <= '1';
    wait for clk_period*3;
    en <= '0';
    wait until busy = '0';
    
	 -- 3 eme echange
    v1 <= "10010001";
    v2 <= "10001111";
    
    wait for clk_period*10; 
    en <= '1';
    wait for clk_period*3;
    en <= '0';
    wait until busy = '0';
    
    wait;
  end process;

end behavior;
