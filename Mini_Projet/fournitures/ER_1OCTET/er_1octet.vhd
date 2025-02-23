library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity er_1octet is
  port ( rst : in std_logic ;
         clk : in std_logic ;
         en : in std_logic ;
         din : in std_logic_vector (7 downto 0) ;
         miso : in std_logic ;
         sclk : out std_logic ;
         mosi : out std_logic ;
         dout : out std_logic_vector (7 downto 0) ;
         busy : out std_logic);
end er_1octet;

architecture behavioral of er_1octet is
	type t_etat is ( repos, reception_bit, emission_bit ); -- Les �tats de er_1octet durant l'�change avec Joystick
	signal etat : t_etat ; -- Variable etat (On utilise l'automate)
	
begin
	process (clk, rst)
		variable cpt_bit : natural ; -- Variable de travail pour savoir quel bit � transmettre
		variable rg : std_logic_vector(7 downto 0); -- Variable de travail pour stocker la data � transmettre
	begin
		if rst = '0' then -- Si un reset est arriv�e => on remet tous � l'etat initiale
			sclk <= '1'; -- Ou cas de repos le maitre met le serial clock a '1'
			dout <= (others => 'U') ; 
			busy <= '0'; -- Indique que aucune transmission n'est encore
			etat <= repos; -- Indique que le maitre est dans une etat de repos
			mosi <= 'U'; -- Mettons master output bit � 'U'
		elsif (rising_edge(clk)) then
			case etat is -- Le bascule entre les �tats de maitre => chaque etat � un traitement sp�cifique
				when repos => -- ETAT DE REPOS (Pas d'�change avec JoyStick)
					if ( en = '1' ) then -- R�ception d'un ordre d'�change
						busy <= '1'; -- Indique que le mettre est en �tat de travail ( d'�change de bit )
						sclk <= '0'; -- Front d�sendant de sclk pour �mission d'un bit par l'esclave et le maitre
						rg := din; -- On stock la data a �mettre
						cpt_bit := 7;
						mosi <= rg(cpt_bit); -- Envoie de 1er Bit (Poinds frot) bit par le maitre en front desendant
						etat <= reception_bit; -- Changemnt d'etat en Reception dans le front montant
					end if;
							
				when reception_bit => -- ETAT DE RECEPTION DE BIT PAR MAITRE (MEME POUR L'ESCLAVE)
					if cpt_bit > 0 then -- On v�rifi�e est ce que nous sommes dans l'�mission de derni�re bit
						sclk <= '1'; -- Front montant de serial clock (sclk) => R�ception de bit 
						rg(cpt_bit) := miso; -- On utilise la meme variable rg pour stocker le bit re�us de slave
						etat <= emission_bit; -- Bascule au emission de prochain bit
					else -- le cas d'envoie de dernier bit
						rg(cpt_bit) := miso; -- Envoie de dernier bit (Bit poids faible)
						sclk <= '1'; -- On remet sclk � '1' en cas de repos
						busy <= '0'; -- On indique que l'�change est termin�
						dout <= rg; -- On met l'octet re�u dans en sortie  de er_1octet
						etat <= repos; -- On passe � l'�tat de repos
					end if;
					
				when emission_bit => -- ETAT D'EMISSION DE BIT (ENVOIE DU BIT)
					sclk <= '0'; -- Front desendant d'oclock
					cpt_bit := cpt_bit - 1; -- On d�cremente le compteur pour pr�ciser le bit suivant � envoyer
					mosi <= rg(cpt_bit); -- Envoie de bit Suivant dans le front desendant actuelle
					etat <= reception_bit; -- On passe � l'�tat de recption dans le front montant suivant
					
			end case;
		end if;
	end process;
end behavioral;
