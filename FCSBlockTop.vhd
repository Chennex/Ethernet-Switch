LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

Entity FCSBlockTop is
port(
clk : in std_logic;
inputA : in std_logic_vector(7 downto 0);
inputB : in std_logic_vector(7 downto 0);
inputC : in std_logic_vector(7 downto 0);
inputD : in std_logic_vector(7 downto 0);

--MAC Learning connections
Wport : in std_logic_vector(3 downto 0);
src : out std_logic_vector(47 downto 0);
dst : out std_logic_vector(47 downto 0);

--Crossbar Connections. 9 bit long, last bit used to signify end of packet.
OutA : out std_logic_vector(8 downto 0);
OutB : out std_logic_vector(8 downto 0);
OutC : out std_logic_vector(8 downto 0);
OutD : out std_logic_vector(8 downto 0);
wport: out std_logic_vector(3 downto 0);

reset : in std_logic
);
end FCSBlockTop;

architecture of FCSBlockTop is
--Signal assignments.--

begin


end architecture;

