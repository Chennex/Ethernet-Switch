library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.numeric_std.ALL;

entity FSM is
	port(
		clk: in std_logic;
		r_end0: in std_logic;
		empty0: in std_logic;
		rreq0: out std_logic;
		r_end1: in std_logic;
		empty1: in std_logic;
		rreq1: out std_logic;
		r_end2: in std_logic;
		empty2: in std_logic;
		rreq2: out std_logic;
		r_end3: in std_logic;
		empty3: in std_logic;
		rreq3: out std_logic;
		port_select: out std_logic_vector(1 downto 0)
	);
end entity FSM;

architecture behav of FSM is 
	signal RRcounter: std_logic_vector(1 downto 0):="00";
	begin
	process(clk)
	begin
		if(rising_edge(clk)) then
			if(RRcounter = 0) then
				IF( empty0='0') THEN
					if(r_end0 = '0') then
						port_select<="00";
						rreq0<='1';
						rreq1<='0';
						rreq2<='0';
						rreq3<='0';
					else
						port_select<="00";
						rreq0<='1';
						rreq1<='0';
						rreq2<='0';
						rreq3<='0';
						RRcounter <= RRcounter + 1;
					end if;
				else
					RRcounter<=RRcounter + 1;
					port_select<="00";
				END IF;
			elsif(RRcounter = 1) then
				IF(empty1='0') THEN
					if(r_end1 = '0') then
						port_select<="01";
						rreq0<='0';
						rreq1<='1';
						rreq2<='0';
						rreq3<='0';
					else
						port_select<="01";
						rreq0<='0';
						rreq1<='1';
						rreq2<='0';
						rreq3<='0';
						RRcounter <= RRcounter + 1;
					end if;
				ELSE
					RRcounter <= RRcounter + 1;
					port_select<="01";
				END IF;
			elsif(RRcounter = 2) then
				IF(empty2='0') THEN
					if(r_end2 = '0') then
						port_select<="10";
						rreq0<='0';
						rreq1<='0';
						rreq2<='1';
						rreq3<='0';
					else
						port_select<="10";
						rreq0<='0';
						rreq1<='0';
						rreq2<='1';
						rreq3<='0';
						RRcounter <= RRcounter + 1;
					end if;
				ELSE
					RRcounter <= RRcounter + 1;
					port_select<="10";
				END IF;
			else
				if(empty3 = '0') THEN
					if(r_end3 = '0') then
						port_select<="11";
						rreq0<='0';
						rreq1<='0';
						rreq2<='0';
						rreq3<='1';
					else
						port_select<="11";
						rreq0<='0';
						rreq1<='0';
						rreq2<='0';
						rreq3<='1';
						RRcounter <= RRcounter + 1;
					end if;
				ELSE 
					RRcounter <= RRcounter + 1;
					port_select<="11";
				END IF;
			end if;
		end if;
	end process;
end behav;