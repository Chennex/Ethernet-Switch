LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

ENTITY FCSBlockTop IS
    PORT (
        clk : IN std_logic;
        inputA : IN std_logic_vector(7 DOWNTO 0);
        inputB : IN std_logic_vector(7 DOWNTO 0);
        inputC : IN std_logic_vector(7 DOWNTO 0);
        inputD : IN std_logic_vector(7 DOWNTO 0);
        linkSyncA : IN std_logic_vector(3 DOWNTO 0);
        reset : IN std_logic;
        --MAC Learning connections
        portIn : IN std_logic_vector(3 DOWNTO 0);
        portWrEn : IN std_logic_vector(3 DOWNTO 0);
        WportMAC : OUT std_logic_vector(3 DOWNTO 0);

        src1 : OUT std_logic_vector(47 DOWNTO 0);
        dst1 : OUT std_logic_vector(47 DOWNTO 0);
        src2 : OUT std_logic_vector(47 DOWNTO 0);
        dst2 : OUT std_logic_vector(47 DOWNTO 0);
        src3 : OUT std_logic_vector(47 DOWNTO 0);
        dst3 : OUT std_logic_vector(47 DOWNTO 0);
        src4 : OUT std_logic_vector(47 DOWNTO 0);
        dst4 : OUT std_logic_vector(47 DOWNTO 0);
        --Crossbar Connections. 9 bit long, last bit used to signify end of packet.
        OutA : OUT std_logic_vector(8 DOWNTO 0);
        OutB : OUT std_logic_vector(8 DOWNTO 0);
        OutC : OUT std_logic_vector(8 DOWNTO 0);
        OutD : OUT std_logic_vector(8 DOWNTO 0);
        wportCross : OUT std_logic_vector(3 DOWNTO 0)
    );
END FCSBlockTop;

