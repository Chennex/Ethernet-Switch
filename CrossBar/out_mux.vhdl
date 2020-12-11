LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE std.textio.all;
USE ieee.numeric_std.ALL;
-- ------------------------------------------------------------------------------
-- 				TESTED
-- ------------------------------------------------------------------------------
ENTITY out_mux is
	PORT(
		data0: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data1: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data2: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data3: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		data_out: OUT STD_lOGIC_VECTOR(7 DOWNTO 0);
		port_select: IN STD_lOGIC_VECTOR(1 DOWNTO 0)
	);
END ENTITY out_mux;

ARCHITECTURE behav of out_mux IS
	BEGIN
	PROCESS(data0,data1,data2,data3,port_select)
		BEGIN
		IF( port_select = "00") THEN --size of incoming packet less than available size
			data_out<=data0;
		ELSIF( port_select = "01") THEN --size of incoming packet less than available size
			data_out<=data1;
		ELSIF( port_select = "10") THEN --size of incoming packet less than available size
			data_out<=data2;
		ELSE
			data_out<=data3;
		END IF;			
	END PROCESS;
END behav;
