
library Ieee; 
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 
 
entity uart_transmitter is port ( 
    buf_i : in std_logic_vector(8 downto 0):=(others=>'0'); -- 8-bitowe wejscie	
    clk50_i : in std_logic;  											-- wejscie clk
    rst_i : in std_logic;  											-- zerowanie 
    key	: in std_logic;
    TxD : out std_logic  -- -- wyjscie nadawanych danych, state na linii transmisyjnej
 ); 
 
end uart_transmitter; 
 
architecture behavioral of uart_transmitter is 

    signal transmission_rate : STD_LOGIC:='0';
    signal buf_s : std_logic_vector(8 downto 0):=(others=>'0');  
    type state_type is (st_idle, st_start, st_data, st_stop); 
    signal state : state_type:=st_idle;   
    signal cnt_b : integer range 0 to 8:=0;  --licznik bitów danych 
begin 
 --dzielnik częstotliwości  
p_divider: process(clk50_i) variable cnt : integer range 0 to 162;  

begin 	
    if rising_edge(clk50_i) then    
        if cnt<8 then      
            cnt:=cnt+1;            
        else    
            cnt:=0;  
        end if;  
    end if;   
end process; 
  
process(transmission_rate, buf_i, rst_i, key)
begin   
    if rst_i='0' then
        state<=st_idle;    
        buf_s<=(others=>'0');
        TxD<='0';       
        cnt_b<=0;   
    elsif rising_edge(transmission_rate) then   	
        case state is     
            when st_idle =>
                    if key='0' then   
                        state<=st_start;  
                        TxD<='1';			
                    else state<=st_idle; 
                        TxD<='1';
                    end if;     
                        
            when st_start =>      
                TxD<='0';
                state<=st_data;      
                    
            when st_data => 
                TxD<=buf_i(cnt_b);		
                if cnt_b<8 then 
                    cnt_b<=cnt_b+1;       
                else       
                    state<=st_stop;    
                    cnt_b<=0;     
                end if;   
            when st_stop =>     
                TxD<='1';      
                state<=st_idle;      
        end case;
    end if;
 
end process; 
 
end behavioral;
