LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE std.textio.all;
USE ieee.numeric_std.ALL;

ENTITY entry_checker is
	PORT(
		fifo_usedw: IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		inp_size: IN STD_lOGIC_VECTOR(10 DOWNTO 0);
		wrreq: OUT STD_lOGIC
	);
END ENTITY entry_checker;

ARCHITECTURE behav of entry_checker IS
	BEGIN
	PROCESS(fifo_usedw,inp_size)
		BEGIN
		IF( (1500 < (8191 - fifo_usedw))) THEN --size of incoming packet less than available size
			wrreq<='1';
		ELSE
			wrreq<='0';
		END IF;			
	END PROCESS;
END behav;