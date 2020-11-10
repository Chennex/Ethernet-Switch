library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity switch_top is
port (
	clk_100 : in std_logic;
	reset_n : in std_logic;
	tx:	out std_logic_vector(3 downto 0);
	rx:	in std_logic_vector(3 downto 0);
	mdc:  out std_logic_vector(3 downto 0);	--	MDIO clock(s)
	mdio: inout std_logic_vector(3 downto 0);	--MDIO data0-3
	int:	 inout std_logic_vector(3 downto 0); --MDIO interrupt 0-3
	rst:	 out std_logic;	--MDIO reset 0-3 (active low)
	--reset_phy_n:	out std_logic;
	reset_phy_in:	in std_logic;
	fan_ctrl:	out std_logic
	);
end switch_top;

architecture arch of switch_top is


COMPONENT switchcore is

	port
			(
				clk:			in	std_logic;
				reset:			in	std_logic;
				
				--Activity indicators
				link_sync:		in	std_logic_vector(3 downto 0);	--High indicates a peer connection at the physical layer. 
				
				--Four GMII interfaces
				tx_data:			out	std_logic_vector(31 downto 0);	--(7 downto 0)=TXD0...(31 downto 24=TXD3)
				tx_ctrl:			out	std_logic_vector(3 downto 0);	--(0)=TXC0...(3=TXC3)
				rx_data:			in	std_logic_vector(31 downto 0);	--(7 downto 0)=RXD0...(31 downto 24=RXD3)
				rx_ctrl:			in	std_logic_vector(3 downto 0)	--(0)=RXC0...(3=RXC3)
			);

end COMPONENT;


COMPONENT transceivers is
   
    port
            (
              clk_in:          		in    	std_logic;
              clk_out:				out		std_logic;
              reset_n:        		in    	std_logic;
              
              --High indicates a peer connection at the physical layer. 
              link_sync:			out std_logic_vector(3 downto 0);	
                      
              --Parallel I/O
              tx_data_in:			in	std_logic_vector(31 downto 0);
              tx_ctrl_in:			in	std_logic_vector(3 downto 0);
              rx_data_out:			out	std_logic_vector(31 downto 0);
              rx_ctrl_out:			out	std_logic_vector(3 downto 0);
              
              --Serial I/O
              rx_datain: 			IN STD_LOGIC_VECTOR (3 DOWNTO 0);
              tx_dataout: 			OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
				  
				  mdc:  out std_logic_vector(3 downto 0);	--	MDIO clock(s)
				  mdio: inout std_logic_vector(3 downto 0);	--MDIO data0-3
				  int:	 inout std_logic_vector(3 downto 0) --MDIO interrupt 0-3
              );
              
end COMPONENT;
 

 -- Transceiver signals --
 SIGNAL clk_in:          		    	std_logic;
 SIGNAL clk_out:						std_logic;
 --High indicates a peer connection at the physical layer. 
 SIGNAL link_sync:			 std_logic_vector(3 downto 0);	
	 
 --Parallel I/O
 SIGNAL tx_data_in:				std_logic_vector(31 downto 0);
 SIGNAL tx_ctrl_in:				std_logic_vector(3 downto 0);
 SIGNAL rx_data_out:				std_logic_vector(31 downto 0);
 SIGNAL rx_ctrl_out:				std_logic_vector(3 downto 0);
 
 --Serial I/O
 SIGNAL rx_datain: 			STD_LOGIC_VECTOR (3 DOWNTO 0);
 SIGNAL tx_dataout: 			 STD_LOGIC_VECTOR (3 DOWNTO 0);
 
 SIGNAL fan_cnt:	integer range 0 to 999999;
 constant fan_speed: integer:=330000;--33% - this is the lowest possible setting...
 
begin
rst<=reset_phy_in;
-- Port maps --


sw_core:switchcore
	port map(clk_out,reset_n,link_sync,tx_data_in,tx_ctrl_in,rx_data_out,rx_ctrl_out);
	
GEx4: transceivers
	port map(clk_100, clk_out, reset_n, link_sync, tx_data_in, tx_ctrl_in, rx_data_out, rx_ctrl_out, rx, tx, mdc, mdio, int);


fan:	process(clk_out, reset_n)
begin

	if(reset_n='0') then
		fan_cnt<=0;
	
	elsif(rising_edge(clk_out)) then
		
		if(fan_cnt<999999) then
			fan_cnt<=fan_cnt+1;
		else
			fan_cnt<=0;
		end if;
		
		
		if(fan_cnt<fan_speed) then
			fan_ctrl<='1';
		else
			fan_ctrl<='0';
		end if;
	
	end if;


end process;	



end arch;