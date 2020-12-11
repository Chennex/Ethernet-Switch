LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
USE std.textio.all;
USE ieee.numeric_std.ALL;

ENTITY TB_CB is
END ENTITY TB_CB;

ARCHITECTURE BEHAV OF TB_CB IS
	COMPONENT CrossBar is 
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
		reset: in std_logic;
		output4: out std_logic_vector(7 downto 0)
		--j: out std_logic_vector(1 downto 0)
	);
	end COMPONENT CrossBar;
	SIGNAL clk: STD_LOGIC:='1';
	SIGNAL reset: STD_LOGIC;
	SIGNAL packet1,packet2,packet3,packet4 : STD_LOGIC_VECTOR(8 DOWNTO 0);
	SIGNAL Wport1,Wport2,Wport3,Wport4 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL output1,output2,output3,output4: STD_LOGIC_VECTOR(7 DOWNTO 0);
	BEGIN
	CB: CrossBar PORT MAP(clk, packet1,Wport1,packet2,Wport2,packet3,Wport3,packet4,Wport4,output1,output2,output3,reset,output4);
	process
		begin
    		clk <= '1';
		--write_enable<='0';
    		wait for 10 ns;    	
    		clk <= '0';
		--write_enable<='1';
    		wait for 10 ns;    	
	end process;
	packet1<=std_logic_vector(to_unsigned(1,9));
	packet2<=std_logic_vector(to_unsigned(2,9));
	packet3<=std_logic_vector(to_unsigned(3,9));
	packet4<=std_logic_vector(to_unsigned(4,9));
	Wport1<="1111";
	Wport2<="1111";
	Wport3<="1111";
	Wport4<="1111";
END BEHAV;
