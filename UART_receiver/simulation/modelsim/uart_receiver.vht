library ieee;
use ieee.std_logic_1164.all;

entity uart_receiver_vhd_tst is
end uart_receiver_vhd_tst;
architecture uart_receiver_arch of uart_receiver_vhd_tst is
	-- constants
	constant CLK50_PERIOD : time := 20 ns;
	constant BAUDE_RATE_PERIOD : time := 8.68 us; -- 1/baudeRate
	-- signals
	signal buf_o : STD_LOGIC_VECTOR(7 downto 0);
	signal clk50_i : STD_LOGIC := '0';
	signal baudeRate_s : STD_LOGIC := '0';
	signal rst_i : STD_LOGIC;
	signal RxD_i : STD_LOGIC;
	component uart_receiver
		port (
			buf_o : out STD_LOGIC_VECTOR(7 downto 0);
			clk50_i : in STD_LOGIC;
			rst_i : in STD_LOGIC;
			RxD_i : in STD_LOGIC
		);
	end component;
begin
	DUT : uart_receiver
	port map(
		buf_o => buf_o,
		clk50_i => clk50_i,
		rst_i => rst_i,
		RxD_i => RxD_i
	);
	clk50_i <= not clk50_i after CLK50_PERIOD /2; -- taktowanie modulu odbiornika
	baudeRate_s <= not baudeRate_s after BAUDE_RATE_PERIOD /2; -- zegar transmisji
	p_sentData : process
		procedure wait_baudeRate_edge is begin
			wait until rising_edge(baudeRate_s);
		end;
		procedure test_init is
		begin
			report("test reset");
			rst_i <= '1';
			RxD_i <= '1';
			wait_baudeRate_edge;
		end;
		procedure sent_char (ascii_hex : std_logic_vector(7 downto 0)) is
		begin
			for i in 0 to 10 loop
				if i = 0 then
					RxD_i <= '0'; -- bit start
				elsif i = 9 then
					RxD_i <= '1'; 
				elsif i = 10 then
					RxD_i <= '1'; -- bit stop
				else
					RxD_i <= ascii_hex(i - 1); -- dane
				end if;
				wait_baudeRate_edge;
			end loop;
		end;
	begin
		-- init
		test_init;
		wait for BAUDE_RATE_PERIOD;
		rst_i <= '0';
		wait for BAUDE_RATE_PERIOD;
		rst_i <= '1';
		wait for BAUDE_RATE_PERIOD;
		-- UART test - send data
		sent_char(ascii_hex => X"50"); -- P
		sent_char(ascii_hex => X"55"); -- U
		
		sent_char(ascii_hex => X"55"); -- U
		sent_char(ascii_hex => X"43"); -- C
		
		sent_char(ascii_hex => X"55"); -- U
		wait for BAUDE_RATE_PERIOD * 8;
		std.env.stop;
	end process p_sentData;
end uart_receiver_arch;