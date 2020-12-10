LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE std.textio.all;
USE ieee.numeric_std.ALL;

ENTITY tb_CB is
END ENTITY tb_entry_mux;
--
--ARCHITECTURE behav of tb_entry_mux IS
----	COMPONENT entry_mux is
----	PORT(
----		fifo_usedw: IN STD_LOGIC_VECTOR(12 DOWNTO 0);
----		inp_size: IN STD_lOGIC_VECTOR(10 DOWNTO 0);
----		valid: IN STD_lOGIC;
----		wrreq: OUT STD_lOGIC
----
----	);
----	END COMPONENT entry_mux;
----	COMPONENT FIFO IS
----	PORT
----	(
----		clock		: IN STD_LOGIC ;
----		data		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
----		rdreq		: IN STD_LOGIC ;
----		sclr		: IN STD_LOGIC ;
----		wrreq		: IN STD_LOGIC ;
----		empty		: OUT STD_LOGIC ;
----		full		: OUT STD_LOGIC ;
----		q		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
----		usedw		: OUT STD_LOGIC_VECTOR (12 DOWNTO 0)
----	);
----	END COMPONENT FIFO;
----	SIGNAL fifo_usedw1: STD_LOGIC_VECTOR(12 DOWNTO 0);
----	SIGNAL inp_size1: STD_LOGIC_VECTOR(10 DOWNTO 0);
----	SIGNAL usedw: STD_LOGIC_VECTOR(12 DOWNTO 0);
----	SIGNAL data: STD_LOGIC_VECTOR(8 DOWNTO 0);
----	SIGNAL q: STD_LOGIC_VECTOR(8 DOWNTO 0);
----	SIGNAL wrreq,rdreq,full,empty,sclr,clk: STD_LOGIC:='0';
--	
--	COMPONENT FSM is
--		port(
--		clk: in std_logic;
--		r_end0: in std_logic;
--		empty0: in std_logic;
--		rreq0: out std_logic;
--		r_end1: in std_logic;
--		empty1: in std_logic;
--		rreq1: out std_logic;
--		r_end2: in std_logic;
--		empty2: in std_logic;
--		rreq2: out std_logic;
--		r_end3: in std_logic;
--		empty3: in std_logic;
--		rreq3: out std_logic;
--		port_select: out std_logic_vector(1 downto 0)
--		);
--	end COMPONENT FSM;
--	SIGNAL clk,r_end0, rreq0,r_end1,rreq1,r_end2, rreq2,r_end3, rreq3, empty0,empty1,empty2,empty3: STD_LOGIC:='0';
--	SIGNAL port_select: STD_LOGIC_VECTOR(1 downto 0);
--	BEGIN
--		FSM1: FSM PORT MAP(clk, r_end0, empty0,rreq0,r_end1, empty1,rreq1,r_end2, empty2,rreq2,r_end3, empty3,rreq3,port_select);
--		--FIFO1: FIFO PORT MAP(clk,data,rdreq,sclr,wrreq,empty,full,q,usedw);
--		process
--		begin
--    		clk <= '1';
--		--write_enable<='0';
--    		wait for 10 ns;    	
--    		clk <= '0';
--		--write_enable<='1';
--    		wait for 10 ns;    	
--		end process;
--		r_end0<='0';
--		r_end1<='0', '1' after 30ns;
--		r_end2<='0', '1' after 50ns;
--		r_end3<='0', '1' after 70ns;
--		empty0<='1';
--		empty1<='0';
--		empty2<='0';
--		empty3<='0';
--		--data<= std_logic_vector(to_unsigned(8,9)), std_logic_vector(to_unsigned(10,9)) after 20ns,std_logic_vector(to_unsigned(20,9)) after 40ns; 
--		--wrreq<='1';
--		--rdreq<='0', '1' after 10ns;
----		EM : entry_mux PORT MAP (fifo_usedw1, inp_size1, valid1 , wreq1);
----		valid1<='1', '0' after 40 ns;
----		inp_size1<=std_logic_vector(to_unsigned(1500,11)), std_logic_vector(to_unsigned(1500,11)) after 10ns,std_logic_vector(to_unsigned(1500,11)) after 20 ns;
----		fifo_usedw1<=std_logic_vector(to_unsigned(5,13)),std_logic_vector(to_unsigned(8050,13)) after 10ns,std_logic_vector(to_unsigned(8,13)) after 20 ns;	
--END behav;
----
