library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.numeric_std.ALL;
ENTITY CrossBar is 
	port( 
		clk: in std_logic;
		packet1: in std_logic_vector(8 downto 0);
		Wport1: in std_logic_vector(3 downto 0);
		packet2: in std_logic_vector(8 downto 0);
		Wport2: in std_logic_vector(3 downto 0);
		packet3: in std_logic_vector(8 downto 0);
		Wport3: in std_logic_vector(3 downto 0);
		packet4: in std_logic_vector(8 downto 0);
		Wport4: in std_logic_vector(3 downto 0);
		output1: out std_logic_vector(7 downto 0);
		output2: out std_logic_vector(7 downto 0);
		output3: out std_logic_vector(7 downto 0);
		output4: out std_logic_vector(7 downto 0)
		--j: out std_logic_vector(1 downto 0)
	);
end ENTITY CrossBar;

architecture behavioral of CrossBar is
	COMPONENT FSM is
	port(
		clk: in std_logic;
		r_end0: in std_logic;
		empty0: in std_logic;
		rreq0: out std_logic;
		r_end1: in std_logic;
		empty1: in std_logic;
		rreq1: out std_logic;
		r_end2: in std_logic;
		empty2: in std_logic;
		rreq2: out std_logic;
		r_end3: in std_logic;
		empty3: in std_logic;
		rreq3: out std_logic;
		port_select: out std_logic_vector(1 downto 0)
	);
	end COMPONENT FSM;
	COMPONENT entry_demux is
	PORT(
		Wport: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		packet: IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		FIFOx0: OUT STD_LOGIC_VECTOR(8 DOWNTO 0); --1st FIFO--
		FIFOx1: OUT STD_LOGIC_VECTOR(8 DOWNTO 0); --2nd FIFO--
		FIFOx2: OUT STD_LOGIC_VECTOR(8 DOWNTO 0); -- 3rd FIFO--
		FIFOx3: OUT STD_LOGIC_VECTOR(8 DOWNTO 0) -- 4th FIFO--
	);
	END COMPONENT entry_demux;
	COMPONENT entry_checker is
	PORT(
		fifo_usedw: IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		inp_size: IN STD_lOGIC_VECTOR(10 DOWNTO 0);
		wrreq: OUT STD_lOGIC
	);
	END COMPONENT entry_checker;
	COMPONENT FIFO IS
		PORT
		(
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			rdreq		: IN STD_LOGIC ;
			sclr		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			empty		: OUT STD_LOGIC ;
			full		: OUT STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
			usedw		: OUT STD_LOGIC_VECTOR (12 DOWNTO 0)
		);
	END COMPONENT FIFO;
	COMPONENT out_mux is
		PORT(
			data0: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			data1: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			data2: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			data3: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			data_out: OUT STD_lOGIC_VECTOR(7 DOWNTO 0);
			port_select: IN STD_lOGIC_VECTOR(1 DOWNTO 0)
		);
	END COMPONENT out_mux;
-----------------------Crossbar Layout--------------------------------
--	
--	FIFO Naming convention: FIFO<Row><Column>
--	--FIFO00-----FIFO01-------FIFO02-------FIFO03 |
--	---|-----------|------------|-----------|---- |
--	--FIFO10-----FIFO11-------FIFO12-------FIFO13 |
--	---|-----------|------------|-----------|---- |
--	--FIFO20-----FIFO21-------FIFO22-------FIFO23 |
--	---|-----------|------------|-----------|---- |
--	--FIFO30-----FIFO31-------FIFO32-------FIFO33 |
--	---|-----------|------------|-----------|---- |
--	--output1----output2------output3------ouput4 |		
-- 	
 	SIGNAL FIFO00_d,FIFO01_d, FIFO02_d, FIFO03_d, FIFO10_d,FIFO11_d, FIFO12_d, FIFO13_d, FIFO20_d,FIFO21_d, FIFO22_d, FIFO23_d, FIFO30_d,FIFO31_d, FIFO32_d, FIFO33_d : std_logic_vector(8 DOWNTO 0);
	SIGNAL FIFO_used00, FIFO_used01, FIFO_used02, FIFO_used03, FIFO_used10, FIFO_used11, FIFO_used12, FIFO_used13, FIFO_used20, FIFO_used21, FIFO_used22, FIFO_used23, FIFO_used30, FIFO_used31, FIFO_used32, FIFO_used33 : STD_LOGIC_VECTOR(12 DOWNTO 0);
	SIGNAL wrreq00,wrreq01,wrreq02,wrreq03,wrreq10,wrreq11,wrreq12,wrreq13,wrreq20,wrreq21,wrreq22,wrreq23,wrreq30,wrreq31,wrreq32,wrreq33 : std_logic;
	--SIGNAL FIFO00_d, FIFO01_d, FIFO02_d, FIFO03_d, FIFO10_d, FIFO11_d, FIFO12_d, FIFO13_d, FIFO20_d, FIFO21_d, FIFO22_d, FIFO23_d, FIFO30_d, FIFO31_d, FIFO32_d, FIFO33_d: STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL rreq00, sclr00,rreq01, sclr01,rreq02, sclr02,rreq03, sclr03,rreq10, sclr10,rreq11, sclr11,rreq12, sclr12,rreq13, sclr13,rreq20, sclr20,rreq21, sclr21,rreq22, sclr22,rreq23, sclr23,rreq30, sclr30,rreq31, sclr31,rreq32, sclr32,rreq33, sclr33 : STD_LOGIC:='0';
	SIGNAL FIFO_empty00, full00,FIFO_empty01, full01,FIFO_empty02, full02,FIFO_empty03, full03,FIFO_empty10, full10,FIFO_empty11, full11,FIFO_empty12, full12,FIFO_empty13, full13,FIFO_empty20, full20,FIFO_empty21, full21,FIFO_empty22, full22,FIFO_empty23, full23,FIFO_empty30, full30,FIFO_empty31, full31,FIFO_empty32, full32,FIFO_empty33, full33: STD_LOGIC:='0';
	SIGNAL FIFO_Out00, FIFO_Out01, FIFO_Out02, FIFO_Out03, FIFO_Out10, FIFO_Out11, FIFO_Out12, FIFO_Out13, FIFO_Out20, FIFO_Out21, FIFO_Out22, FIFO_Out23, FIFO_Out30, FIFO_Out31, FIFO_Out32, FIFO_Out33: STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL port_select0, port_select1, port_select2, port_select3 : STD_LOGIC_VECTOR(1 DOWNTO 0);
	--signal packet1,packet2,packet3,packet4,output1,output2,output3,output4: std_logic_vector(8 downto 0);
