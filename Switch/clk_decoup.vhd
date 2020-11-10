library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use ieee.numeric_std.all;
--use ieee.std_logic_arith.all 

 

entity clk_decoup is
   
    port
            (  reset_n		: IN std_logic;
               data		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
					rdclk		: IN STD_LOGIC ;
					wrclk		: IN STD_LOGIC ;
					q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
					overflow: std_logic;
					underrun: std_logic
              );
              
end clk_decoup;

architecture arch of clk_decoup is


COMPONENT clksync IS
		PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		rdempty		: OUT STD_LOGIC;
		rdusedw		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
		wrfull		: OUT STD_LOGIC ;
		wrusedw		: OUT STD_LOGIC_VECTOR (5 DOWNTO 0)
	);
END COMPONENT;


type statetype is (huntIFG, modifyIFG, passthrough);
SIGNAL rdstate: statetype;
SIGNAL wrstate: statetype;

SIGNAL rdreq		:  STD_LOGIC;
SIGNAL wrreq		:  STD_LOGIC;
SIGNAL rdempty		:  STD_LOGIC;
SIGNAL rdusedw		:  STD_LOGIC_VECTOR (5 DOWNTO 0);
SIGNAL wrfull		:  STD_LOGIC;
SIGNAL wrusedw		:  STD_LOGIC_VECTOR (5 DOWNTO 0);
SIGNAL q_int		:	STD_LOGIC_VECTOR(8 downto 0);


BEGIN

q<=q_int;

--Generate the FIFO
fifo:clksync
	port map(not(reset_n),data, rdclk, rdreq, wrclk, wrreq, q_int, rdempty,rdusedw,wrfull,wrusedw);
	
	

Read_control: process(rdclk,reset_n)
begin


	if(reset_n='0') then
		rdreq<='0';
		rdstate<=huntIFG;
	
	elsif(rising_edge(rdclk)) then
	
		case rdstate is
		
			when huntIFG =>
				rdreq<='1';
				rdstate<=huntIFG;
				if(q_int(8)='0') then --we have found an idle sequence
					rdstate<=modifyIFG;
				end if;			
			
			when modifyIFG =>
				if(rdusedw<12) then --stop readout until FIFO level is >= 12
					rdreq<='0';
					rdstate<=modifyIFG;
				else
					rdreq<='1';
					rdstate<=passthrough;
				end if;
			
			when passthrough =>
				rdstate<=passthrough;
				rdreq<='1';
				if(q_int(8)='0') then --we have found an idle sequence
					rdstate<=modifyIFG;
				end if;
			
			
			when others =>
				rdstate<=huntIFG;
		end case;
	
	end if;

 
end process;



Write_control: process(wrclk,reset_n)
begin


	if(reset_n='0') then
		wrreq<='0';
		wrstate<=huntIFG;
		
	elsif(rising_edge(wrclk)) then
	
		case wrstate is
		 
			when huntIFG =>
				wrreq<='1';
				wrstate<=huntIFG;
				if(data(8)='0') then --we have found an idle sequence
					wrstate<=modifyIFG;
				end if;			
			
			when modifyIFG =>
				if(wrusedw>20 and data(8)='0') then	--delete idle chars to reduce FIFO level (<=20)
					wrreq<='0';
					wrstate<=modifyIFG;
				else
					wrreq<='1';
					wrstate<=passthrough;
				end if;
			
			when passthrough =>
				wrstate<=passthrough;
				wrreq<='1';
				if(data(8)='0') then --we have found an idle sequence
					wrstate<=modifyIFG;
				end if;
			
			
			when others =>
				wrstate<=huntIFG;
			
		end case;
	
	end if;


end process;

 
 
 
 end arch;