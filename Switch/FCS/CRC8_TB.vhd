
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
			start_of_frame : IN std_logic;                      -- arrival of the first bit.
			end_of_frame   : IN std_logic;                      -- arrival of the first bit in FCS.
			data_in        : IN std_logic_vector(7 DOWNTO 0);   -- serial input data.
			fcs_error      : OUT std_logic                     -- indicates an error.
			--data_out       : OUT std_logic_vector(31 DOWNTO 0)  -- outputs the polynomial string - only for testing purposes
		);
	END COMPONENT;

	SIGNAL clk_TB, start_TB, end_TB, fcs_error_TB : std_logic                    := '0';
	SIGNAL data_in_TB                             : std_logic_vector(7 DOWNTO 0) := x"00";
	SIGNAL fcs_counter                            : INTEGER                      := 0;
	SIGNAL reset_TB                               : std_logic                    := '1';
	SIGNAL data_out_TB                            : std_logic_vector(31 DOWNTO 0);

BEGIN

	DUT : fcs_check_parallel
	PORT MAP(
		clk            => clk_TB,
		reset          => reset_TB,
		start_of_frame => start_TB,
		end_of_frame   => end_TB,
		data_in        => data_in_TB,
		fcs_error      => fcs_error_TB
		--data_out       => data_out_TB
	);

	STIMULUS : PROCESS

	BEGIN

		clk_TB <= '1';
		WAIT FOR 10 ns;
		reset_TB <= '0';
		clk_TB   <= '0';
		WAIT FOR 10 ns;

	END PROCESS;

	MAIN : PROCESS (clk_TB)

		FILE file_in                 : text OPEN read_mode IS "input.txt";
		FILE out1bit                 : text OPEN read_mode IS "output1bit.txt";
		FILE file_out                : text OPEN write_mode IS "comparison.txt";

		VARIABLE current_read_line   : line;
		VARIABLE current_read_field1 : STRING(2 DOWNTO 1);
		VARIABLE current_read_field2 : INTEGER;
		VARIABLE current_read_field3 : std_logic_vector(31 DOWNTO 0);

		VARIABLE space               : CHARACTER := ' ';

		VARIABLE current_write_line  : line;
		VARIABLE F                   : std_logic_vector(7 DOWNTO 0);

	BEGIN

		IF rising_edge(clk_TB) THEN
			fcs_counter <= fcs_counter + 1;
			readline(file_in, current_read_line);
			read(current_read_line, current_read_field1);
			CASE(current_read_field1(2 DOWNTO 2)) IS
				WHEN "0"    => F(7 DOWNTO 4)    := x"0";
				WHEN "1"    => F(7 DOWNTO 4)    := x"1";
				WHEN "2"    => F(7 DOWNTO 4)    := x"2";
				WHEN "3"    => F(7 DOWNTO 4)    := x"3";
				WHEN "4"    => F(7 DOWNTO 4)    := x"4";
				WHEN "5"    => F(7 DOWNTO 4)    := x"5";
				WHEN "6"    => F(7 DOWNTO 4)    := x"6";
				WHEN "7"    => F(7 DOWNTO 4)    := x"7";
				WHEN "8"    => F(7 DOWNTO 4)    := x"8";
				WHEN "9"    => F(7 DOWNTO 4)    := x"9";
				WHEN "A"    => F(7 DOWNTO 4)    := x"A";
				WHEN "B"    => F(7 DOWNTO 4)    := x"B";
				WHEN "C"    => F(7 DOWNTO 4)    := x"C";
				WHEN "D"    => F(7 DOWNTO 4)    := x"D";
				WHEN "E"    => F(7 DOWNTO 4)    := x"E";
				WHEN "F"    => F(7 DOWNTO 4)    := x"F";
				WHEN OTHERS => F(7 DOWNTO 4) := x"0";
			END CASE;

			CASE(current_read_field1(1 DOWNTO 1)) IS
				WHEN "0"    => F(3 DOWNTO 0)    := x"0";
				WHEN "1"    => F(3 DOWNTO 0)    := x"1";
				WHEN "2"    => F(3 DOWNTO 0)    := x"2";
				WHEN "3"    => F(3 DOWNTO 0)    := x"3";
				WHEN "4"    => F(3 DOWNTO 0)    := x"4";
				WHEN "5"    => F(3 DOWNTO 0)    := x"5";
				WHEN "6"    => F(3 DOWNTO 0)    := x"6";
				WHEN "7"    => F(3 DOWNTO 0)    := x"7";
				WHEN "8"    => F(3 DOWNTO 0)    := x"8";
				WHEN "9"    => F(3 DOWNTO 0)    := x"9";
				WHEN "A"    => F(3 DOWNTO 0)    := x"A";
				WHEN "B"    => F(3 DOWNTO 0)    := x"B";
				WHEN "C"    => F(3 DOWNTO 0)    := x"C";
				WHEN "D"    => F(3 DOWNTO 0)    := x"D";
				WHEN "E"    => F(3 DOWNTO 0)    := x"E";
				WHEN "F"    => F(3 DOWNTO 0)    := x"F";
				WHEN OTHERS => F(3 DOWNTO 0) := x"0";
			END CASE;

			IF fcs_counter = 0 THEN
				start_TB <= '1';
			ELSIF fcs_counter = 60 THEN
				end_TB <= '1';
			ELSE
				end_TB   <= '0';
				start_TB <= '0';
			END IF;

			IF fcs_counter = 64 THEN
				fcs_counter <= 0;
			END IF;

			--------------------------------- COMPARISON BETWEEN 1 BIT AND 8 BIT POLYNOMIAL DIVISORS ------------------------------------
			IF fcs_counter > 2 THEN
				readline(out1bit, current_read_line);
				read(current_read_line, current_read_field2);
				read(current_read_line, current_read_field3);
				IF current_read_field2 = fcs_counter - 2 AND data_out_TB = current_read_field3 THEN
					write(current_write_line, STRING'("Correct division result"));
				ELSE
					write(current_write_line, STRING'("Wrong division result"));
				END IF;

				write(current_write_line, STRING'(" ("));
				write(current_write_line, data_out_TB);
				write(current_write_line, STRING'(")"));
				writeline(file_out, current_write_line);
			END IF;

			data_in_TB <= F;
		END IF;

	END PROCESS;
END ARCHITECTURE;
