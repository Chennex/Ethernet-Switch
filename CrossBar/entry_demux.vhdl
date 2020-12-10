LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE std.textio.all;
USE ieee.numeric_std.ALL;
-- ------------------------------------------------------------------------------
-- 				TESTED
-- ------------------------------------------------------------------------------
ENTITY entry_demux is
	PORT(
		Wport: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		packet: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		FIFOx0: OUT STD_LOGIC_VECTOR(8 DOWNTO 0); --1st FIFO--
		FIFOx1: OUT STD_LOGIC_VECTOR(8 DOWNTO 0); --2nd FIFO--
		FIFOx2: OUT STD_LOGIC_VECTOR(8 DOWNTO 0); -- 3rd FIFO--
		FIFOx3: OUT STD_LOGIC_VECTOR(8 DOWNTO 0) -- 4th FIFO--
	);
END ENTITY entry_demux;

ARCHITECTURE behav1 OF entry_demux is
	BEGIN
	PROCESS(Wport,packet)
	BEGIN
		IF ( Wport="1000") THEN -- packet to output1--
			FIFOx0<=packet;
			FIFOx1<=(others =>'0');
			FIFOx2<=(others =>'0');
			FIFOx3<=(others =>'0');
		ELSIF ( Wport="0100") THEN -- packet to output2--
			FIFOx0<=(others =>'0');
			FIFOx1<=packet;
			FIFOx2<=(others =>'0');
			FIFOx3<=(others =>'0');
		ELSIF ( Wport="0010") THEN -- packet to output3--
			FIFOx0<=(others =>'0');
			FIFOx1<=(others =>'0');
			FIFOx2<=packet;
			FIFOx3<=(others =>'0');
		ELSIF ( Wport="0001") THEN -- packet to output4--
			FIFOx0<=(others =>'0');
			FIFOx1<=(others =>'0');
			FIFOx2<=(others =>'0');
			FIFOx3<=packet;
		ELSIF ( Wport="1111") THEN -- packet broadcast--
			FIFOx0<=packet;
			FIFOx1<=packet;
			FIFOx2<=packet;
			FIFOx3<=packet;
		ELSE -- to combat system error state--
			FIFOx0<=(others =>'0');
			FIFOx1<=(others =>'0');
			FIFOx2<=(others =>'0');
			FIFOx3<=(others =>'0');
		END IF;
	END PROCESS;
END behav1;

