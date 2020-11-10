library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity mdio is
generic (clk_div_fact: integer:=1000);

port (
	clk 		: 		in std_logic;	
	reset_n : 		in std_logic;
	
	--Parallel interface (to MAC)
	data_in:			in std_logic_vector(15 downto 0);
	data_out: 		out std_logic_vector(15 downto 0);
	phy_addr: 		in std_logic_vector(4 downto 0);
	reg_addr: 		in std_logic_vector(4 downto 0);
	we:				in std_logic; 	--if '0', do read, if '1' do write
	start:			in std_logic;	-- assert to perform one MDIO access
	done:				out std_logic;	-- asserted when MDIO access has been completed, deasserted when "start" is detected
	
	--Serial interface to MDIO (PHY)
	mdc:  out std_logic;	--MDIO clock --from DC to 8.3MHz in Marvel 88E1111 Ethernet PHY chip
	mdio: inout std_logic;	--MDIO data
	int:	 inout std_logic --not implemented
	);
end mdio;

architecture arch of mdio is


type statetype is (idle, accs, read, write);

SIGNAL state: statetype;

SIGNAL clkdiv_cnt:	integer range 0 to (clk_div_fact/2)-1;
SIGNAL mdio_frame:	std_logic_vector(63 downto 0);
SIGNAL mdio_clk:		std_logic;
SIGNAL frame_cnt:		integer range 0 to 63;


begin

mdio_frame(63 downto 32)<=(others=>'1'); -- this is the MDIO preample
mdc<=mdio_clk;
int<='Z';

clk_div: process(clk,reset_n)
begin
	if(reset_n='0') then
		clkdiv_cnt<=0;
		mdio_clk<='0';
	elsif(rising_edge(clk)) then
	
		if(clkdiv_cnt=(clk_div_fact/2)-1) then
			clkdiv_cnt<=0;
			mdio_clk<=not(mdio_clk);
		else
			clkdiv_cnt<=clkdiv_cnt+1;
		end if;
	
	end if;

end process;


mdio_access: process(mdio_clk, reset_n)
begin


	if(reset_n='0') then
		done<='1';
		state<=idle;
		frame_cnt<=63;
		data_out<=(others=>'0');
		mdio<='1';
		mdio_frame(31 downto 0)<=(others=>'1');
	elsif(falling_edge(mdio_clk)) then	-- perform read/writes on the data bus on FALLING edges!
	
		case state is 
		
			when idle =>
				done<='1';
				mdio<='1';
				
				if(start='1') then
					done<='0';
				
					if(we='0') then	--perform read		start  read									TA(z0)    dummy data
						mdio_frame(31 downto 0)<=		"01" & "10" & phy_addr & reg_addr & "00"  & x"0000";
						
					else					--perform write	start  write							 TA(10)    write data
						mdio_frame(31 downto 0)<=		"01" & "01" & phy_addr & reg_addr & "10"  & data_in;
					end if;
					
					state<=accs;
				end if;		
					
				
			when accs =>
			
				mdio<=mdio_frame(frame_cnt);
				frame_cnt<=frame_cnt-1;
			
				if(frame_cnt=18) then
					if(we='0') then	--perform read
						state<=read;
					else					--perform write
						state<=write;
					end if;
				end if;
				
			when read =>
				mdio<='Z';
				
				if(frame_cnt<16) then
					data_out(frame_cnt)<=mdio;
				end if;
				
				if(frame_cnt=0) then
					frame_cnt<=63;
					state<=idle;
					done<='1';
				else
					frame_cnt<=frame_cnt-1;
				end if;
			
			when write =>
				mdio<=mdio_frame(frame_cnt);
				
				if(frame_cnt=0) then
					frame_cnt<=63;
					state<=idle;
					done<='1';
				else
					frame_cnt<=frame_cnt-1;
				end if;
			
			when others =>
				done<='1';
				state<=idle;
	
		end case;
		
	end if;


end process;





end arch;