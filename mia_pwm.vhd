library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PWM is
--    generic(
-----    clock_sys:integer:=10000;  -- ipotetico clock del sistema, è basso per ragioni di tempi di simulazione
--    freq_mod:integer:=1000 --Hz (inserire qui la frequenza di modulazione desiderata in Hertz. ATTENZIONE, viene considerato un clock ad 10kHz)
--    );
    port(
        clock : in std_logic; -- per quanto avrebbe più senso metterlo nel generic, per simularlo in gtkwave mi serve come porta per dargli l'impulso
        duty_in : in signed (7 downto 0); -- è il segnale che arriva dalla PI come duty
        dir : out std_logic; -- segnale da inviare al bridge per scegliere la direzione del motore
        out_signal: out std_logic -- segnale in uscita dalla pwm
         
    );
end entity;

architecture struct of PWM is
    signal clock_sys:integer:=10000;
    signal freq_mod:integer:=1000;
    signal portante : unsigned (6 downto 0) :="0000000";
    signal sigreal : unsigned (7 downto 0);
    signal counter : integer:=0;
    signal invert : signed (7 downto 0);
    signal value : integer;
    -- constant only_ones : signed (7 downto 0) :="11111111";

begin
    process (clock, duty_in) is
        begin
        value<=clock_sys/freq_mod;
        if duty_in<0 then
            invert<= not duty_in; -- faccio il complemento ad 1 per i numeri negativi, in questo modo specchio le due porzioni di valori positivi e negativi
            sigreal<=unsigned(invert);
            --sigreal<=unsigned(abs(duty_in))+1; -- questo praticamente dovrebbe convertire il numero negativo in complemento a 2 nel suo corrispettivo positivo
            dir<='0';-- ipoteticamente se il numero è negativo, il motore gira in senso antiorario
        else
            sigreal<=unsigned(duty_in);
            dir<='1';--se è positivo e quindi gira in senso orario
        end if;
        if rising_edge(clock) then  -- rising_edge è un altro modo di scrivere tick'event and tick='1'
            presc : for i in 1 to value loop
                counter<=counter+1;
            end loop ; --

            portante<= portante +1;
            if sigreal> portante then
                out_signal<='1';
            else
                out_signal<='0';
            end if;
        end if;
           
    end process;
end architecture;