--	signal Wport1, Wport2, Wport3, Wport4: std_logic_vector(3 downto 0);
	BEGIN
	--Port 1 delcarations--
	--	Entry demux--
	EDM0x: entry_demux PORT MAP(Wport1, packet1, FIFO00_d, FIFO01_d, FIFO02_d, FIFO03_d);
	EDM1x: entry_demux PORT MAP(Wport2, packet2, FIFO10_d, FIFO11_d, FIFO12_d, FIFO13_d);
	EDM2x: entry_demux PORT MAP(Wport3, packet3, FIFO20_d, FIFO21_d, FIFO22_d, FIFO23_d);
	EDM3x: entry_demux PORT MAP(Wport4, packet4, FIFO30_d, FIFO31_d, FIFO32_d, FIFO33_d); 
	-- Size Checker--
	--Port 1--
	EC00: entry_checker PORT MAP(fifo_used00, std_logic_vector(to_unsigned(1500,11)), wrreq00);
	EC01: entry_checker PORT MAP(fifo_used01, std_logic_vector(to_unsigned(1500,11)), wrreq01);
	EC02: entry_checker PORT MAP(fifo_used02, std_logic_vector(to_unsigned(1500,11)), wrreq02);
	EC03: entry_checker PORT MAP(fifo_used03, std_logic_vector(to_unsigned(1500,11)), wrreq03);
	--Port 2--
	EC10: entry_checker PORT MAP(fifo_used10, std_logic_vector(to_unsigned(1500,11)), wrreq10);
	EC11: entry_checker PORT MAP(fifo_used11, std_logic_vector(to_unsigned(1500,11)), wrreq11);
	EC12: entry_checker PORT MAP(fifo_used12, std_logic_vector(to_unsigned(1500,11)), wrreq12);
	EC13: entry_checker PORT MAP(fifo_used13, std_logic_vector(to_unsigned(1500,11)), wrreq13);
	-- Port 3--
	EC20: entry_checker PORT MAP(fifo_used20, std_logic_vector(to_unsigned(1500,11)), wrreq20);
	EC21: entry_checker PORT MAP(fifo_used21, std_logic_vector(to_unsigned(1500,11)), wrreq21);
	EC22: entry_checker PORT MAP(fifo_used22, std_logic_vector(to_unsigned(1500,11)), wrreq22);
	EC23: entry_checker PORT MAP(fifo_used23, std_logic_vector(to_unsigned(1500,11)), wrreq23);
	-- Port 4--
	EC30: entry_checker PORT MAP(fifo_used30, std_logic_vector(to_unsigned(1500,11)), wrreq30);
	EC31: entry_checker PORT MAP(fifo_used31, std_logic_vector(to_unsigned(1500,11)), wrreq31);
	EC32: entry_checker PORT MAP(fifo_used32, std_logic_vector(to_unsigned(1500,11)), wrreq32);
	EC33: entry_checker PORT MAP(fifo_used33, std_logic_vector(to_unsigned(1500,11)), wrreq33);
	--Connection to FIFO--
	--Port 1--
	FIFO00: FIFO PORT MAP(clk, FIFO00_d, rreq00, sclr00, wrreq00, FIFO_empty00, full00, FIFO_Out00, FIFO_used00);
	FIFO01: FIFO PORT MAP(clk, FIFO01_d, rreq01, sclr01, wrreq01, FIFO_empty01, full01, FIFO_Out01, FIFO_used01);
	FIFO02: FIFO PORT MAP(clk, FIFO02_d, rreq02, sclr02, wrreq02, FIFO_empty02, full02, FIFO_Out02, FIFO_used02);
	FIFO03: FIFO PORT MAP(clk, FIFO03_d, rreq01, sclr03, wrreq03, FIFO_empty03, full03, FIFO_Out03, FIFO_used03);
	--Port 2--
	FIFO10: FIFO PORT MAP(clk, FIFO10_d, rreq10, sclr10, wrreq10, FIFO_empty10, full10, FIFO_Out10, FIFO_used10);
	FIFO11: FIFO PORT MAP(clk, FIFO11_d, rreq11, sclr11, wrreq11, FIFO_empty11, full11, FIFO_Out11, FIFO_used11);
	FIFO12: FIFO PORT MAP(clk, FIFO12_d, rreq12, sclr12, wrreq12, FIFO_empty12, full12, FIFO_Out12, FIFO_used12);
	FIFO13: FIFO PORT MAP(clk, FIFO13_d, rreq13, sclr13, wrreq13, FIFO_empty13, full13, FIFO_Out13, FIFO_used13);
	--Port 3--
	FIFO20: FIFO PORT MAP(clk, FIFO20_d, rreq20, sclr20, wrreq20, FIFO_empty20, full20, FIFO_Out20, FIFO_used20);
	FIFO21: FIFO PORT MAP(clk, FIFO21_d, rreq21, sclr21, wrreq21, FIFO_empty21, full21, FIFO_Out21, FIFO_used21);
	FIFO22: FIFO PORT MAP(clk, FIFO22_d, rreq22, sclr22, wrreq22, FIFO_empty22, full22, FIFO_Out22, FIFO_used22);
	FIFO23: FIFO PORT MAP(clk, FIFO23_d, rreq23, sclr23, wrreq23, FIFO_empty23, full23, FIFO_Out23, FIFO_used23);
	--Port 4--
	FIFO30: FIFO PORT MAP(clk, FIFO30_d, rreq30, sclr30, wrreq30, FIFO_empty30, full30, FIFO_Out30, FIFO_used30);
	FIFO31: FIFO PORT MAP(clk, FIFO31_d, rreq31, sclr31, wrreq31, FIFO_empty31, full31, FIFO_Out31, FIFO_used31);
	FIFO32: FIFO PORT MAP(clk, FIFO32_d, rreq32, sclr32, wrreq32, FIFO_empty32, full32, FIFO_Out32, FIFO_used32);
	FIFO33: FIFO PORT MAP(clk, FIFO33_d, rreq33, sclr33, wrreq33, FIFO_empty33, full33, FIFO_Out33, FIFO_used33);
	--FSM Delcarations--
	-----FSM for output mux---
	FSMx0: FSM PORT MAP(clk, FIFO_Out00(8),FIFO_empty00,rreq00, FIFO_Out10(8),FIFO_empty10,rreq10, FIFO_Out20(8),FIFO_empty20,rreq20, FIFO_Out30(8),FIFO_empty30,rreq30, port_select0);
	FSMx1: FSM PORT MAP(clk, FIFO_Out01(8),FIFO_empty01,rreq01, FIFO_Out11(8),FIFO_empty11,rreq11, FIFO_Out21(8),FIFO_empty21,rreq21, FIFO_Out31(8),FIFO_empty31,rreq31, port_select1);
	FSMx2: FSM PORT MAP(clk, FIFO_Out02(8),FIFO_empty02,rreq02, FIFO_Out12(8),FIFO_empty12,rreq12, FIFO_Out22(8),FIFO_empty22,rreq22, FIFO_Out32(8),FIFO_empty32,rreq32, port_select2);
	FSMx3: FSM PORT MAP(clk, FIFO_Out03(8),FIFO_empty03,rreq03, FIFO_Out13(8),FIFO_empty13,rreq13, FIFO_Out23(8),FIFO_empty23,rreq23, FIFO_Out33(8),FIFO_empty33,rreq33, port_select3);

	--Output mux declarations--
	out_mux0: out_mux PORT MAP(FIFO_Out00(7 DOWNTO 0), FIFO_Out10(7 DOWNTO 0), FIFO_Out20(7 DOWNTO 0), FIFO_Out30(7 DOWNTO 0), output1, port_select0);
	out_mux1: out_mux PORT MAP(FIFO_Out01(7 DOWNTO 0), FIFO_Out11(7 DOWNTO 0), FIFO_Out21(7 DOWNTO 0), FIFO_Out31(7 DOWNTO 0), output2, port_select1);
	out_mux2: out_mux PORT MAP(FIFO_Out02(7 DOWNTO 0), FIFO_Out12(7 DOWNTO 0), FIFO_Out22(7 DOWNTO 0), FIFO_Out32(7 DOWNTO 0), output3, port_select2);
	out_mux3: out_mux PORT MAP(FIFO_Out03(7 DOWNTO 0), FIFO_Out13(7 DOWNTO 0), FIFO_Out23(7 DOWNTO 0), FIFO_Out33(7 DOWNTO 0), output4, port_select3);

end behavioral;
