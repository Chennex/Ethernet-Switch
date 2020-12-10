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
  linkSyncA : in std_logic_vector(3 downto 0);
  reset : 	in std_logic;
  WportMAC : 	out std_logic_vector(3 downto 0);
  portIn : in std_logic_vector(3 downto 0);
  portWrEn : in std_logic_vector(3 downto 0);
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
  signal linkSyncA: std_logic_vector(3 downto 0) := "0000";
  signal reset: std_logic;
  signal WportMAC: std_logic_vector(3 downto 0);
  signal portIn : std_logic_vector(3 downto 0);
  signal portWrEn : std_logic_vector(3 downto 0);
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
  signal counter : integer := 0;
  
begin

  uut: FCSBlockTop port map ( clk        => clk,
                              inputA     => inputA,
                              inputB     => inputB,
                              inputC     => inputC,
                              inputD     => inputD,
                              linkSyncA   => linkSyncA,
                              reset      => reset,
                              WportMAC   => WportMAC,
			      portIn	=> portIn,
			      portWrEn   => portWrEn,
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
  
 
  countUp : process( clk )
  begin
    if rising_edge(clk) then
      counter <= counter + 1;
      if counter > 5 then
        linkSyncA <= "0000";
        else 
        linkSyncA <= "0001";
        end if;
    end if;
  end process ; -- countUp                            
  stimulus: process
  begin
  	
    inputB <= x"00";
    inputC <= x"00";
    inputD <= x"00";
    inputA <= x"AF";
    portWrEn <= "1111";
    portIn <= "1111";
    -- Put test bench stimulus code here
    
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