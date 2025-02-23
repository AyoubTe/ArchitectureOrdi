library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MasterOpl is
  port ( rst : in std_logic;
         clk : in std_logic;
         en : in std_logic;
         v1 : in std_logic_vector (7 downto 0);
         v2 : in std_logic_vector(7 downto 0);
         miso : in std_logic;
         ss   : out std_logic;
         sclk : out std_logic;
         mosi : out std_logic;
         val_xor : out std_logic_vector (7 downto 0);
         val_and : out std_logic_vector (7 downto 0);
         val_or : out std_logic_vector (7 downto 0);
         busy : out std_logic);
end MasterOpl;

architecture behavior of MasterOpl is
	-- RAPPEl de Composant er_octet qui va être utilisé pour envoyer l'octet vers le slave
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
    -- Définition des états d'automate
    type t_etat is (repos, attente, echange);
	 -- Variables de travail
    signal etat : t_etat := repos;
	 -- Variables internes
    signal en_er : std_logic := '0';
    signal din_er : std_logic_vector(7 downto 0) := (others => 'U');
    signal dout_er : std_logic_vector(7 downto 0) := (others => 'U');
    signal busy_er : std_logic := 'U';
	 -- Registre pour stocker les valuers à transmettre vers l'esclave
    signal rg_v1 : std_logic_vector(7 downto 0) := (others => 'U');
    signal rg_v2 : std_logic_vector(7 downto 0) := (others => 'U');
    signal v : std_logic_vector(7 downto 0) := (others => 'U');
    
begin
	-- Instantiation de er_1octet
    Inst_er_1octet: er_1octet
        PORT MAP(
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
		  -- Variable utilisé pour le calcul de nombre des cycles
        variable cpt : natural := 0;
		  -- Numéro d'octet pour indiquer l'octet encore d'envoi
		  variable noOctet : natural := 0;
		  -- Duree d'attete au début d'échange nécessaire pour que le slave soit
        constant ATTENTE_DEPART : natural := 10;
			-- Inter Octets Attente : durée d'attente entre l'envoi de 2 octets
		  constant IOATTENTE : natural := 3;
    begin
			-- A l'arrivée d'une reset on remet tous à zero
        if (rst = '0') then
            ss <= '1';
            busy <= '0';
            val_xor <= (others => 'U'); 
            val_and <= (others => 'U');
            val_or <= (others => 'U');
            en_er <= '0';
            cpt := 0;
            etat <= repos;
				
        elsif (rising_edge(clk)) then
            case etat is 
                when repos =>
					 -- En cas de repos dès la reception d'un order de transimission
                    if en = '1' then
                        rg_v1 <= v1;
                        rg_v2 <= v2;
                        ss <= '0';
                        busy <= '1';
								-- En attend que l'esclave soit prêt
                        cpt := ATTENTE_DEPART;
								noOctet := 1;
                        etat <= attente;
                    end if;
					-- Cas d'attente
                when attente =>
                    if cpt = 0 then 
                        case noOctet is
									when 1 => 
										din_er <= rg_v1;
									when 2 => 
										din_er <= rg_v2;
									when others =>
										din_er <= (others => 'U');
								end case;
								en_er <= '1';
								etat <= echange;
                    else
                        cpt := cpt - 1;
                    end if;
					 -- cas d'echange  
                when echange =>
						  if busy_er = '0' and en_er = '0' then
							 case noOctet is
								when 1 =>
									val_xor <= dout_er;
									etat <= attente;
								when 2 =>
									val_and <= dout_er;
									etat <= attente;
								when 3 =>
									val_or <= dout_er;
									ss <= '1';
									busy <= '0';
									en_er <= '0';
									etat <= repos;
								when others => null;
							 end case;
							 noOctet := noOctet + 1;
							 cpt := IOATTENTE;
						  else
							 en_er <= '0';
						  end if;
            end case;    
        end if;
    end process;
end behavior;