library IEEE;
use IEEE.std_logic_1164.all;

entity clkUnit is
  
 port (
   clk, reset : in  std_logic;
   enableTX   : out std_logic; -- La fréquence d'horloge de transmission : 9.6 Khz
   enableRX   : out std_logic); -- La fréquence d'horloge de reception : 155 Khz
    
end clkUnit;

architecture behavorial of clkUnit is
begin
	process (reset, clk)
		variable cpt : natural := 0;
	begin
		-- La fréquence d'horloge de reception egale à celle de circuit sauf en cas de reset
		enableRX <= clk;
		if reset = '0' then
			-- tant que reset = 0, les horloges enableRX et enableTX n'evoluent pas
			enableRX <= '0';
			enableTX <= '0';
			cpt := 0;
			
		elsif rising_edge(clk) then	
			--  tous les 16 tops d'horloge clk, enableTX passe a '1' pour une periode de l'horloge et vaut '0' autrement
			if cpt = 15 then
				enableTX <= '1';
				cpt := 0;
			else
				enableTX <= '0';
				cpt := cpt + 1;
			end if;
			
		end if;
	end process;
	
end behavorial;
