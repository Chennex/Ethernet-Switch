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
linkSyncA :  in std_logic_vector(3 downto 0);
reset : 	in std_logic;
--MAC Learning connections
portIn : in std_logic_vector(3 downto 0);
portWrEn : in std_logic_vector(3 downto 0);
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
end FCSBlockTop;

architecture arch of FCSBlockTop is
--Component assignments --

component fcs_check_parallel
port(
	clk            : IN std_logic;                      -- system clock
	reset          : IN std_logic;                      -- asynchronous reset
	write_enable   : OUT std_logic;                     -- Data on output
	data_in        : IN std_logic_vector(8 DOWNTO 0);   -- serial input data.
	fcs_error      : OUT std_logic                      -- indicates an error.
	);
end component;

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

component FiFoErrors
	PORT
	(
		clock		: IN STD_LOGIC ;
		data		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
		rdreq		: IN STD_LOGIC ;
		sclr		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		empty		: OUT STD_LOGIC ;
		full		: OUT STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
		usedw		: OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
	);
end component;

--Signal assignments.--
--Misc signals--
signal counterA : integer := 0;
signal counterB : integer := 0;
signal counterC : integer := 0;
signal counterD : integer := 0;


signal errorWriteEnable : std_logic_vector(3 downto 0) := (others => '0');
signal startWriting :std_logic_vector(3 downto 0) := (others => '0');
signal linkSync : std_logic_vector(3 downto 0) := (others => '0');
signal linkSyncB : std_logic_vector(3 downto 0) := (others => '0');

signal deadEnd : std_logic_vector(8 downto 0);
--Incoming signals.
signal SoF : std_logic_vector(3 downto 0) := (others => '0');		--Start of Frame FCS needs to be changed to not need this.
signal EoF : std_logic_vector(3 downto 0) := (others => '0');
--Error handling signals.
signal fcs_error : std_logic_vector(3 downto 0) := (others => '0');	--Input to FCS error fifos.
signal fcs_error_out : std_logic_vector(3 downto 0) := (others => '0');	--Output of FCS error fifos.

signal wreqErr : std_logic_vector(3 downto 0) := (others => '0');	--Write enable signal for err Fifo
signal rreqErr : std_logic_vector(3 downto 0) := (others => '0');	-- Read enable
signal emptyErr : std_logic_vector(3 downto 0) := (others => '0');
signal fullErr : std_logic_vector(3 downto 0) := (others => '0');
signal usedWErr : std_logic_vector(19 downto 0) := (others => '0');	-- number of used words.

signal packetErrorState : std_logic_vector(3 downto 0) := (others => '0'); --Switches to 1 for whole packet if erred.
signal waitForError : std_logic_vector(3 downto 0) := (others => '0');		--If 0, ignore packetErrorState.
--Packet Signals
signal packetDoneFlag : std_logic_vector(3 downto 0) := (others => '0');
signal emptyPack : std_logic_vector(3 downto 0) := (others => '0');
signal fullPack : std_logic_vector(3 downto 0) := (others => '0');
signal wrreqPack : std_logic_vector(3 downto 0) := (others => '0');
signal rdreqPack : std_logic_vector(3 downto 0) := (others => '0');
signal usedWPack : std_logic_vector(43 downto 0) := (others => '0');
signal readDataA : std_logic_vector(8 downto 0) := (others => '0');
signal readDataB : std_logic_vector(8 downto 0) := (others => '0');
signal readDataC : std_logic_vector(8 downto 0) := (others => '0');
signal readDataD : std_logic_vector(8 downto 0) := (others => '0');

signal regA : std_logic_vector(7 downto 0) := (others => '0');
signal regB : std_logic_vector(7 downto 0) := (others => '0');
signal regC : std_logic_vector(7 downto 0) := (others => '0');
signal regD : std_logic_vector(7 downto 0) := (others => '0');
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
signal crossOutA : std_logic_vector(8 downto 0) := (others => '0');
signal crossOutB : std_logic_vector(8 downto 0) := (others => '0');
signal crossOutC : std_logic_vector(8 downto 0) := (others => '0');
signal crossOutD : std_logic_vector(8 downto 0) := (others => '0');

begin
wreqErr <= EoF;	--Enable write if the end of frame is written.
wrreqPack <= linkSync;
wportCross <= portIn;



