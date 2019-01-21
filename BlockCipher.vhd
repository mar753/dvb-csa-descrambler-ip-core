----------------------------------------------------------------------------------
-- Company: -
-- Engineer: Marcel Szewczyk (marcel.szewczyk@gmail.com)
--
-- Create Date:     08:39:26 07/30/2012
-- Design Name:
-- Module Name:     BlockCipher - Behavioral
-- Project Name:    DVB-CSA implementation
-- Target Device:   FPGAs
-- Tool versions:   Xilinx ISE 13.2
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 1.0
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BlockCipher is
	Port ( clk : in STD_LOGIC;
			  enable : in STD_LOGIC;
			  res : in STD_LOGIC;
			  key : in  STD_LOGIC_VECTOR (63 downto 0);
			  IBi : in  STD_LOGIC_VECTOR (63 downto 0);
			  output : out  STD_LOGIC_VECTOR (63 downto 0);
			  ready : out STD_LOGIC
			  );
end BlockCipher;

architecture Behavioral of BlockCipher is
signal expandedKey : STD_LOGIC_VECTOR(447 downto 0);

type sbTable is array(integer range 0 to 15,integer range 0 to 15) of integer;
type sbTable1 is array(integer range 0 to 63) of integer;
type sbTable2 is array(integer range 6 downto 0) of std_logic_vector(63 downto 0);

constant keyPerm : sbTable1 := (
54, 15, 37, 2, 14, 45, 62, 31, 43, 9, 5, 10, 42, 55, 4, 59, 16, 60, 46, 22, 24, 7, 30, 44, 57, 29, 47, 21, 11, 51, 34, 50, 40, 25, 39, 56, 13, 12, 3, 33, 0, 26, 52, 1, 38, 36, 19, 23, 63, 58, 32, 18, 49, 61, 53, 27, 20, 28, 48, 41, 6, 8, 35, 17);

