LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

Entity FCSBlockTop is
port(
clk : 		in std_logic;
inputA :	in std_logic_vector(7 downto 0);
inputB : 	in std_logic_vector(7 downto 0);
inputC : 	in std_logic_vector(7 downto 0);
inputD : 	in std_logic_vector(7 downto 0);

--MAC Learning connections
WportMAC : 	in std_logic_vector(3 downto 0);
src : 		out std_logic_vector(47 downto 0);
dst : 		out std_logic_vector(47 downto 0);

--Crossbar Connections. 9 bit long, last bit used to signify end of packet.
OutA : 		out std_logic_vector(8 downto 0);
OutB : 		out std_logic_vector(8 downto 0);
OutC : 		out std_logic_vector(8 downto 0);
OutD : 		out std_logic_vector(8 downto 0);
wportCross: 		out std_logic_vector(3 downto 0);

reset : 	in std_logic
);
end FCSBlockTop;

architecture arch of FCSBlockTop is
--Component assignments --

component fcs_check_parallel
port(
	clk            : IN std_logic;                      -- system clock
	reset          : IN std_logic;                      -- asynchronous reset
	start_of_frame : IN std_logic;                      -- arrival of the first bit.
	end_of_frame   : IN std_logic;                      -- arrival of the first bit in FCS.
	data_in        : IN std_logic_vector(7 DOWNTO 0);   -- serial input data.
	fcs_error      : OUT std_logic                      -- indicates an error.
	);
end component;
--Signal assignments.--

--Component connection vectors.
signal SoF : std_logic_vector(3 downto 0) := (others => '0');		--Start of Frame
signal EoF : std_logic_vector(3 downto 0) := (others => '0');		--End of Frame
signal data_in : std_logic_vector(31 downto 0) := (others => '0');
signal fcs_error : std_logic_vector(3 downto 0) := (others => '0');

begin





--Port Mapping--
FCS1 : fcs_check_parallel
port map(
	clk => clk,
	reset => reset,
	start_of_frame => SoF(0),
	end_of_frame => EoF(0),
	data_in => data_in(7 downto 0),
	fcs_error => fcs_error(0)
	);
FCS2 : fcs_check_parallel
port map(
	clk => clk,
	reset => reset,
	start_of_frame => SoF(1),
	end_of_frame => EoF(1),
	data_in => data_in(15 downto 8),
	fcs_error => fcs_error(1)
	);
FCS3 : fcs_check_parallel
port map(
	clk => clk,
	reset => reset,
	start_of_frame => SoF(2),
	end_of_frame => EoF(2),
	data_in => data_in(23 downto 16),
	fcs_error => fcs_error(2)
	);
FCS4 : fcs_check_parallel
port map(
	clk => clk,
	reset => reset,
	start_of_frame => SoF(3),
	end_of_frame => EoF(3),
	data_in => data_in(31 downto 24),
	fcs_error => fcs_error(3)
	);

end architecture;