--Start of frame logic.
SoFDeterminer : process( linkSync, SoF )
begin
	if rising_edge(linkSync(0)) then
		SoF(0) <= linkSync(0);
	else
		SoF(0) <= '0';
	end if;
	if rising_edge(linkSync(1)) then
		SoF(1) <= linkSync(1);
	else
		SoF(1) <= '0';
	end if;
	if rising_edge(linkSync(2)) then
		SoF(2) <= linkSync(2);
	else
		SoF(2) <= '0';
	end if;
	if rising_edge(linkSync(3)) then
		SoF(3) <= linkSync(3);
	else
		SoF(3) <= '0';
	end if;
end process ; -- SoFDeterminer

--PacketDone logic.
--Packet is finished once the sync signal goes to 0. Given the last 1 comes together with the last packet,
--data needs to be delayed by one cycle to match know packet is done.

packetDelay : process( clk )
begin	
		if(rising_edge(clk)) then
			linkSyncB <= linkSyncA;
			linkSync <= linkSyncB;
			if(linkSyncB(0) = '1') then
				regA <= inputA;
			end if;
			if(linkSync(1) = '1') then
				regB <= inputB;
			end if;
			if(linkSync(2) = '1') then
				regC <= inputC;
			end if;
			if(linkSync(3) = '1') then
				regD <= inputD;
			end if;
		end if;
		

end process ; -- packetDelay

--Error Detection.
errorDetect : process( clk )
begin
	if rising_edge(clk) then
		if EoF(0) = '1' then
			packetErrorState(0) <= fcs_error_out(0);
			waitForError(0) <= '1';
		end if ;
		if EoF(1) = '1' then
			packetErrorState(1) <= fcs_error_out(1);
			waitForError(1) <= '1';
		end if ; 
		if EoF(2) = '1' then
			packetErrorState(2) <= fcs_error_out(2);
			waitForError(2) <= '1';
		end if ; 
		if EoF(3) = '1' then
			packetErrorState(3) <= fcs_error_out(3);
			waitForError(3) <= '1';
		end if ; 
	end if;
