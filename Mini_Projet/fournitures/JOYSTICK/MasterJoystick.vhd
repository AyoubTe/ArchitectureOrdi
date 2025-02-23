----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:55:37 11/21/2024 
-- Design Name: 
-- Module Name:    MasterJoystick - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MasterJoystick is
    Port ( 
		rst : in std_logic; 
		clk : in std_logic;
      en : in std_logic;
      miso : in std_logic; -- Master-in Slave-out
      led1 : in std_logic; -- Allumer le led 1 de Joystick 
      led2 : in std_logic; -- Allumer le led 2 de Joystick
      X : out std_logic_vector (9 downto 0); -- Position du Joystick selon l'axe x
      Y : out std_logic_vector(9 downto 0); -- Valeur de la position selon l'axe y
      btn1 : out std_logic; -- La valeur du button 1 de Joystick
      btn2 : out std_logic; -- La valeur du button 2 de Jostick 
      btnJ : out std_logic; -- Le button central de Joystick
		ss   : out std_logic; -- Slave Select
      sclk : out std_logic; -- Slave Clock génnèrée par Master
      mosi : out std_logic; -- Le signal master-out slave-in génèré par le Master 
      busy : out std_logic
	);
end MasterJoystick;
architecture Behavioral of MasterJoystick is
	-- Définition des états d'automate
	type t_etat is (repos, attente, echange);
	-- variable de travail : etat
	signal etat : t_etat := repos;
	
	-- RAPPEl DE COMPOSENT
	COMPONENT er_1octet
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		en : IN std_logic;
		din : IN std_logic_vector(7 downto 0);
		miso : IN std_logic;          
		sclk : OUT std_logic;
		mosi : OUT std_logic;
		dout : OUT std_logic_vector(7 downto 0);
		busy : OUT std_logic
		);
	END COMPONENT;
	
	-- Variables internes
	signal en_er : std_logic; -- signal enable de er_1octet
   signal din_er : std_logic_vector(7 downto 0); -- octet envoyé par er_1octet
   signal dout_er : std_logic_vector(7 downto 0); -- octet reçu par er_1octet 
   signal busy_er : std_logic; -- busy de er_1octet
begin
	-- Instance de er_1octet
	Inst_er_1octet: er_1octet PORT MAP(
		rst => rst,
		clk => clk,
		en => en_er,
		din => din_er,
		miso => miso,
		sclk => sclk,
		mosi => mosi,
		dout => dout_er,
		busy => busy_er
	);
	
	process (clk, rst)
		-- Variable pour gérer le temps d'attente
		variable dureeAttente : natural := 0;
		-- Numéro d'octet à envoyer
		variable noOctet : natural := 1;
		-- Temps d'attente de départ avant le premier envoi (15µs => 15 cycles avec une fréquence 1MHZ) 
		constant ATTENTE_DEPART : natural := 15;
		-- La durée d'attente entre envoi de 2 octets (10µS => 10 cycles avec une fréquence de 1Mhz)
		constant EOATTENTE : natural := 10;
	begin
		-- A la reception d'une rst on remet tous à zero
		if rst = '0' then
			busy <= '0';
			ss <= '1';
			X <= (others => '0');
			Y <= (others => '0');
			noOctet := 1;
			etat <= repos;
		elsif rising_edge(clk) then
			case etat is 
				when repos => -- Etat de repos
					-- Attentdre d'une demande de travail 
					if en = '1' then
						ss <= '0';
						busy <= '1';
						-- Une durée de depart de 15µs
						dureeAttente := ATTENTE_DEPART;
						noOctet := 1;
						etat <= attente;
					end if;
					
				when echange => -- Etat d'échange
					en_er <= '0';
					if busy_er = '0' and en_er <= '0' then
						case noOctet is
							-- Echange de 1er Octet
							when 1 =>
								X(7 downto 0) <= dout_er;
								dureeAttente := EOATTENTE;
								noOctet := 2;
								etat <= attente;
							-- Echange de 2eme Octet
							when 2 =>
								X(9 downto 8) <= dout_er(1 downto 0);
								dureeAttente := EOATTENTE;
								noOctet := 3;
								etat <= attente;
							-- Echange de 3eme Octet
							when 3 =>
								Y(7 downto 0) <= dout_er;
								dureeAttente := EOATTENTE;
								noOctet := 4;
								etat <= attente;
							-- Echange de 4 Octet
							when 4 =>
								Y(9 downto 8) <= dout_er(1 downto 0);
								dureeAttente := EOATTENTE;
								noOctet := 5;
								etat <= attente;
							-- Echange de 5 Octet
							when 5 =>
								btn2 <= dout_er(2);
								btn1 <= dout_er(1);
								btnJ <= dout_er(0);
								
								ss <= '1';
								busy <= '0';
								etat <= repos;
								
							when others => null;
						end case;
					end if;
				
				when attente => -- Etat d'attente
					if dureeAttente = 0 then
						case noOctet is
							-- Le premier Octet envoyé par le MasterJoystick est : "000000"&led1&led2
							when 1 => 
								din_er <= (0 => led1, 1 => led2, 7 => '1', others => '0');
							-- Les autres Octets sont ignorés par le Joystick
							when others =>
								din_er <= (others => '0');
						end case;
						
						en_er <= '1';
						etat <= echange;
					else 
						dureeAttente := dureeAttente - 1;
					end if;
					
			end case;
		end if;
	end process;

end Behavioral;

