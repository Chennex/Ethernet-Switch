library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.numeric_std.ALL;

entity tb_FIFO is
end entity tb_FIFO;

architecture behav of tb_FIFO is
	signal full,sclr,wrreq,rdreq,clock,empty: std_logic:='0';
	signal data: std_logic_vector(8 downto 0);
	signal q: std_logic_vector(8 downto 0);
	signal usedw: std_logic_vector(12 DOWNTO 0);
	signal halfperiod: time := 5 ns;
	component FIFOIP IS
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		sclr		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (12 DOWNTO 0)
	);
	END component FIFOIP;
	begin
	FIFO1: FIFOIP port map(clock,data,rdreq,sclr,wrreq,empty,full,q,usedw);
	process
	begin
    		clock <= not clock;
    		wait for halfperiod;
    		clock <= not clock;
    		wait for halfperiod;
	end process;
	wrreq<='1','0' after 40 ns;
	--rdreq<='0';
	data<="111111111", "000000000" after 10 ns, "111111111" after 20 ns;
	---data<="000000000" after 10 ns;
	---data<="111111111" after 20 ns;
	--data<="000000000" after 30 ns;
	---wrreq<='0' after 40ns;
	rdreq<='1' after 10 ns;
	
end behav;