end process ; -- errorDetect
--Read data out. Discard if FCS error (read from FCS FiFo) is high.
readOut : process (clk)
begin
	if rising_edge(clk) then
		--Enable error list read if not empty, or current packet is not done.
		rreqErr <= not emptyErr and not startWriting;
		startWriting <= not packetDoneFlag and not emptyPack;
		--FCS1
		if(((packetErrorState(0) = '0' and waitForError(0) = '1') or EoF(0) = '0') and startWriting(0) = '1' and portWrEn(0) = '1') then
			rdreqPack(0) <= '1';
			outA <= readDataA;
			packetDoneFlag(0) <= readDataA(8);
			if(counterA >= 7 AND counterA <= 13) then --Dest MAC is from bytes 7 to 13.
			MACReadOut1(47 downto 8) <= MACReadOut1(39 downto 0);
			MACReadOut1(7 downto 0) <= readDataA(7 downto 0);
                --dst1(8 * counter - 8 downto 1 * counter -8) <= readDataA;
            end if;
            if counterA >= 14 AND counterA <= 20 then
                MACReadOut1S(47 downto 8) <= MACReadOut1S(39 downto 0);
                MACReadOut1S(7 downto 0) <= readDataA(7 downto 0);
                --src1(8 * counter - 15 downto 1 * counter -15) <= readDataA;
			end if;
			if counterA = 21 then
				dst1 <= MACReadOut1;
				src1 <= MACReadOut1S;
			end if;
			else
			rdreqPack(0) <= '0';
		end if;
		if(((packetErrorState(1) = '0' and waitForError(1)= '1') or EoF(1) = '0') and startWriting(1) = '1' and portWrEn(1) = '1') then
			rdreqPack(1) <= '1';
			outB <= readDataB;
			packetDoneFlag(1) <= readDataB(8);
			if(counterB >= 7 AND counterB <= 13) then --Dest MAC is from bytes 7 to 13.
			MACReadOut2(47 downto 8) <= MACReadOut2(39 downto 0);
			MACReadOut2(7 downto 0) <= readDataB(7 downto 0);
                --dst1(8 * counter - 8 downto 1 * counter -8) <= readDataA;
            end if;
            if counterB >= 14 AND counterB <= 20 then
                MACReadOut2S(47 downto 8) <= MACReadOut2S(39 downto 0);
                MACReadOut2S(7 downto 0) <= readDataB(7 downto 0);
                --src1(8 * counter - 15 downto 1 * counter -15) <= readDataA;
			end if;
			if counterB = 21 then
				dst2 <= MACReadOut2;
				src2 <= MACReadOut2S;
			end if;
			else
			rdreqPack(1) <= '0';
		end if;
		if(((packetErrorState(2) = '0' and waitForError(2)= '1') or EoF(2) = '0')  and startWriting(2) = '1' and portWrEn(2) = '1') then
			rdreqPack(2) <= '1';
			outC <= readDataC;
			packetDoneFlag(2) <= readDataC(8);
			if(counterC >= 7 AND counterC <= 13) then --Dest MAC is from bytes 7 to 13.
			MACReadOut3(47 downto 8) <= MACReadOut3(39 downto 0);
			MACReadOut3(7 downto 0) <= readDataC(7 downto 0);
                --dst1(8 * counter - 8 downto 1 * counter -8) <= readDataA;
            end if;
            if counterC >= 14 AND counterC <= 20 then
                MACReadOut3S(47 downto 8) <= MACReadOut3S(39 downto 0);
                MACReadOut3S(7 downto 0) <= readDataD(7 downto 0);
                --src1(8 * counter - 15 downto 1 * counter -15) <= readDataA;
			end if;
			if counterC = 21 then
				dst3 <= MACReadOut3;
				src3 <= MACReadOut3S;
			end if;
			else
			rdreqPack(2) <= '0';		end if;
		if(((packetErrorState(3) = '0' and waitForError(3)= '1') or EoF(3) = '0')  and startWriting(3) = '1' and portWrEn(3) = '1') then
			rdreqPack(3) <= '1';
			outD <= readDataD;
			packetDoneFlag(3) <= readDataD(8);
			if(counterD >= 7 AND counterD <= 13) then --Dest MAC is from bytes 7 to 13.
			MACReadOut4(47 downto 8) <= MACReadOut4(39 downto 0);
			MACReadOut4(7 downto 0) <= readDataD(7 downto 0);
                --dst1(8 * counter - 8 downto 1 * counter -8) <= readDataA;
            end if;
            if counterD >= 14 AND counterD <= 20 then
                MACReadOut4S(47 downto 8) <= MACReadOut4S(39 downto 0);
                MACReadOut4S(7 downto 0) <= readDataD(7 downto 0);
                --src1(8 * counter - 15 downto 1 * counter -15) <= readDataA;
			end if;
			if counterD = 21 then
				dst4 <= MACReadOut4;
				src4 <= MACReadOut4S;
			end if;
			else
			rdreqPack(3) <= '0';
			end if;
	end if;
end process;

trashErredData : process( clk )
begin
	if rising_edge(clk) then
		if(packetErrorState(0) = '1' and EoF(0) = '1' and packetDoneFlag(0) = '0') then
			rdreqPack(0) <= '1';
			deadEnd <= readDataA;
			packetDoneFlag(0) <= readDataA(8);
		end if;
		if(packetErrorState(1) = '1' and EoF(1) = '1' and packetDoneFlag(1) = '0') then
			rdreqPack(1) <= '1';
			deadEnd <= readDataB;
			packetDoneFlag(1) <= readDataB(8);
		end if;
		if(packetErrorState(2) = '1' and EoF(2) = '1' and packetDoneFlag(2) = '0') then
			rdreqPack(2) <= '1';
			deadEnd <= readDataC;
			packetDoneFlag(2) <= readDataC(8);
		end if;
		if(packetErrorState(3) = '1' and EoF(3) = '1' and packetDoneFlag(3) = '0') then
			rdreqPack(3) <= '1';
			deadEnd <= readDataD;
			packetDoneFlag(3) <= readDataD(8);
		end if;
	end if ;
	
end process ; -- trashErredData


counterProc : process (clk)
begin
	if rising_edge(clk) then
		if startWriting(0) = '1' then
			counterA <= counterA + 1;
			if packetDoneFlag(0) = '1' then
				counterA <= 0;
			end if;
		end if;

		if startWriting(1) = '1' then
			counterB <= counterB + 1;
			if packetDoneFlag(0) = '1' then
				counterB <= 0;
			end if;
		end if;

		if startWriting(2) = '1' then
			counterC <= counterC + 1;
			if packetDoneFlag(0) = '1' then
				counterC <= 0;
			end if;
		end if;

		if startWriting(3) = '1' then
			counterD <= counterD + 1;
			if packetDoneFlag(0) = '1' then
				counterD <= 0;
			end if;
		end if;
		
	end if;
