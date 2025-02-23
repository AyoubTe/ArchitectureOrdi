--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:09:49 10/31/2018
-- Design Name:   
-- Module Name:   testTxUnit.vhd
-- Project Name:  uart
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TxUnit
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY testTxUnit IS
END testTxUnit;
 
ARCHITECTURE behavior OF testTxUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TxUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         ld : IN  std_logic;
         txd : OUT  std_logic;
         regE : OUT  std_logic;
         bufE : OUT  std_logic;
         data : IN  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
   
    COMPONENT clkUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enableTX : OUT  std_logic;
         enableRX : OUT  std_logic
        );
    END COMPONENT;	

   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enableTx : std_logic := '0';
   signal enableRx : std_logic := '0';
   signal ld : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');

   signal txd : std_logic;
   signal regE : std_logic ;
   signal bufE : std_logic ;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test
   uut0: TxUnit PORT MAP (
          clk => clk,
          reset => reset,
          enable => enableTX,
          ld => ld,
          txd => txd,
          regE => regE,
          bufE => bufE,
          data => data
        );

   -- Instantiate the clkUnit
   clkUnit1: clkUnit PORT MAP (
          clk => clk,
          reset => reset,
          enableTX => enableTX,
          enableRX => enableRX
        );
		  
   -- Clock process definitions
   clk_process :process
   begin
     clk <= '0';
     wait for clk_period/2;
     clk <= '1';
     wait for clk_period/2;
   end process;
 
 
   -- Stimulus process
   stim_proc: process
   begin		
     -- maintien du reset durant 100 ns.
     wait for 100 ns;	
     reset <= '1';

     wait for 200 ns;
		
		
     -- l'emetteur est dispo ?
     if not (regE='1' and bufE='1') then
       wait until regE='1' and bufE='1';
     end if;

     -- si oui, on charge la donnÃ©e
     wait for clk_period;
     -- emission du caractere 0x55
     data <= "01010101";
     ld <= '1';

     -- on attend de voir que l'ordre d'emission
     -- a ete bien pris en compte avant de rabaisser
     -- le signal ld
     if not (regE='1' and bufE='0') then
       wait until regE='1' and bufE='0';
     end if;
     wait for clk_period;
     ld <= '0';
	  

     -- completer avec des tests qui montrent que la prise
     -- en compte de la demande d'emission d'un second
     -- caractere se fait lorsqu'on emet un premier caractere
     -- et ceci quelque soit l'etape d'emission
	  
	  -- 2 eme Chargement de Buffer
	  -- On attend que la donnée soit copie vers le registre
	  if not (regE='0') then
       wait until regE='0';
     end if;
	  
	  -- Emission 
	  data <= "11001100";
	  ld <= '1';
	  
	  -- On s'assure que la data est copie en buffer
	  if not (bufE = '0') then
       wait until bufE = '0';
     end if;
	  
	  wait for clk_period;
	  ld <= '0';
	  
	  -- 3 eme Chargement du buffer
	  -- Emission 
	  data <= "11100010";
	  ld <= '1';
	  
	  -- On s'assure que la data est copie en buffer
	  if not (bufE = '0' and  regE = '1' ) then
       wait until bufE = '0' and regE = '1';
     end if;
	  
	  wait for 200 ns;
	  ld <= '0';
	  
     wait;
   end process;

END;