ARCHITECTURE arch OF FCSBlockTop IS
    --Component assignments --

    COMPONENT fcs_check_parallel
        PORT (
            clk : IN std_logic; -- system clock
            reset : IN std_logic; -- asynchronous reset
            write_enable : OUT std_logic; -- Data on output
            data_in : IN std_logic_vector(8 DOWNTO 0); -- serial input data.
            fcs_error : OUT std_logic -- indicates an error.
        );
    END COMPONENT;

    COMPONENT FiFoPacket
        PORT (
            clock : IN STD_LOGIC;
            data : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
            rdreq : IN STD_LOGIC;
            sclr : IN STD_LOGIC;
            wrreq : IN STD_LOGIC;
            empty : OUT STD_LOGIC;
            full : OUT STD_LOGIC;
            q : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
            usedw : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT FiFoErrors
        PORT (
            clock : IN STD_LOGIC;
            data : IN STD_LOGIC_VECTOR (0 DOWNTO 0);
            rdreq : IN STD_LOGIC;
            sclr : IN STD_LOGIC;
            wrreq : IN STD_LOGIC;
            empty : OUT STD_LOGIC;
            full : OUT STD_LOGIC;
            q : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
            usedw : OUT STD_LOGIC_VECTOR (4 DOWNTO 0)
        );
    END COMPONENT;

    --Signal assignments.--
    --Misc signals--
    SIGNAL counterA : INTEGER := 0;
    SIGNAL counterB : INTEGER := 0;
    SIGNAL counterC : INTEGER := 0;
    SIGNAL counterD : INTEGER := 0;
    SIGNAL errorWriteEnable : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL startWriting : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL linkSync : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL linkSyncB : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');

    SIGNAL deadEnd : std_logic_vector(8 DOWNTO 0);
    --Incoming signals.
    SIGNAL EoF : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    --Error handling signals.
    SIGNAL fcs_error : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0'); --Input to FCS error fifos.
    SIGNAL fcs_error_out : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0'); --Output of FCS error fifos.

    SIGNAL wreqErr : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0'); --Write enable signal for err Fifo
    SIGNAL rreqErr : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0'); -- Read enable
    SIGNAL emptyErr : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fullErr : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL usedWErr : std_logic_vector(19 DOWNTO 0) := (OTHERS => '0'); -- number of used words.

    SIGNAL packetErrorState : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0'); --Switches to 1 for whole packet if erred.
    SIGNAL waitForError : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0'); --If 0, ignore packetErrorState.
    --Packet Signals
    SIGNAL packetDoneFlag : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL emptyPack : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL fullPack : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wrreqPack : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL rdreqPack : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
    SIGNAL usedWPack : std_logic_vector(43 DOWNTO 0) := (OTHERS => '0');
    SIGNAL readDataA : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');
    SIGNAL readDataB : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');
    SIGNAL readDataC : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');
    SIGNAL readDataD : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');

    SIGNAL regA : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL regB : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL regC : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL regD : std_logic_vector(7 DOWNTO 0) := (OTHERS => '0');
    --Outgoing Singals
    --Signals towards MAC Learning
    SIGNAL MACReadOut1 : std_logic_vector(47 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MACReadOut2 : std_logic_vector(47 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MACReadOut3 : std_logic_vector(47 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MACReadOut4 : std_logic_vector(47 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MACActivePort : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');

    SIGNAL MACReadOut1S : std_logic_vector(47 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MACReadOut2S : std_logic_vector(47 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MACReadOut3S : std_logic_vector(47 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MACReadOut4S : std_logic_vector(47 DOWNTO 0) := (OTHERS => '0'); 

    --Signals towards Crossbar
    SIGNAL crossOutA : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');
    SIGNAL crossOutB : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');
    SIGNAL crossOutC : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');
    SIGNAL crossOutD : std_logic_vector(8 DOWNTO 0) := (OTHERS => '0');

BEGIN
    wreqErr <= EoF; --Enable write if the end of frame is written.
    wrreqPack <= linkSync;
    wportCross <= portIn;
    --PacketDone logic.
    --Packet is finished once the sync signal goes to 0. Given the last 1 comes together with the last packet,
    --data needs to be delayed by one cycle to match know packet is done.

    packetDelay : PROCESS (clk)
    BEGIN
        IF (rising_edge(clk)) THEN
            linkSyncB <= linkSyncA;
            linkSync <= linkSyncB;
            IF (linkSyncB(0) = '1') THEN
                regA <= inputA;
            END IF;
            IF (linkSync(1) = '1') THEN
                regB <= inputB;
            END IF;
            IF (linkSync(2) = '1') THEN
                regC <= inputC;
            END IF;
            IF (linkSync(3) = '1') THEN
                regD <= inputD;
            END IF;
        END IF;
 

    END PROCESS; -- packetDelay

    --Error Detection.
    errorDetect : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF EoF(0) = '1' THEN
                packetErrorState(0) <= fcs_error(0);
                --packetErrorState(0) <= fcs_error_out(0);
                waitForError(0) <= '1';
            END IF;
            IF EoF(1) = '1' THEN
                packetErrorState(1) <= fcs_error(1);
                --packetErrorState(1) <= fcs_error_out(1);
                waitForError(1) <= '1';
            END IF;
            IF EoF(2) = '1' THEN
                packetErrorState(2) <= fcs_error(2);
                --packetErrorState(2) <= fcs_error_out(2);
                waitForError(2) <= '1';
            END IF;
            IF EoF(3) = '1' THEN
                packetErrorState(3) <= fcs_error(3);
                --packetErrorState(3) <= fcs_error_out(3);
                waitForError(3) <= '1';
            END IF;
        END IF;
    END PROCESS; -- errorDetect
    --Read data out. Discard if FCS error (read from FCS FiFo) is high.
    readOut : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            --Enable error list read if not empty, or current packet is not done.
            rreqErr <= NOT emptyErr AND NOT startWriting;
            startWriting <= NOT packetDoneFlag AND NOT emptyPack;
            --FCS1
            IF (packetErrorState(0) = '0' AND startWriting(0) = '1' AND portWrEn(0) = '1' and waitForError(0) = '1') THEN
                rdreqPack(0) <= '1';
                outA <= readDataA;
                packetDoneFlag(0) <= readDataA(8);
                IF (counterA >= 7 AND counterA <= 13) THEN --Dest MAC is from bytes 7 to 13.
                    MACReadOut1(47 DOWNTO 8) <= MACReadOut1(39 DOWNTO 0);
                    MACReadOut1(7 DOWNTO 0) <= readDataA(7 DOWNTO 0);
                    --dst1(8 * counter - 8 downto 1 * counter -8) <= readDataA;
                END IF;
                IF counterA >= 14 AND counterA <= 20 THEN
                    MACReadOut1S(47 DOWNTO 8) <= MACReadOut1S(39 DOWNTO 0);
                    MACReadOut1S(7 DOWNTO 0) <= readDataA(7 DOWNTO 0);
                    --src1(8 * counter - 15 downto 1 * counter -15) <= readDataA;
                END IF;
                IF counterA = 21 THEN
                    dst1 <= MACReadOut1;
                    src1 <= MACReadOut1S;
                END IF;
            ELSE
                rdreqPack(0) <= '0';
            END IF;
            IF (packetErrorState(1) = '0' AND startWriting(1) = '1' AND portWrEn(1) = '1' and waitForError(1) = '1') THEN
                rdreqPack(1) <= '1';
                outB <= readDataB;
                packetDoneFlag(1) <= readDataB(8);
                IF (counterB >= 7 AND counterB <= 13) THEN --Dest MAC is from bytes 7 to 13.
                    MACReadOut2(47 DOWNTO 8) <= MACReadOut2(39 DOWNTO 0);
                    MACReadOut2(7 DOWNTO 0) <= readDataB(7 DOWNTO 0);
                    --dst1(8 * counter - 8 downto 1 * counter -8) <= readDataA;
                END IF;
                IF counterB >= 14 AND counterB <= 20 THEN
                    MACReadOut2S(47 DOWNTO 8) <= MACReadOut2S(39 DOWNTO 0);
                    MACReadOut2S(7 DOWNTO 0) <= readDataB(7 DOWNTO 0);
                    --src1(8 * counter - 15 downto 1 * counter -15) <= readDataA;
                END IF;
                IF counterB = 21 THEN
                    dst2 <= MACReadOut2;
                    src2 <= MACReadOut2S;
                END IF;
            ELSE
                rdreqPack(1) <= '0';
            END IF;
            IF (packetErrorState(2) = '0' AND startWriting(2) = '1' AND portWrEn(2) = '1' and waitForError(2) = '1') THEN
                rdreqPack(2) <= '1';
                outC <= readDataC;
                packetDoneFlag(2) <= readDataC(8);
                IF (counterC >= 7 AND counterC <= 13) THEN --Dest MAC is from bytes 7 to 13.
                    MACReadOut3(47 DOWNTO 8) <= MACReadOut3(39 DOWNTO 0);
                    MACReadOut3(7 DOWNTO 0) <= readDataC(7 DOWNTO 0);
                    --dst1(8 * counter - 8 downto 1 * counter -8) <= readDataA;
                END IF;
                IF counterC >= 14 AND counterC <= 20 THEN
                    MACReadOut3S(47 DOWNTO 8) <= MACReadOut3S(39 DOWNTO 0);
                    MACReadOut3S(7 DOWNTO 0) <= readDataD(7 DOWNTO 0);
                    --src1(8 * counter - 15 downto 1 * counter -15) <= readDataA;
                END IF;
                IF counterC = 21 THEN
                    dst3 <= MACReadOut3;
                    src3 <= MACReadOut3S;
                END IF;
            ELSE
                rdreqPack(2) <= '0';
            END IF;
            IF (packetErrorState(3) = '0' AND startWriting(3) = '1' AND portWrEn(3) = '1' and waitForError(3) = '1') THEN
                rdreqPack(3) <= '1';
                outD <= readDataD;
                packetDoneFlag(3) <= readDataD(8);
                IF (counterD >= 7 AND counterD <= 13) THEN --Dest MAC is from bytes 7 to 13.
                    MACReadOut4(47 DOWNTO 8) <= MACReadOut4(39 DOWNTO 0);
                    MACReadOut4(7 DOWNTO 0) <= readDataD(7 DOWNTO 0);
                    --dst1(8 * counter - 8 downto 1 * counter -8) <= readDataA;
                END IF;
                IF counterD >= 14 AND counterD <= 20 THEN
                    MACReadOut4S(47 DOWNTO 8) <= MACReadOut4S(39 DOWNTO 0);
                    MACReadOut4S(7 DOWNTO 0) <= readDataD(7 DOWNTO 0);
                    --src1(8 * counter - 15 downto 1 * counter -15) <= readDataA;
                END IF;
                IF counterD = 21 THEN
                    dst4 <= MACReadOut4;
                    src4 <= MACReadOut4S;
                END IF;
            ELSE
                rdreqPack(3) <= '0';
            END IF;
        END IF;
    END PROCESS;

    trashErredData : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF (packetErrorState(0) = '1' AND EoF(0) = '1' AND packetDoneFlag(0) = '0') THEN
                rdreqPack(0) <= '1';
                deadEnd <= readDataA;
                packetDoneFlag(0) <= readDataA(8);
            END IF;
            IF (packetErrorState(1) = '1' AND EoF(1) = '1' AND packetDoneFlag(1) = '0') THEN
                rdreqPack(1) <= '1';
                deadEnd <= readDataB;
                packetDoneFlag(1) <= readDataB(8);
            END IF;
            IF (packetErrorState(2) = '1' AND EoF(2) = '1' AND packetDoneFlag(2) = '0') THEN
                rdreqPack(2) <= '1';
                deadEnd <= readDataC;
                packetDoneFlag(2) <= readDataC(8);
            END IF;
            IF (packetErrorState(3) = '1' AND EoF(3) = '1' AND packetDoneFlag(3) = '0') THEN
                rdreqPack(3) <= '1';
                deadEnd <= readDataD;
                packetDoneFlag(3) <= readDataD(8);
            END IF;
        END IF;
 
    END PROCESS; -- trashErredData
    counterProc : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF startWriting(0) = '1' THEN
                counterA <= counterA + 1;
                IF packetDoneFlag(0) = '1' THEN
                    counterA <= 0;
                END IF;
            END IF;

            IF startWriting(1) = '1' THEN
                counterB <= counterB + 1;
                IF packetDoneFlag(0) = '1' THEN
                    counterB <= 0;
                END IF;
            END IF;

            IF startWriting(2) = '1' THEN
                counterC <= counterC + 1;
                IF packetDoneFlag(0) = '1' THEN
                    counterC <= 0;
                END IF;
            END IF;

            IF startWriting(3) = '1' THEN
                counterD <= counterD + 1;
                IF packetDoneFlag(0) = '1' THEN
                    counterD <= 0;
                END IF;
            END IF;
 
        END IF;
    END PROCESS;
    --Port Mapping--

    --4 FCS modules.
    FCS1 : fcs_check_parallel
    PORT MAP(
        clk => clk, 
        reset => reset, 
        write_enable => EoF(0), 
        data_in(7 DOWNTO 0) => regA, 
        data_in(8) => linkSync(0), 
        fcs_error => fcs_error(0)
        );
        FCS2 : fcs_check_parallel
        PORT MAP(
            clk => clk, 
            reset => reset, 
            write_enable => EoF(1), 
            data_in(7 DOWNTO 0) => regB, 
            data_in(8) => linkSync(1), 
            fcs_error => fcs_error(1)
        );
        FCS3 : fcs_check_parallel
        PORT MAP(
            clk => clk, 
            reset => reset, 
            write_enable => EoF(2), 
            data_in(7 DOWNTO 0) => regC, 
            data_in(8) => linkSync(2), 
            fcs_error => fcs_error(2)
        );
        FCS4 : fcs_check_parallel
        PORT MAP(
            clk => clk, 
            reset => reset, 
            write_enable => EoF(3), 
            data_in(7 DOWNTO 0) => regD, 
            data_in(8) => linkSync(3), 
            fcs_error => fcs_error(3)
        );

        --4 FiFoPacket
        FiFoPack1 : FiFoPacket
        PORT MAP(
            clock => clk, 
            data(7 DOWNTO 0) => regA, 
            data(8) => linkSyncA(0), 
            rdreq => rdreqPack(0), 
            sclr => reset, 
            wrreq => wrreqPack(0), 
            empty => emptyPack(0), 
            full => fullPack(0), 
            q => readDataA(8 DOWNTO 0), 
            usedw => usedwPack(10 DOWNTO 0)
        );
        FiFoPack2 : FiFoPacket
        PORT MAP(
            clock => clk, 
            data(7 DOWNTO 0) => regB, 
            data(8) => linkSyncA(1), 
            rdreq => rdreqPack(0), 
            sclr => reset, 
            wrreq => wrreqPack(1), 
            empty => emptyPack(1), 
            full => fullPack(1), 
            q => readDataB(8 DOWNTO 0), 
            usedw => usedwPack(21 DOWNTO 11)
        );
        FiFoPack3 : FiFoPacket
        PORT MAP(
            clock => clk, 
            data(7 DOWNTO 0) => regC, 
            data(8) => linkSyncA(2), 
            rdreq => rdreqPack(0), 
            sclr => reset, 
            wrreq => wrreqPack(2), 
            empty => emptyPack(2), 
            full => fullPack(2), 
            q => readDataC(8 DOWNTO 0), 
            usedw => usedwPack(32 DOWNTO 22)
        );
        FiFoPack4 : FiFoPacket
        PORT MAP(
            clock => clk, 
            data(7 DOWNTO 0) => regD, 
            data(8) => linkSyncA(3), 
            rdreq => rdreqPack(0), 
            sclr => reset, 
            wrreq => wrreqPack(3), 
            empty => emptyPack(3), 
            full => fullPack(3), 
            q => readDataD(8 DOWNTO 0), 
            usedw => usedwPack(43 DOWNTO 33)
        );
        --TODO add 3 more after filling out all mapping.
        --4 FiFoErr
        FiFoErr1 : FiFoErrors
        PORT MAP(
            clock => clk, 
            data(0) => fcs_error(0), 
            rdreq => rreqErr(0), 
            sclr => reset, 
            wrreq => wreqErr(0), 
            empty => emptyErr(0), 
            full => fullErr(0), 
            q(0) => fcs_error_out(0), 
            usedw => usedWErr(4 DOWNTO 0)
        );
        FiFoErr2 : FiFoErrors
        PORT MAP(
            clock => clk, 
            data(0) => fcs_error(1), 
            rdreq => rreqErr(1), 
            sclr => reset, 
            wrreq => wreqErr(1), 
            empty => emptyErr(1), 
            full => fullErr(1), 
            q(0) => fcs_error_out(1), 
            usedw => usedWErr(9 DOWNTO 5)
        );
        FiFoErr3 : FiFoErrors
        PORT MAP(
            clock => clk, 
            data(0) => fcs_error(2), 
            rdreq => rreqErr(2), 
            sclr => reset, 
            wrreq => wreqErr(2), 
            empty => emptyErr(2), 
            full => fullErr(2), 
            q(0) => fcs_error_out(2), 
            usedw => usedWErr(14 DOWNTO 10)
        );
        FiFoErr4 : FiFoErrors
        PORT MAP(
            clock => clk, 
            data(0) => fcs_error(3), 
            rdreq => rreqErr(3), 
            sclr => reset, 
            wrreq => wreqErr(3), 
            empty => emptyErr(3), 
            full => fullErr(3), 
            q(0) => fcs_error_out(3), 
            usedw => usedWErr(19 DOWNTO 15)
        );
END ARCHITECTURE;
