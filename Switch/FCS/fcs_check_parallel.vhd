
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

ENTITY fcs_check_parallel IS
    PORT (
        clk : IN std_logic; -- system clock
        reset : IN std_logic; -- asynchronous reset
        data_in : IN std_logic_vector(8 DOWNTO 0); -- serial input data.
        fcs_error : OUT std_logic; -- indicates an error.
        write_enable : OUT std_logic -- indicated if ready to write.
        --data_out : OUT std_logic_vector(31 DOWNTO 0) -- outputs the polynomial string - only for testing purposes
    );
END fcs_check_parallel;

ARCHITECTURE fcs_check_parallel_arch OF fcs_check_parallel IS

    SIGNAL div_in : std_logic_vector(7 DOWNTO 0) := x"00";
    SIGNAL counter : std_logic_vector(2 DOWNTO 0) := "000";
    SIGNAL rotdiv : std_logic_vector(31 DOWNTO 0) := x"00000000";
    SIGNAL start_of_frame, end_of_frame, regA : std_logic := '0';

BEGIN
    PROCESS (data_in(8), regA)
    BEGIN

        write_enable <= '0';
        start_of_frame <= '0';

        IF (data_in(8) = '1' AND regA = '0') THEN
            start_of_frame <= '1';
        END IF;

        IF (regA = '1' AND data_in(8) = '0') THEN
            write_enable <= '1';
        END IF;

    END PROCESS;

    PROCESS (counter, start_of_frame, data_in(7 DOWNTO 0))
    BEGIN
        IF start_of_frame = '1' OR counter < 3 THEN
            div_in <= NOT data_in(7 DOWNTO 0);
        ELSE
            div_in <= data_in(7 DOWNTO 0);
        END IF;
    END PROCESS;

    PROCESS (end_of_frame, rotdiv)
    BEGIN
        fcs_error <= '0';
        --write_enable <= '0';
        IF (end_of_frame = '1') THEN
            --write_enable <= '1';
            IF (rotdiv(31 DOWNTO 0) = "11111111111111111111111111111111") THEN
                fcs_error <= '0';
            ELSE
                fcs_error <= '1';
            END IF;

        END IF;
    END PROCESS;

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN

            regA <= data_in(8);

            -------------------------------------- Counter ------------------------------------------
            IF start_of_frame = '1' THEN
                counter <= "000";
                ELSIF (counter < 4) THEN
                    counter <= counter + 1;
                ELSE
                    counter <= counter;
                END IF;

            -------------------------------------- END OF FRAME DELAY ------------------------------------------

            end_of_frame <= NOT data_in(8);
            -------------------------------------- Polynomial division ------------------------------------------
            IF start_of_frame = '1' THEN
                rotdiv(31 DOWNTO 0) <= x"00000000";
                rotdiv(7 DOWNTO 0) <= div_in;
            ELSE
                rotdiv(0) <= rotdiv(24) XOR rotdiv(30) XOR div_in(0);
                rotdiv(1) <= rotdiv(24) XOR rotdiv(25) XOR rotdiv(30) XOR rotdiv(31) XOR div_in(1);
                rotdiv(2) <= rotdiv(24) XOR rotdiv(25) XOR rotdiv(26) XOR rotdiv(30) XOR rotdiv(31) XOR div_in(2);
                rotdiv(3) <= rotdiv(25) XOR rotdiv(26) XOR rotdiv(27) XOR rotdiv(31) XOR div_in(3);
                rotdiv(4) <= rotdiv(24) XOR rotdiv(26) XOR rotdiv(27) XOR rotdiv(28) XOR rotdiv(30) XOR div_in(4);
                rotdiv(5) <= rotdiv(24) XOR rotdiv(25) XOR rotdiv(27) XOR rotdiv(28) XOR rotdiv(29) XOR rotdiv(30) XOR rotdiv(31) XOR div_in(5);
                rotdiv(6) <= rotdiv(25) XOR rotdiv(26) XOR rotdiv(28) XOR rotdiv(29) XOR rotdiv(30) XOR rotdiv(31) XOR div_in(6);
                rotdiv(7) <= rotdiv(24) XOR rotdiv(26) XOR rotdiv(27) XOR rotdiv(29) XOR rotdiv(31) XOR div_in(7);
                rotdiv(8) <= rotdiv(0) XOR rotdiv(24) XOR rotdiv(25) XOR rotdiv(27) XOR rotdiv(28);
                rotdiv(9) <= rotdiv(1) XOR rotdiv(25) XOR rotdiv(26) XOR rotdiv(28) XOR rotdiv(29);
                rotdiv(10) <= rotdiv(2) XOR rotdiv(24) XOR rotdiv(26) XOR rotdiv(27) XOR rotdiv(29);
                rotdiv(11) <= rotdiv(3) XOR rotdiv(24) XOR rotdiv(25) XOR rotdiv(27) XOR rotdiv(28);
                rotdiv(12) <= rotdiv(4) XOR rotdiv(24) XOR rotdiv(25) XOR rotdiv(26) XOR rotdiv(28) XOR rotdiv(29) XOR rotdiv(30);
                rotdiv(13) <= rotdiv(5) XOR rotdiv(25) XOR rotdiv(26) XOR rotdiv(27) XOR rotdiv(29) XOR rotdiv(30) XOR rotdiv(31);
                rotdiv(14) <= rotdiv(6) XOR rotdiv(26) XOR rotdiv(27) XOR rotdiv(28) XOR rotdiv(30) XOR rotdiv(31);
                rotdiv(15) <= rotdiv(7) XOR rotdiv(27) XOR rotdiv(28) XOR rotdiv(29) XOR rotdiv(31);
                rotdiv(16) <= rotdiv(8) XOR rotdiv(24) XOR rotdiv(28) XOR rotdiv(29);
                rotdiv(17) <= rotdiv(9) XOR rotdiv(25) XOR rotdiv(29) XOR rotdiv(30);
                rotdiv(18) <= rotdiv(10) XOR rotdiv(26) XOR rotdiv(30) XOR rotdiv(31);
                rotdiv(19) <= rotdiv(11) XOR rotdiv(27) XOR rotdiv(31);
                rotdiv(20) <= rotdiv(12) XOR rotdiv(28);
                rotdiv(21) <= rotdiv(13) XOR rotdiv(29);
                rotdiv(22) <= rotdiv(14) XOR rotdiv(24);
                rotdiv(23) <= rotdiv(15) XOR rotdiv(24) XOR rotdiv(25) XOR rotdiv(30);
                rotdiv(24) <= rotdiv(16) XOR rotdiv(25) XOR rotdiv(26) XOR rotdiv(31);
                rotdiv(25) <= rotdiv(17) XOR rotdiv(26) XOR rotdiv(27);
                rotdiv(26) <= rotdiv(18) XOR rotdiv(24) XOR rotdiv(27) XOR rotdiv(28) XOR rotdiv(30);
                rotdiv(27) <= rotdiv(19) XOR rotdiv(25) XOR rotdiv(28) XOR rotdiv(29) XOR rotdiv(31);
                rotdiv(28) <= rotdiv(20) XOR rotdiv(26) XOR rotdiv(29) XOR rotdiv(30);
                rotdiv(29) <= rotdiv(21) XOR rotdiv(27) XOR rotdiv(30) XOR rotdiv(31);
                rotdiv(30) <= rotdiv(22) XOR rotdiv(28) XOR rotdiv(31);
                rotdiv(31) <= rotdiv(23) XOR rotdiv(29);
            END IF;

            --data_out <= rotdiv;

            -------------------------------------- RESET ------------------------------------------
            IF reset = '1' THEN
                counter <= "000";
                rotdiv <= x"00000000";
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE;