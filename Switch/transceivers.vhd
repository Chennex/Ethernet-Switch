library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--use ieee.numeric_std.all;
--use ieee.std_logic_arith.all 

 

entity transceivers is
   
    port
            (
              clk_in:          		in    	std_logic;
              clk_out:				out		std_logic;
              reset_n:        		in    	std_logic;
              
              --High indicates a peer connection at the physical layer. 
              link_sync:			out	std_logic_vector(3 downto 0);	
                            
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
              
end transceivers;

architecture Behavioral of transceivers is


COMPONENT tse IS
	PORT (
		gmii_rx_d	: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		gmii_rx_dv	: OUT STD_LOGIC;
		gmii_rx_err	: OUT STD_LOGIC;
		tx_clk	: OUT STD_LOGIC;
		rx_clk	: OUT STD_LOGIC;
		led_an	: OUT STD_LOGIC;
		led_disp_err	: OUT STD_LOGIC;
		led_char_err	: OUT STD_LOGIC;
		led_link	: OUT STD_LOGIC;
		rx_recovclkout	: OUT STD_LOGIC;
		readdata	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		waitrequest	: OUT STD_LOGIC;
		txp	: OUT STD_LOGIC;
		gmii_tx_d	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		gmii_tx_en	: IN STD_LOGIC;
		gmii_tx_err	: IN STD_LOGIC;
		reset_tx_clk	: IN STD_LOGIC;
		reset_rx_clk	: IN STD_LOGIC;
		address	: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
		read	: IN STD_LOGIC;
		writedata	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		write	: IN STD_LOGIC;
		clk	: IN STD_LOGIC;
		reset	: IN STD_LOGIC;
		rxp	: IN STD_LOGIC;
		ref_clk	: IN STD_LOGIC
	);
END COMPONENT;

type fourX8 is array (3 downto 0) of STD_LOGIC_VECTOR (7 DOWNTO 0);
type fourX16 is array (3 downto 0) of STD_LOGIC_VECTOR (15 DOWNTO 0);

SIGNAL gmii_rx_d	:  fourX8;
SIGNAL gmii_rx_dv	: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL gmii_rx_err	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL tx_clk	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL rx_clk	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL led_an	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL led_disp_err	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL led_char_err	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL led_link	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL rx_recovclkout	:  STD_LOGIC_VECTOR(3 DOWNTO 0);

SIGNAL readdata	:  fourX16;
SIGNAL waitrequest	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL tx	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL gmii_tx_d	:  fourX8;
SIGNAL gmii_tx_en	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL gmii_tx_err	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL reset_tx_clk	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL reset_rx_clk	:  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL address	:  STD_LOGIC_VECTOR (4 DOWNTO 0);
SIGNAL read	:  STD_LOGIC;
SIGNAL writedata	:  STD_LOGIC_VECTOR (15 DOWNTO 0);
SIGNAL write	:  STD_LOGIC;
SIGNAL rx	:  STD_LOGIC_VECTOR(3 DOWNTO 0);


COMPONENT clk_decoup is  
    port
            (
					reset_n		: IN std_logic;
               data		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
					rdclk		: IN STD_LOGIC ;
					wrclk		: IN STD_LOGIC ;
					q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
					overflow: std_logic;
					underrun: std_logic
              );
              
end COMPONENT;


COMPONENT prb IS
	PORT
	(
		probe		: IN STD_LOGIC_VECTOR (127 DOWNTO 0);
		source		: OUT STD_LOGIC_VECTOR (127 DOWNTO 0)
	);
END COMPONENT; 

SIGNAL probe: STD_LOGIC_VECTOR (127 DOWNTO 0);
SIGNAL source: STD_LOGIC_VECTOR (127 DOWNTO 0);

 COMPONENT clkgen IS
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';	--100MHz
		c0		: OUT STD_LOGIC ;					--125MHz	--for Ethernet transceivers
		c1		: OUT STD_LOGIC ;					--40MHz  -- for calibration block (cal_blk_clk)
		locked		: OUT STD_LOGIC 			-- is the PLL locked?
	);
END COMPONENT;

SIGNAL clk125:	std_logic;
SIGNAL clk50:	std_logic;


COMPONENT phy_setup is
port (
	clk 		: 		in std_logic;	
	reset_n : 		in std_logic;
	done_o:				out std_logic_vector(3 downto 0);	-- asserted when ALL MDIO accesses have been completed
	
	--Serial interface to MDIO (PHY)
	mdc_o:  out std_logic_vector(3 downto 0);	--MDIO clock
	mdio_o: inout std_logic_vector(3 downto 0);	--MDIO data
	int_o:	 inout std_logic_vector(3 downto 0) --not implemented
	);
end COMPONENT;	




type busarray is array(3 downto 0) of std_logic_vector(7 downto 0);
type occ_array is array (3 downto 0) of std_logic_vector(5 downto 0);


--SIGNALS--

SIGNAL tx_overflow 		:  STD_LOGIC_VECTOR(3 downto 0);
SIGNAL tx_underrun		:  STD_LOGIC_VECTOR(3 downto 0);
SIGNAL rx_overflow		:  STD_LOGIC_VECTOR(3 downto 0);
SIGNAL rx_underrun		:  STD_LOGIC_VECTOR(3 downto 0);


type fifobus is array(3 downto 0) of std_logic_vector(8 downto 0);

SIGNAL fifo_in_tx:		fifobus;
SIGNAL fifo_out_tx:		fifobus;

SIGNAL fifo_in_rx:		fifobus;
SIGNAL fifo_out_rx:		fifobus;
SIGNAL clk_out_int:		std_logic;
SIGNAL metastab_buf:	std_logic_vector(7 downto 0);
SIGNAL tx_full:	std_logic_vector(3 downto 0);
SIGNAL rx_full:	std_logic_vector(3 downto 0);


SIGNAL pcs_setup_ok:	std_logic;





begin

--Port maps--

--PLL for generating 125MHz and 40MHz signals
pll:	clkgen
	port map(clk_in,clk125,clk50,probe(9));


setup_phy:phy_setup
	port map (clk_in,reset_n,probe(36 downto 33), mdc, mdio,int);

					
--Generate the clock decouplers
decoup: for i in 0 to 3 generate
tx:clk_decoup
	port map(reset_n, fifo_in_tx(i), tx_clk(i), clk125, fifo_out_tx(i), tx_overflow(i), tx_underrun(i));

rx:clk_decoup
	port map(reset_n, fifo_in_rx(i), clk125, rx_clk(i), fifo_out_rx(i), rx_overflow(i), rx_underrun(i));
 end generate decoup;

--Transceiver port map
gx: for i in 0 to 3 generate
GE: tse
	port map(
		gmii_rx_d(i),
		gmii_rx_dv(i),
		gmii_rx_err(i),
		tx_clk(i),
		rx_clk(i),
		led_an(i),
		led_disp_err(i),
		led_char_err(i),
		led_link(i),

		rx_recovclkout(i),
		readdata(i),
		waitrequest(i),
		tx_dataout(i),
		gmii_tx_d(i),
		gmii_tx_en(i),
		gmii_tx_err(i),
		'0',--reset_tx_clk(i),
		'0',--reset_rx_clk(i),
		address,
		read,
		writedata,
		write,
		clk50,
		not(reset_n),
		rx_datain(i),		--rxp,
		clk125	--ref_clk
	);
end generate gx;


--Connect the clock
clk_out_int<=clk125;
clk_out<=clk_out_int;


--Connect the transceivers
              
------------- Connect the FIFOs ---------------
--TX direction
--Input	-- From the Switch core
fifo_in_tx(0)<=tx_ctrl_in(0) & tx_data_in(7 downto 0);
fifo_in_tx(1)<=tx_ctrl_in(1) & tx_data_in(15 downto 8);
fifo_in_tx(2)<=tx_ctrl_in(2) & tx_data_in(23 downto 16);
fifo_in_tx(3)<=tx_ctrl_in(3) & tx_data_in(31 downto 24);

--Output	--To the transceivers
gmii_tx_d(0)<=fifo_out_tx(0)(7 downto 0);		
gmii_tx_d(1)<=fifo_out_tx(1)(7 downto 0);
gmii_tx_d(2)<=fifo_out_tx(2)(7 downto 0);
gmii_tx_d(3)<=fifo_out_tx(3)(7 downto 0);
gmii_tx_en(0)<=fifo_out_tx(0)(8);
gmii_tx_en(1)<=fifo_out_tx(1)(8);
gmii_tx_en(2)<=fifo_out_tx(2)(8);
gmii_tx_en(3)<=fifo_out_tx(3)(8);

--RX direction
--Input	--From the transceivers
fifo_in_rx(0)<=gmii_rx_dv(0) & gmii_rx_d(0);
fifo_in_rx(1)<=gmii_rx_dv(1) & gmii_rx_d(1);
fifo_in_rx(2)<=gmii_rx_dv(2) & gmii_rx_d(2);
fifo_in_rx(3)<=gmii_rx_dv(3) & gmii_rx_d(3);

----Output	-- To the Switch core
Idle_gen: process(fifo_out_rx)--process for idle generation
begin	
	for i in 0 to 3 loop
			rx_data_out(7+i*8 downto i*8)<=fifo_out_rx(i)(7 downto 0);
			rx_ctrl_out(i)<=fifo_out_rx(i)(8);
	end loop;
end process;
---- End FIFO connection mapping --

address<="00000";	--control register
writedata<=x"0140"; --deactivate autoneg (default 1140=autoneg enabled)
read<='0';

PCS_setup: process(clk50, reset_n)
begin
	if(reset_n='0') then
		write<='0';
		pcs_setup_ok<='0';
	
	elsif(rising_edge(clk50)) then
		if(pcs_setup_ok='0') then
			write<='1';
			pcs_setup_ok<='1';
		else
			write<='0';
		end if;
	end if;
end process;


end behavioral;