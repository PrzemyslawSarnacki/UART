-- Odbiornik UART: 8b+1b, 16 x oversampling, 115200 bps library Ieee; use ieee.std_logic_1164.all; use ieee.numeric_std.all; 
library Ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all; 


entity uart_receiver is port (
	RxD_i : in std_logic;
	clk50_i : in std_logic;
	rst_i : in std_logic;
	buf_o : out std_logic_vector(7 downto 0) := (others => '0'));
end uart_receiver;

architecture behavioral of uart_receiver is signal clkOversampling_s : std_logic := '1';
	signal buf_s : std_logic_vector(7 downto 0) := (others => '0');
	type state_type is (st_idle, st_start, st_data, st_stop); --określenie stanu automatu
	signal state : state_type:=st_idle; 

	signal cnt_o : integer range 0 to 15 := 0; --licznik taktów zegara próbkującego 
	signal cnt_b : integer range 0 to 7 := 0; --licznik bitów danych 

begin

	-- dzielnik częstotliwości  
	p_divider : process (clk50_i) variable cnt : integer range 0 to 162;
	begin
		--czas trwania stanu logicznego L lub H równy połowie okresu: (50MHz/16*115200)/2=14   
		if rising_edge(clk50_i) then
			if cnt < 13 then
				cnt := cnt + 1;
			else cnt := 0;
				clkOversampling_s <= not clkOversampling_s;
			end if;
		end if;
	end process;

	-- automat stanu  
	p_FSM_comb : process (clkOversampling_s, RxD_i, rst_i) begin if rst_i = '0' then
		state <= st_idle;
		buf_s <= (others => '0');
		buf_o <= (others => '0');
		cnt_o <= 0;
		cnt_b <= 0;
	elsif rising_edge(clkOversampling_s) then
		case state is when st_idle => if RxD_i = '0' then
				--wystąpienie bitu Start       
				state <= st_start;
		end if;
		when st_start => if cnt_o = 7 then --znajdź środek bitu start (ósmy takt zegara próbkującego)   
		state <= st_data;
		cnt_o <= 0;
	else cnt_o <= cnt_o + 1;
	end if;
	when st_data => if cnt_o = 15 then --znajdź środek bitu danych (co szesnasty takt zegara próbkującego)  
	cnt_o <= 0;
	buf_s <= RxD_i & buf_s(7 downto 1); -- rejestr przesuwajajacy (LSB first)
	if cnt_b < 7 then
		cnt_b <= cnt_b + 1;
	else state <= st_stop;
		cnt_b <= 0;
	end if;
else cnt_o <= cnt_o + 1;
end if;
when st_stop =>
 buf_o <= buf_s;
if cnt_o = 15 then
	--odczekaj czas równy 1-bitowi (16 taktów zegara próbkującego)       
	state <= st_idle;
	cnt_o <= 0;
else cnt_o <= cnt_o + 1;
end if;
end case;
end if;
end process;
end behavioral;