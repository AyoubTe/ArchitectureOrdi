library IEEE;
use IEEE.std_logic_1164.all;

entity RxUnit is
  port (
    clk, reset       : in  std_logic;
    enable           : in  std_logic;
    read             : in  std_logic;
    rxd              : in  std_logic;
    data             : out std_logic_vector(7 downto 0);
    Ferr, OErr, DRdy : out std_logic); -- Ferr, OErr : Erreurs de reception
end RxUnit; --  DRdy:Signal qui informe quune donnee a ete recue correctement

architecture RxUnit_arch of RxUnit is
	signal tmprxd : std_logic ; -- la valeur de rxd reÃ§ue lorque de 8ieme top d'horloge de 
	signal tmpclk : std_logic ; -- Signal pour simuler l'horloge d'envoie
	signal reg : std_logic_vector(7 downto 0); -- Buffer de données temporaires
	type t_etat is (repos, reception_donnees, bit_parite);
	signal etat : t_etat; 
	signal cpt_bit : natural := 0;
	signal bit_p : std_logic;
	signal tmpDRdy : std_logic := '0';
begin
	compteur16: process(enable, reset)
		variable cpt : natural := 0;
	begin
		if reset = '0' then
			tmpclk <= '0';
			tmprxd <= '0';
			cpt := 0;
			
		elsif rising_edge(enable) then
			if cpt = 7 then 
				tmprxd <= rxd;
				cpt := cpt + 1;
			elsif cpt = 15 then 
				tmpclk <= '1';
				cpt := 0;
			else 
				tmpclk <= '0';
				cpt := cpt + 1;
			end if;
		end if;
	end process;
	
	controle_reception: process (tmpclk, reset)
	begin
		if reset = '0' then
			etat <= repos;
			reg <= (others => '0');
			cpt_bit <= 0;
			Drdy <= '0';
			tmpDRdy <= '0';
			FErr <= '0';
		
		elsif rising_edge(tmpclk) then
			case etat is 
				when repos => 
					FErr <= '0';
					Drdy <= '0';
					tmpDRdy <= '0';
					if tmprxd = '0' then -- Détection de bit de départ
						etat <= reception_donnees;
						cpt_bit <= 7;
						bit_p <= '0';
						reg <= (others => '0');
					end if;
				
				when reception_donnees =>
					reg(cpt_bit) <= tmprxd;
					bit_p <= (bit_p xor tmprxd);
					if cpt_bit = 0 then
						etat <= bit_parite;
					else
						cpt_bit <= cpt_bit - 1;
					end if;
					
				when bit_parite =>
					if tmprxd = bit_p then -- Bit d'arret valide
						data <= reg;
						DRdy <= '1';
						tmpDRdy <= '1';
					else 
						FErr <= '1';
					end if;
					etat <= repos;
			end case;
		end if;
	end process;
	
	oerr_p: process(clk, reset)
	begin
		if reset = '0' then
			OErr <= '0';
		elsif rising_edge(clk) then
			-- Vérification d'erreur de débordement
			if tmpDRdy = '1' and read = '0' then
				OErr <= '1';
			else
				OErr <= '0';
			end if;
		end if;
	end process;

end RxUnit_arch;