constant sbox : sbTable := (
(16#3A#,16#EA#,16#68#,16#FE#,16#33#,16#E9#,16#88#,16#1A#,16#83#,16#CF#,16#E1#,16#7F#,16#BA#,16#E2#,16#38#,16#12#),
(16#E8#,16#27#,16#61#,16#95#,16#0C#,16#36#,16#E5#,16#70#,16#A2#,16#06#,16#82#,16#7C#,16#17#,16#A3#,16#26#,16#49#),
(16#BE#,16#7A#,16#6D#,16#47#,16#C1#,16#51#,16#8F#,16#F3#,16#CC#,16#5B#,16#67#,16#BD#,16#CD#,16#18#,16#08#,16#C9#),
(16#FF#,16#69#,16#EF#,16#03#,16#4E#,16#48#,16#4A#,16#84#,16#3F#,16#B4#,16#10#,16#04#,16#DC#,16#F5#,16#5C#,16#C6#),
(16#16#,16#AB#,16#AC#,16#4C#,16#F1#,16#6A#,16#2F#,16#3C#,16#3B#,16#D4#,16#D5#,16#94#,16#D0#,16#C4#,16#63#,16#62#),
(16#71#,16#A1#,16#F9#,16#4F#,16#2E#,16#AA#,16#C5#,16#56#,16#E3#,16#39#,16#93#,16#CE#,16#65#,16#64#,16#E4#,16#58#),
(16#6C#,16#19#,16#42#,16#79#,16#DD#,16#EE#,16#96#,16#F6#,16#8A#,16#EC#,16#1E#,16#85#,16#53#,16#45#,16#DE#,16#BB#),
(16#7E#,16#0A#,16#9A#,16#13#,16#2A#,16#9D#,16#C2#,16#5E#,16#5A#,16#1F#,16#32#,16#35#,16#9C#,16#A8#,16#73#,16#30#),
(16#29#,16#3D#,16#E7#,16#92#,16#87#,16#1B#,16#2B#,16#4B#,16#A5#,16#57#,16#97#,16#40#,16#15#,16#E6#,16#BC#,16#0E#),
(16#EB#,16#C3#,16#34#,16#2D#,16#B8#,16#44#,16#25#,16#A4#,16#1C#,16#C7#,16#23#,16#ED#,16#90#,16#6E#,16#50#,16#00#),
(16#99#,16#9E#,16#4D#,16#D9#,16#DA#,16#8D#,16#6F#,16#5F#,16#3E#,16#D7#,16#21#,16#74#,16#86#,16#DF#,16#6B#,16#05#),
(16#8E#,16#5D#,16#37#,16#11#,16#D2#,16#28#,16#75#,16#D6#,16#A7#,16#77#,16#24#,16#BF#,16#F0#,16#B0#,16#02#,16#B7#),
(16#F8#,16#FC#,16#81#,16#09#,16#B1#,16#01#,16#76#,16#91#,16#7D#,16#0F#,16#C8#,16#A0#,16#F2#,16#CB#,16#78#,16#60#),
(16#D1#,16#F7#,16#E0#,16#B5#,16#98#,16#22#,16#B3#,16#20#,16#1D#,16#A6#,16#DB#,16#7B#,16#59#,16#9F#,16#AE#,16#31#),
(16#FB#,16#D3#,16#B6#,16#CA#,16#43#,16#72#,16#07#,16#F4#,16#D8#,16#41#,16#14#,16#55#,16#0D#,16#54#,16#8B#,16#B9#),
(16#AD#,16#46#,16#0B#,16#AF#,16#80#,16#52#,16#2C#,16#FA#,16#8C#,16#89#,16#66#,16#FD#,16#B2#,16#A9#,16#9B#,16#C0#)
);

constant xorOp : sbTable2 := (
x"0000000000000000",x"0101010101010101",x"0202020202020202",x"0303030303030303",x"0404040404040404",x"0505050505050505",x"0606060606060606");

begin

kinit: process(clk, res) --, key)
	variable tmp : STD_LOGIC_VECTOR(63 downto 0);
	variable tmp2 : STD_LOGIC_VECTOR(63 downto 0);

begin
	tmp2 := key;

	expandedKey(63 downto 0) <= key;
	for i in 1 to 6 loop
		for j in 63 downto 0 loop
			tmp(63-keyPerm(j)) := tmp2(j);
		end loop;
	tmp2 := tmp;
	expandedKey((64*(i+1))-1 downto (64*(i))) <= (tmp2 xor xorOp(i));
	end loop;

	expandedKey(63 downto 0) <= (key xor xorOp(0));

end process;

dec: process(clk, res) --, IBi)
	variable tmp : STD_LOGIC_VECTOR(63 downto 0);
	variable tmp2 : STD_LOGIC_VECTOR(7 downto 0);
	variable tmp3 : STD_LOGIC_VECTOR(7 downto 0);
	variable iter : integer;
begin
	if (res='0') then -- asynchronous reset

		iter := 0;
		tmp := (others => '0');--IBi;
		tmp2 := (others => '0');
		tmp3 := (others => '0');
		output <= (others => '0');
		ready <= '0';

	elsif rising_edge(clk) and enable='1' then

		ready <= '0';
		if iter=0 then

			tmp2 := std_logic_vector(to_unsigned(sbox(to_integer(unsigned( IBi(15 downto 12) xor (expandedKey(7+(8*iter)) & expandedKey(6+(8*iter)) & expandedKey(5+(8*iter)) & expandedKey(4+(8*iter))) )), to_integer(unsigned(IBi(11 downto 8) xor (expandedKey(3+(8*iter)) & expandedKey(2+(8*iter)) & expandedKey(1+(8*iter)) & expandedKey(8*iter)) ))),8));
			tmp3 := tmp2(1) & tmp2(5) & tmp2(2) & tmp2(3) & tmp2(7) & tmp2(4) & tmp2(0) & tmp2(6);
			tmp :=	(IBi(7 downto 0) xor tmp2) &
						IBi(63 downto 56) &
						(IBi(7 downto 0) xor IBi(55 downto 48) xor tmp2) &
						(IBi(7 downto 0) xor IBi(47 downto 40) xor tmp2) &
						(IBi(7 downto 0) xor IBi(39 downto 32) xor tmp2) &
						(IBi(31 downto 24)) &
						(IBi(23 downto 16) xor tmp3) &
						IBi(15 downto 8);

			output <= tmp;
			iter := iter+1;

		else

			tmp2 := std_logic_vector(to_unsigned(sbox(to_integer(unsigned( tmp(15 downto 12) xor (expandedKey(7+(8*iter)) & expandedKey(6+(8*iter)) & expandedKey(5+(8*iter)) & expandedKey(4+(8*iter))) )), to_integer(unsigned(tmp(11 downto 8) xor (expandedKey(3+(8*iter)) & expandedKey(2+(8*iter)) & expandedKey(1+(8*iter)) & expandedKey(8*iter)) ))),8));
			tmp3 := tmp2(1) & tmp2(5) & tmp2(2) & tmp2(3) & tmp2(7) & tmp2(4) & tmp2(0) & tmp2(6);
			tmp :=	(tmp(7 downto 0) xor tmp2) &
						tmp(63 downto 56) &
						(tmp(7 downto 0) xor tmp(55 downto 48) xor tmp2) &
						(tmp(7 downto 0) xor tmp(47 downto 40) xor tmp2) &
						(tmp(7 downto 0) xor tmp(39 downto 32) xor tmp2) &
						(tmp(31 downto 24)) &
						(tmp(23 downto 16) xor tmp3) &
						tmp(15 downto 8);

			output <= tmp;
			iter := iter+1;
			if iter=56 then
				iter:=0;
				tmp := IBi;
				ready <= '1';
			end if;
		end if;

	end if;
end process;

end Behavioral;