end process;
--Port Mapping--

--4 FCS modules.
FCS1 : fcs_check_parallel
port map(
	clk => clk,
	reset => reset,
	write_enable => EoF(0),
	data_in(7 downto 0) => regA,
	data_in(8) => linkSync(0),
	fcs_error => fcs_error(0)
	);
FCS2 : fcs_check_parallel
port map(
	clk => clk,
	reset => reset,
	write_enable => EoF(1),
	data_in(7 downto 0) => regB,
	data_in(8) => linkSync(1),
	fcs_error => fcs_error(1)
	);
FCS3 : fcs_check_parallel
port map(
	clk => clk,
	reset => reset,
	write_enable => EoF(2),
	data_in(7 downto 0) => regC,
	data_in(8) => linkSync(2),
	fcs_error => fcs_error(2)
	);
FCS4 : fcs_check_parallel
port map(
	clk => clk,
	reset => reset,
	write_enable => EoF(3),
	data_in(7 downto 0) => regD,
	data_in(8) => linkSync(3),
	fcs_error => fcs_error(3)
	);

--4 FiFoPacket
FiFoPack1 : FiFoPacket
port map(
	clock => clk,
	data(7 downto 0) => regA,
	data(8) => linkSyncA(0),
	rdreq => rdreqPack(0),
	sclr => reset,
	wrreq => wrreqPack(0),
	empty => emptyPack(0),
	full => fullPack(0),
	q => readDataA(8 downto 0),
	usedw => usedwPack(10 downto 0)
	);
FiFoPack2 : FiFoPacket
port map(
	clock => clk,
	data(7 downto 0) => regB,
	data(8) => linkSyncA(1),
	rdreq => rdreqPack(0),
	sclr => reset,
	wrreq => wrreqPack(1),
	empty => emptyPack(1),
	full => fullPack(1),
	q => readDataB(8 downto 0),
	usedw => usedwPack(21 downto 11)
	);
FiFoPack3 : FiFoPacket
port map(
	clock => clk,
	data(7 downto 0) => regC,
	data(8) => linkSyncA(2),
	rdreq => rdreqPack(0),
	sclr => reset,
	wrreq => wrreqPack(2),
	empty => emptyPack(2),
	full => fullPack(2),
	q => readDataC(8 downto 0),
	usedw => usedwPack(32 downto 22)
	);
FiFoPack4 : FiFoPacket
port map(
	clock => clk,
	data(7 downto 0) => regD,
	data(8) => linkSyncA(3),
	rdreq => rdreqPack(0),
	sclr => reset,
	wrreq => wrreqPack(3),
	empty => emptyPack(3),
	full => fullPack(3),
	q => readDataD(8 downto 0),
	usedw => usedwPack(43 downto 33)
	);
--TODO add 3 more after filling out all mapping.
--4 FiFoErr
FiFoErr1 : FiFoErrors
port map(
	clock => clk,
	data(0) => fcs_error(0),
	rdreq => rreqErr(0),
	sclr => reset,
	wrreq => wreqErr(0),
	empty => emptyErr(0),
	full => fullErr(0),
	q(0) => fcs_error_out(0),
	usedw => usedWErr(4 downto 0)
	);
FiFoErr2 : FiFoErrors
port map(
	clock => clk,
	data(0) => fcs_error(1),
	rdreq => rreqErr(1),
	sclr => reset,
	wrreq => wreqErr(1),
	empty => emptyErr(1),
	full => fullErr(1),
	q(0) => fcs_error_out(1),
	usedw => usedWErr(9 downto 5)
	);
FiFoErr3 : FiFoErrors
port map(
	clock => clk,
	data(0) => fcs_error(2),
	rdreq => rreqErr(2),
	sclr => reset,
	wrreq => wreqErr(2),
	empty => emptyErr(2),
	full => fullErr(2),
	q(0) => fcs_error_out(2),
	usedw => usedWErr(14 downto 10)
	);
FiFoErr4 : FiFoErrors
port map(
	clock => clk,
	data(0) => fcs_error(3),
	rdreq => rreqErr(3),
	sclr => reset,
	wrreq => wreqErr(3),
	empty => emptyErr(3),
	full => fullErr(3),
	q(0) => fcs_error_out(3),
	usedw => usedWErr(19 downto 15)
	);
end architecture;

