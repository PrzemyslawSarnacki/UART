-- Copyright (C) 2019  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "04/23/2020 14:56:21"
                                                            
-- Vhdl Test Bench template for design  :  uart_transmitter
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                
use IEEE.numeric_std.all; -- use that, it's a better coding guideline


ENTITY uart_transmitter_vhd_tst IS
END uart_transmitter_vhd_tst;

ARCHITECTURE uart_transmitter_arch OF uart_transmitter_vhd_tst IS
-- constants
CONSTANT CLK50_PERIOD : time := 20 ns;      
CONSTANT BAUDE_RATE_PERIOD : time := 8.68 us; -- 1/baudeRate                                                  
-- signals                                                   
SIGNAL key : STD_LOGIC :='1';
SIGNAL rst_i : STD_LOGIC;
SIGNAL TxD : STD_LOGIC;
SIGNAL buf_i : STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL clk50_i : STD_LOGIC:='0';
SIGNAL transmission_rate : STD_LOGIC:='0';

COMPONENT uart_transmitter
PORT (
    key : IN STD_LOGIC;
    rst_i : IN STD_LOGIC;
    TxD : out STD_LOGIC;
    buf_i : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    clk50_i : IN STD_LOGIC
    );
END COMPONENT;

BEGIN
DUT : uart_transmitter
	PORT MAP (
-- list connections between master ports and signals
	key => key,
	rst_i => rst_i,
	TxD => TxD,
	buf_i => buf_i,
	clk50_i => clk50_i
	);

clk50_i<= not clk50_i after CLK50_PERIOD /2;  -- taktowanie modulu odbiornika 
transmission_rate<= not transmission_rate after BAUDE_RATE_PERIOD /2; -- clk50_i transmisji 

p_sentData : PROCESS   
procedure wait_transmission_rate is 
begin   
    wait until rising_edge(transmission_rate);  
end;   
 
procedure test_init is   
begin  
report("test rst_i");   
    rst_i<='1';
    buf_i<="000000000";   
    wait_transmission_rate;  
end; 
 
	
procedure sent_char (ascii_hex : std_logic_vector(7 downto 0)) is  
begin   
    for i in 0 to 3 loop
        if i=0 then   
            key<='0';
      
        elsif i=3 then 
            key<='1';	
        else      	
            buf_i<= (( ( (ascii_hex(0) xor ascii_hex(1)) xor (ascii_hex(2) xor ascii_hex(3)) xor (ascii_hex(4) xor ascii_hex(5)) xor (ascii_hex(6) xor ascii_hex(7)) ) ) & ascii_hex); -- dane
        end if;    
		  wait for CLK50_PERIOD*40;	  
    end loop;		
	
end; 
     
BEGIN   
 -- init    
test_init;   
wait for BAUDE_RATE_PERIOD;   
rst_i<='0';   
wait for BAUDE_RATE_PERIOD;   
rst_i<='1';   
wait for BAUDE_RATE_PERIOD;   


-- UART test - send data   

sent_char(ascii_hex=> X"53"); -- S    
wait for 2*BAUDE_RATE_PERIOD; 
sent_char(ascii_hex=> X"41"); -- A   
wait for 2*BAUDE_RATE_PERIOD; 
sent_char(ascii_hex=> X"52"); -- R
wait for 2*BAUDE_RATE_PERIOD; 
sent_char(ascii_hex=> X"4E"); -- N
wait for 2*BAUDE_RATE_PERIOD; 
sent_char(ascii_hex=> X"41"); -- A
wait for 2*BAUDE_RATE_PERIOD; 
sent_char(ascii_hex=> X"43"); -- C
wait for 2*BAUDE_RATE_PERIOD; 
sent_char(ascii_hex=> X"4B"); -- K
wait for 2*BAUDE_RATE_PERIOD; 
sent_char(ascii_hex=> X"49"); -- I

wait for BAUDE_RATE_PERIOD; 
 
std.env.stop;       
END PROCESS p_sentData; 


	
END uart_transmitter_arch;
