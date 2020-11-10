library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity switchcore is

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

end switchcore;

architecture arch of switchcore is



BEGIN


internalloop:	process(clk, reset)
begin

	if(reset='0') then
		tx_data(7 downto 0)<=(others=>'0');
		tx_data(15 downto 8)<=(others=>'0');
		tx_ctrl(0)<='0';
		tx_ctrl(1)<='0';
	
	elsif(rising_edge(clk)) then

		tx_data(7 downto 0)<=rx_data(15 downto 8);
		tx_data(15 downto 8)<=rx_data(7 downto 0);
		tx_ctrl(0)<=rx_ctrl(1);
		tx_ctrl(1)<=rx_ctrl(0);
	end if;
	
end process;






END arch;

