library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PI is
    generic(
        kP : integer := 1;
        kI : integer := 1;
        TOP_VALUE : signed (7 downto 0)             :="01111111";   -- +127
        MID1_VALUE : signed (7 downto 0)            :="01010000";   -- +80
        MID2_VALUE : signed (7 downto 0)            :="10110000";   -- -80
        BOT_VALUE : signed (7 downto 0)             :="10000000"    -- -128
    );
    port(
        riferimento : in signed (7 downto 0);
        feedback : in signed (7 downto 0);
        clock : in std_logic;
        uscita : out signed (7 downto 0)
    );
end entity;

architecture arch of PI is
    signal stato : std_logic_vector (1 downto 0);
    signal errore : signed (7 downto 0)             :="00000000"; 
    signal errore_cumulativo : signed (7 downto 0)  :="00000000"; 
    signal P : signed (7 downto 0)                  :="00000000";--
    signal I : signed (7 downto 0)                  :="00000000";--
    signal PI : signed (7 downto 0)                 :="00000000";--

    begin
        process (riferimento, feedback, clock) is
            begin
                if clock'event and clock='1'then
                    errore<= riferimento - feedback;
                    errore_cumulativo<=errore_cumulativo + errore;
                    P<=resize(errore * kP,P'length);
                    I<=resize(errore_cumulativo*kI,I'length);
                                                
                ---------- controllo dei limiti ---------------------
                end if;
                if clock'event and clock='0' then
                    PI<=resize(P+I,uscita'length);
                    if PI<= MID1_VALUE and PI>=MID2_VALUE then
                        stato<="00"; --                             -80<PI<80
                    elsif PI < MID2_VALUE then
                        stato<="01"; --                              PI<-80
                    elsif PI > MID1_VALUE then
                        stato<="10"; --                              PI> 80
                    end if;
                    
                    case stato is
                        when "00" => 
                            uscita<=PI;                 

                        when "01" =>
                            if PI+errore>0 then 
                                PI<=BOT_VALUE;
                               -- errore_cumulativo<=errore_cumulativo-errore;
                                errore<="00000000"; -- ti devi stare fermo o fai danni
                                uscita<=BOT_VALUE;
                            else
                                uscita<=PI;
                        end if;

                        when "10" =>
                            if PI+errore<0 then 
                                PI<=TOP_VALUE;
                              --  errore_cumulativo<=errore_cumulativo-errore;
                                errore<="00000000"; -- fermati o fai danni
                                uscita<=TOP_VALUE;
                            else
                                uscita<=PI;
                            end if;

                        when others =>
                            uscita<="00000000"; -- stato di sicurezza del motore
                    end case ;
                end if;
        end process;
end architecture;