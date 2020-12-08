
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_textio.ALL;

LIBRARY STD;
USE STD.textio.ALL;

ENTITY CRC8_TB IS
END ENTITY;

ARCHITECTURE fcs_check_parallel_arch OF CRC8_TB IS

	COMPONENT fcs_check_parallel IS
		PORT (
			clk            : IN std_logic;                      -- system clock
			reset          : IN std_logic;                      -- asynchronous reset
			data_in        : IN std_logic_vector(7 DOWNTO 0);   -- serial input data.
			fcs_error      : OUT std_logic;                     -- indicates an error.
			write_enable   : OUT std_logic	                  -- indicated if ready to write.
			--data_out       : OUT std_logic_vector(31 DOWNTO 0)  -- outputs the polynomial string - only for testing purposes
		);
	END COMPONENT;

	SIGNAL clk_TB, start_TB, end_TB, fcs_error_TB, write_enable	 : std_logic                    := '0';
	SIGNAL data_in_TB                            					 : std_logic_vector(7 DOWNTO 0) := x"00";
	SIGNAL fcs_counter                            					 : INTEGER                      := 0;
	SIGNAL reset_TB                              					 : std_logic                    := '1';
	SIGNAL data_out_TB                           					 : std_logic_vector(31 DOWNTO 0);

	SIGNAL FRAME : std_logic_vector(511 downto 0) := x"0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2";	
	SIGNAL INDEX : integer range -2 to 64 := 64;
	
	BEGIN

	DUT : fcs_check_parallel
	PORT MAP(
		clk            => clk_TB,
		reset          => reset_TB,
		data_in        => data_in_TB,
		fcs_error      => fcs_error_TB,
		write_enable   => write_enable_TB
		--data_out       => data_out_TB
	);

	STIMULUS : PROCESS

	BEGIN
		WAIT FOR 10 ns;
		clk_TB <= not clock_TB;
	END PROCESS;
	
	reset_TB <= '1', '0' AFTER 100ns;			
		
	tb: PROCESS(clk_TB) IS
   BEGIN 
	IF rising_edge(clk_TB) THEN
		IF (INDEX > -1 and INDEX /= 64) THEN
			data_in_TB <= FRAME((8*INDEX + 7) downto (8*INDEX));
		END IF;
		IF (INDEX > -1) THEN
			INDEX <= INDEX - 1;
		END IF;
		IF reset_TB = '1' THEN
			INDEX<= 64;
		END IF;
	END IF;
	END PROCESS tb;

	END PROCESS;
END ARCHITECTURE;
