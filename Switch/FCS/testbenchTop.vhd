LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.ALL;

entity FCSBlockTop_tb is
end;

architecture bench of FCSBlockTop_tb is

  component FCSBlockTop
  port(
  clk : 		in std_logic;
  inputA :	in std_logic_vector(7 downto 0);
  inputB : 	in std_logic_vector(7 downto 0);
  inputC : 	in std_logic_vector(7 downto 0);
  inputD : 	in std_logic_vector(7 downto 0);
  linkSync : in std_logic_vector(3 downto 0);
  reset : 	in std_logic;
  WportMAC : 	out std_logic_vector(3 downto 0);
  src1 : 		out std_logic_vector(47 downto 0);
  dst1 : 		out std_logic_vector(47 downto 0);
  src2 : 		out std_logic_vector(47 downto 0);
  dst2 : 		out std_logic_vector(47 downto 0);
  src3 : 		out std_logic_vector(47 downto 0);
  dst3 : 		out std_logic_vector(47 downto 0);
  src4 : 		out std_logic_vector(47 downto 0);
  dst4 : 		out std_logic_vector(47 downto 0);
  OutA : 			out std_logic_vector(8 downto 0);
  OutB : 			out std_logic_vector(8 downto 0);
  OutC : 			out std_logic_vector(8 downto 0);
  OutD : 			out std_logic_vector(8 downto 0);
  wportCross: 		out std_logic_vector(3 downto 0)
  );
  end component;

  signal clk: std_logic;
  signal inputA: std_logic_vector(7 downto 0);
  signal inputB: std_logic_vector(7 downto 0);
  signal inputC: std_logic_vector(7 downto 0);
  signal inputD: std_logic_vector(7 downto 0);
  signal linkSync: std_logic_vector(3 downto 0);
  signal reset: std_logic;
  signal WportMAC: std_logic_vector(3 downto 0);
  signal src1: std_logic_vector(47 downto 0);
  signal dst1: std_logic_vector(47 downto 0);
  signal src2: std_logic_vector(47 downto 0);
  signal dst2: std_logic_vector(47 downto 0);
  signal src3: std_logic_vector(47 downto 0);
  signal dst3: std_logic_vector(47 downto 0);
  signal src4: std_logic_vector(47 downto 0);
  signal dst4: std_logic_vector(47 downto 0);
  signal OutA: std_logic_vector(8 downto 0);
  signal OutB: std_logic_vector(8 downto 0);
  signal OutC: std_logic_vector(8 downto 0);
  signal OutD: std_logic_vector(8 downto 0);
  signal wportCross: std_logic_vector(3 downto 0) ;

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;

  
begin

  uut: FCSBlockTop port map ( clk        => clk,
                              inputA     => inputA,
                              inputB     => inputB,
                              inputC     => inputC,
                              inputD     => inputD,
                              linkSync   => linkSync,
                              reset      => reset,
                              WportMAC   => WportMAC,
                              src1       => src1,
                              dst1       => dst1,
                              src2       => src2,
                              dst2       => dst2,
                              src3       => src3,
                              dst3       => dst3,
                              src4       => src4,
                              dst4       => dst4,
                              OutA       => OutA,
                              OutB       => OutB,
                              OutC       => OutC,
                              OutD       => OutD,
                              wportCross => wportCross );
  linkSync(0) <= '1';
  
  stimulus: process
      FILE file_in                 : text OPEN read_mode IS "input.txt";
      --FILE out1bit                 : text OPEN read_mode IS "output1bit.txt";
      --FILE file_out                : text OPEN write_mode IS "comparison.txt";
  
      VARIABLE current_read_line   : line;
      VARIABLE current_read_field1 : STRING(2 DOWNTO 1);
      VARIABLE current_read_field2 : INTEGER;
      VARIABLE current_read_field3 : std_logic_vector(31 DOWNTO 0);
  
      VARIABLE space               : CHARACTER := ' ';
  
      VARIABLE current_write_line  : line;
      VARIABLE F                   : std_logic_vector(7 DOWNTO 0);
  begin
  	inputA <= x"AA";
    inputB <= x"0";
    inputC <= x"0";
    inputD <= x"0";

    -- Put test bench stimulus code here
    if rising_edge(clk) then
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
      
      
    end if;
    --stop_the_clock <= true;
    wait;
  end process;

  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;