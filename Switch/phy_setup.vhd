library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity phy_setup is

port (
	clk 		: 		in std_logic;	
	reset_n : 		in std_logic;
	done_o:				out std_logic_vector(3 downto 0);	-- asserted when ALL MDIO accesses have been completed
	
	--Serial interface to MDIO (PHY)
	mdc_o:  out std_logic_vector(3 downto 0);	--MDIO clock
	mdio_o: inout std_logic_vector(3 downto 0);	--MDIO data
	int_o:	 inout std_logic_vector(3 downto 0) --not implemented
	);
end phy_setup;

architecture arch of phy_setup is





COMPONENT mdio is
generic (clk_div_fact: integer:=1000);

port (
	clk 		: 		in std_logic;	--from DC to 8.3MHz in Marvel 88E1111 Ethernet PHY chip
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
	mdc:  out std_logic;	--MDIO clock
	mdio: inout std_logic;	--MDIO data
	int:	 inout std_logic --not implemented
	);
end COMPONENT;


	--Parallel interface (to MAC)
SIGNAL data_in:			std_logic_vector(15 downto 0);
SIGNAL data_out: 			std_logic_vector(15 downto 0);
SIGNAL phy_addr: 			std_logic_vector(4 downto 0);
SIGNAL reg_addr: 			std_logic_vector(4 downto 0);
SIGNAL we:					std_logic; 	--if '0', do read, if '1' do write
SIGNAL start:				std_logic;	-- assert to perform one MDIO access
SIGNAL done:				std_logic;	-- asserted when MDIO access has been completed, deasserted when "start" is detected


constant num_regs: integer:=3;

type addr_array is array (num_regs-1 downto 0) of std_logic_vector(4 downto 0);
type data_array is array (num_regs-1 downto 0) of std_logic_vector(15 downto 0);

SIGNAL phyaddr,regaddr: 	addr_array;
SIGNAL data:					data_array;


type statetype is (go, wait_mdio, finished);
SIGNAL state: statetype;

SIGNAL cmd_cnt:	integer range 0 to num_regs-1;

BEGIN


phyaddr<=(others=>"00000");
regaddr<=(0=>"10110", 1=>"00000", 2=>"10110");
data<=(0=>x"0001", 1=>x"8140", 2=>x"0000");

mdio0: mdio
	port map(clk,reset_n,data_in,data_out,"00000",reg_addr,we,start,done,mdc_o(0),mdio_o(0),int_o(0));
mdio1: mdio
	port map(clk,reset_n,data_in,open,"00001",reg_addr,we,start,open,mdc_o(1),mdio_o(1),int_o(1));
mdio2: mdio
	port map(clk,reset_n,data_in,open,"00010",reg_addr,we,start,open,mdc_o(2),mdio_o(2),int_o(2));
mdio3: mdio
	port map(clk,reset_n,data_in,open,"00011",reg_addr,we,start,open,mdc_o(3),mdio_o(3),int_o(3));



Initialize: process(clk,reset_n)
begin


	if(reset_n='0') then
		state<=go;
		we<='1';
		start<='0';
		data_in<=(others=>'0');
		phy_addr<=(others=>'0');
		reg_addr<=(others=>'0');
		cmd_cnt<=0;
		done_o<=(others=>'0');
	elsif(rising_edge(clk)) then
	

		case state is
		
		
			when go =>
				start<='1';
				phy_addr<=phyaddr(cmd_cnt);
				reg_addr<=regaddr(cmd_cnt);
				data_in<=data(cmd_cnt);
				
				--wait for the mdio to acknowledge the start command
				if(done='0') then
					state<=wait_mdio;
					start<='0';
				else
					state<= go;
				end if;
			
			when wait_mdio =>
				
				-- wait for the mdio to finish processing the request..
				if(done='1') then
					state<=finished;
				else
					state<=wait_mdio;
				end if;
			
			when finished =>
			
				if(cmd_cnt<num_regs-1) then
					cmd_cnt<=cmd_cnt+1;
					state<=go;
				elsif(cmd_cnt=num_regs-1) then
					done_o<=(others=>'1');
					state<=finished;
				else
					state<=finished;
				end if;
				
						
			when others =>
				state<=finished;
			
		end case;
		
	end if;


end process;
	
	

end arch;
