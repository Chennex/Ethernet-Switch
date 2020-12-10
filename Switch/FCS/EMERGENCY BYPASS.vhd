--WEEWOO WEEWOO THIS IS NOT A DRILL, THIS IS A .VHD FILE.
--Removed the FCS from the FCS. Buffers a packet, sends MAC to MAC learning and data to Crossbar.
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

Entity EMERGENCYBYPASS is
port(
clk : 		in std_logic;
inputA :	in std_logic_vector(7 downto 0);
inputB : 	in std_logic_vector(7 downto 0);
inputC : 	in std_logic_vector(7 downto 0);
inputD : 	in std_logic_vector(7 downto 0);
linkSync : in std_logic_vector(3 downto 0);
reset : 	in std_logic;
--MAC Learning connections
WportMAC : 	out std_logic_vector(3 downto 0);
src1 : 		out std_logic_vector(47 downto 0);
dst1 : 		out std_logic_vector(47 downto 0);
src2 : 		out std_logic_vector(47 downto 0);
dst2 : 		out std_logic_vector(47 downto 0);
src3 : 		out std_logic_vector(47 downto 0);
dst3 : 		out std_logic_vector(47 downto 0);
src4 : 		out std_logic_vector(47 downto 0);
dst4 : 		out std_logic_vector(47 downto 0);


--Crossbar Connections. 9 bit long, last bit used to signify end of packet.
OutA : 			out std_logic_vector(8 downto 0);
OutB : 			out std_logic_vector(8 downto 0);
OutC : 			out std_logic_vector(8 downto 0);
OutD : 			out std_logic_vector(8 downto 0);
wportCross: 		out std_logic_vector(3 downto 0)


);
end EMERGENCYBYPASS;

architecture arch of EMERGENCYBYPASS is
--Component assignments --


component FiFoPacket
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		sclr		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
	);
end component;


--Signal assignments.--
--Misc signals--
signal counter : integer := 0;
signal startWriting :std_logic_vector(3 downto 0) := (others => '0');
--Incoming signals.
signal SoF : std_logic_vector(3 downto 0);
signal EoF : std_logic_vector(3 downto 0);

--Outgoing Singals
--Signals towards MAC Learning
signal MACReadOut1 : std_logic_vector(47 downto 0) := (others => '0');
signal MACReadOut2 : std_logic_vector(47 downto 0) := (others => '0');
signal MACReadOut3 : std_logic_vector(47 downto 0) := (others => '0');
signal MACReadOut4 : std_logic_vector(47 downto 0) := (others => '0');
signal MACActivePort : std_logic_vector(3 downto 0) := (others => '0');

signal MACReadOut1S : std_logic_vector(47 downto 0) := (others => '0');
signal MACReadOut2S : std_logic_vector(47 downto 0) := (others => '0');
signal MACReadOut3S : std_logic_vector(47 downto 0) := (others => '0');
signal MACReadOut4S : std_logic_vector(47 downto 0) := (others => '0');	

--Signals towards Crossbar
signal crossOutA : std_logic_vector(8 downto 0);
signal crossOutB : std_logic_vector(8 downto 0);
signal crossOutC : std_logic_vector(8 downto 0);
signal crossOutD : std_logic_vector(8 downto 0);

begin

--PacketDone logic.

--Read data out. Discard if FCS error (read from FCS FiFo) is high.
readOut : process (clk)
begin
	if rising_edge(clk) then
		--Enable error list read if not empty, or current packet is not done.
		startWriting <= linkSync;
		--FCS1
		if(startWriting(0) = '1') then
			wportCross(0) <= '1';
			outA(7 downto 0) <= inputA;
			outA(8) <= linkSync(0);
			if(counter >= 7 AND counter <= 13) then --Dest MAC is from bytes 7 to 13.
				dst1(8 * (counter -6) downto counter - 6) <= inputA;
			end if;
			if counter >= 14 AND counter <= 20 then
				src1 <= inputA;
			end if;
			else
			wportCross(0) <= '0';
		end if;
		if(startWriting(1) = '1') then
			wportCross(1) <= '1';
			outB(7 downto 0) <= inputB;
			outB(8) <= linkSync(1);
			if(counter >= 7 AND counter <= 13) then --Dest MAC is from bytes 7 to 13.
				dst2 <= inputB;
			end if;
			if counter >= 14 AND counter <= 20 then
				src2 <= inputB;
			end if;
			else
			wportCross(1) <= '0';
		end if;
		if(startWriting(2) = '1') then
			wportCross(2) <= '1';
			outC(7 downto 0) <= inputC;
			outC(8) <= linkSync(2);
			if(counter >= 7 AND counter <= 13) then --Dest MAC is from bytes 7 to 13.
				dst3 <= inputC;
			end if;
			if counter >= 14 AND counter <= 20 then
				src3 <= inputC;
			end if;
			else
			wportCross(2) <= '0';
		end if;
		if(startWriting(3) = '1') then
			wportCross(3) <= '1';
			outD(7 downto 0) <= inputD;
			outD(8) <= linkSync(3);
			if(counter >= 7 AND counter <= 13) then --Dest MAC is from bytes 7 to 13.
				dst4 <= inputD;
			end if;
			if counter >= 14 AND counter <= 20 then
				src4 <= inputD;
			end if;
			else
			wportCross(3) <= '0';
		end if;
	end if;
end process;



counterProc : process (clk)
begin
	if rising_edge(clk) then
		counter <= counter + 1;
		if counter > 20 then	--MAC source address ends at byte 20. 
			counter <= 0;
		end if;
	end if;
end process;
--Port Mapping--
end architecture;

