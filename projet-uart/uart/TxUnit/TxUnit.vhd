library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;
    enable : in std_logic;
    ld : in std_logic;
    txd : out std_logic;
    regE : out std_logic;
    bufE : out std_logic;
    data : in std_logic_vector(7 downto 0));
end TxUnit;

architecture behavorial of TxUnit is
	type t_etat is (e0, e1, e2, e3, e4);
	signal etat : t_etat := e0;
	signal bufferT : std_logic_vector(7 downto 0); -- Le buffer d'octet en attente de transmission
	signal registreT : std_logic_vector(7 downto 0); -- Registre pour stocker l'octet en cours de transmission
	signal parite : std_logic; -- Bit de parite
	signal bufE_aux : std_logic; -- Sert  lire les valeurs de bufE
	
begin
	process (clk, reset)
		variable cpt_bit : natural;
	begin
		if (reset = '0') then
			txd <= '1';
			bufE <= '1';
			regE <= '1';
			etat <= e0;
			
		elsif (rising_edge(clk)) then
			case etat is 
				when e0 => -- Etat 0 chargement de Buffer 
					if ld = '1' then
						bufferT <= data;
						bufE <= '0';
						bufE_aux <= '0';
						etat <= e1;
					end if;
					
				when e1 => -- Etat 1 
					registreT <= BufferT;
					regE <= '0';
					bufE <= '1';
					bufE_aux <= '1';
					etat <= e2;
					
				when e2 => 
					if enable = '1' then
						-- Envoi de bit de Start
						txd <= '0';
						-- Initialisation de compteur
						cpt_bit := 8;
						parite <= '0';
						etat <= e3;
					end if;
					
				when e3 =>
					-- Envoi des bits de donne (data)
					if enable = '1' and cpt_bit > 0 then
						cpt_bit := cpt_bit - 1;
						txd <= registreT(cpt_bit);
						parite <= parite xor registreT(cpt_bit);
					
					elsif enable = '1' and cpt_bit = 0 then
						-- Envoi de bit de Stop
						txd <= parite;
						regE <= '1';
						etat <= e4;
					end if;
					
				when e4 =>
					-- Si le buufer est charge en cours d'envoi 
					if enable = '1' and bufE_aux = '0' then
						txd <= '1';
						etat <= e1;
					-- Si le buffer est vide
					elsif enable = '1' and bufE_aux = '1' then
						txd <= '1';
						etat <= e0;
					end if;
			end case;
			-- Si 
			if ld = '1' and bufE_aux = '1' then
				bufferT <= data;
				bufE <= '0';
				bufE_aux <= '0';
			end if;
		end if;
	end process;

end behavorial;
