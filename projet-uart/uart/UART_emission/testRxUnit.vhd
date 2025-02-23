--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:37:20 01/18/2025
-- Design Name:   
-- Module Name:   D:/Formation ENSEEIHT/2024-2025/Architecture des ordinateurs/projet-rs232/uart/UART_emission/testRxUnit.vhd
-- Project Name:  uart
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RxUnit
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
 
ENTITY testRxUnit IS
END testRxUnit;
 
ARCHITECTURE behavior OF testRxUnit IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RxUnit
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         enable : IN  std_logic;
         read : IN  std_logic;
         rxd : IN  std_logic;
         data : OUT  std_logic_vector(7 downto 0);
         Ferr : OUT  std_logic;
         OErr : OUT  std_logic;
         DRdy : OUT  std_logic
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


   signal enableTx : std_logic := '0';
   signal enableRx : std_logic := '0';
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal enable : std_logic := '0';
   signal read : std_logic := '0';
   signal rxd, ld, rege, bufe : std_logic;

 	--Outputs
   signal data_out : std_logic_vector(7 downto 0);
	signal data_in : std_logic_vector(7 downto 0);
   signal Ferr : std_logic;
   signal OErr : std_logic;
   signal DRdy : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
	-- Instantiate the clkUnit
   clkUnit1: clkUnit PORT MAP (
          clk => clk,
          reset => reset,
          enableTX => enableTX,
          enableRX => enableRX
   );
		  
	-- Instantiate the Unit Under Test (UUT)
   uut: RxUnit PORT MAP (
          clk => clk,
          reset => reset,
          enable => enableRx,
          read => read,
          rxd => rxd,
          data => data_out,
          Ferr => Ferr,
          OErr => OErr,
          DRdy => DRdy
        );
	
	
	-- Instantiation de TxUnit
	Inst_TxUnit: TxUnit PORT MAP(
		clk => clk,
		reset => reset,
		enable => enableTx,
		ld => ld,
		txd => rxd,
		regE => regE,
		bufE => bufE,
		data => data_in
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
	  read <= '0';

	  
	  	-------------------- pas d'erreur levée --------------------
	  
	  
	  -- La donnée envoyée par TxUnit et recue par RxUnit
	  -- Ordre d'envoi
	  data_in <= "10101010";
	  ld <= '1';
	  
	  -- Attente pendant un cycle d'horloge
	  wait for clk_period;
	  ld <='0';
	  read <= '0';
	  
	  -- Attente jusqu'a fin de reception
	  if not DRdy = '1' then
		wait until DRdy = '1';
	  end if;
	  
	   wait for clk_period;
		read <= '1';
		wait for clk_period;
		read <= '0';
	  
	  -------------------- levée d'erreur OErr --------------------
	  
	  -- La donnée envoyée par TxUnit et recue par RxUnit
	  -- Ordre d'envoi
	  data_in <= "11100010";
	  wait for clk_period;
	  ld <= '1';
	  
	  -- Attente pendant un cycle d'horloge
	  wait for clk_period;
	  ld <='0';
	  
	  -- Attente jusqu'a fin de reception
	  if not DRdy = '1' then
		wait until DRdy = '1';
	  end if;
	  
	  -- Demande de lecture arrive après 2 cycles d'horloge. 
	  wait for 2*clk_period;
	  read <= '1';
	  
	  wait for clk_period;
	  read <= '0';
	  
	  
     wait;
	  
   end process;


END;
