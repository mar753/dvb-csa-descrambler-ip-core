----------------------------------------------------------------------------------
-- Company: -
-- Engineer: Marcel Szewczyk (marcel.szewczyk@gmail.com)
--
-- Create Date:     13:10:02 07/19/2012
-- Design Name:
-- Module Name:     StreamCipher - Behavioral
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
use IEEE.NUMERIC_STD.ALL;


entity StreamCipher is
    Port ( clk : in STD_LOGIC;
		   enable : in STD_LOGIC;
		   res : in STD_LOGIC;
		   key : in  STD_LOGIC_VECTOR (63 downto 0);
		   SB0 : in  STD_LOGIC_VECTOR (63 downto 0);
		   output : out  STD_LOGIC_VECTOR (1 downto 0);
		   ready : out STD_LOGIC ); -- initialization mode completed
end StreamCipher;

architecture Behavioral of StreamCipher is

signal bout : STD_LOGIC_VECTOR (3 downto 0);
signal d : STD_LOGIC_VECTOR (3 downto 0);
signal x : STD_LOGIC_VECTOR (3 downto 0);
signal y : STD_LOGIC_VECTOR (3 downto 0);
signal z : STD_LOGIC_VECTOR (3 downto 0);
signal p : STD_LOGIC;
signal q : STD_LOGIC;
signal e : STD_LOGIC_VECTOR (3 downto 0);
signal f : STD_LOGIC_VECTOR (3 downto 0);
signal init : STD_LOGIC;
signal cycle : STD_LOGIC;
signal iter : integer;

signal i1 : STD_LOGIC_VECTOR (3 downto 0);
signal i2 : STD_LOGIC_VECTOR (3 downto 0);

subtype dim0 is std_logic_vector(1 downto 0);
type scTable is array(integer range 0 to 31,integer range 1 to 7) of dim0;

constant SBox : scTable := (
("10","11","10","11","10","00","00"),
("00","01","00","01","00","01","11"),
("01","00","01","10","00","10","10"),
("01","10","10","11","01","11","10"),
("10","10","10","00","11","01","11"),
("11","11","11","10","10","10","00"),
("11","11","11","01","11","10","00"),
("00","00","01","10","10","00","01"),
("11","01","01","01","00","00","11"),
("10","11","01","10","01","01","00"),
("10","10","00","00","11","11","01"),
("00","01","11","01","11","00","11"),
("01","00","11","11","01","10","01"),
("01","00","00","00","00","11","10"),
("00","01","10","00","10","01","10"),
("11","10","00","11","01","11","01"),
("00","11","01","01","10","10","01"),
("11","01","11","00","11","11","00"),
("11","00","00","11","10","00","11"),
("00","11","01","01","00","10","11"),
("10","11","11","10","00","11","00"),
("10","10","00","11","11","00","01"),
("01","00","10","00","01","01","01"),
("01","10","10","11","01","01","10"),
("10","00","10","00","01","10","10"),
("10","00","00","11","00","01","11"),
("00","01","01","10","11","01","01"),
("11","10","10","00","10","10","00"),
("01","10","00","01","11","00","10"),
("01","01","11","10","01","11","11"),
("11","11","11","10","00","11","00"),
("00","01","01","01","10","00","10"));


begin

output <= (d(2) xor d(3)) & (d(0) xor d(1));

ctrl: process(clk, res) --, SB0)
begin
	if (res='0') then -- asynchronous reset
		init <= '1';
		cycle <= '0'; --even clk cycle (initial)
		iter <= 0;
		i1 <= SB0(63 downto 60);
		i2 <= SB0(59 downto 56);
		ready <= '0';

	elsif rising_edge(clk) and enable='1' then

			if iter<31 then

				cycle <= not cycle;
				iter <= iter+1;

				i1 <= SB0(63-8*((iter+1) / 4) downto 60-8*((iter+1) / 4));
				i2 <= SB0(59-8*((iter+1) / 4) downto 56-8*((iter+1) / 4));

			elsif iter=31 then

				init <= '0';
				iter <= 32;
			else

				ready <= '1';

			end if;
	end if;
end process;

fsr1: process(clk, res) --, key)
	variable a : STD_LOGIC_VECTOR (39 downto 0);
	variable tmp : STD_LOGIC_VECTOR (4 downto 0);
begin
	if (res='0') then -- asynchronous reset
		a := key(63 downto 32) & "00000000";
		p <= '0';
		q <= '0';
		x <= (others => '0');
		y <= (others => '0');
		z <= (others => '0');
	elsif rising_edge(clk) and enable='1' then

			if init='1' then
				if cycle='0' then

					tmp := a(24)&a(38)&a(17)&a(15)&a(4);
					x(0) <= SBox(to_integer(unsigned(tmp)),1)(1);
					tmp := a(33)&a(30)&a(19)&a(12)&a(5);
					x(1) <= SBox(to_integer(unsigned(tmp)),2)(1);
					tmp := a(39)&a(32)&a(21)&a(23)&a(18);
					x(2) <= SBox(to_integer(unsigned(tmp)),3)(0);
					tmp := a(31)&a(37)&a(35)&a(26)&a(8);
					x(3) <= SBox(to_integer(unsigned(tmp)),4)(0);

					tmp := a(39)&a(32)&a(21)&a(23)&a(18);
					y(0) <= SBox(to_integer(unsigned(tmp)),3)(1);
					tmp := a(31)&a(37)&a(35)&a(26)&a(8);
					y(1) <= SBox(to_integer(unsigned(tmp)),4)(1);
					tmp := a(22)&a(27)&a(16)&a(9)&a(6);
					y(2) <= SBox(to_integer(unsigned(tmp)),5)(0);
					tmp := a(29)&a(25)&a(20)&a(14)&a(7);
					y(3) <= SBox(to_integer(unsigned(tmp)),6)(0);

					tmp := a(22)&a(27)&a(16)&a(9)&a(6);
					z(0) <= SBox(to_integer(unsigned(tmp)),5)(1);
					tmp := a(29)&a(25)&a(20)&a(14)&a(7);
					z(1) <= SBox(to_integer(unsigned(tmp)),6)(1);
					tmp := a(24)&a(38)&a(17)&a(15)&a(4);
					z(2) <= SBox(to_integer(unsigned(tmp)),1)(0);
					tmp := a(33)&a(30)&a(19)&a(12)&a(5);
					z(3) <= SBox(to_integer(unsigned(tmp)),2)(0);

					tmp := a(34)&a(28)&a(13)&a(10)&a(11);
					p <= SBox(to_integer(unsigned(tmp)),7)(1);
					q <= SBox(to_integer(unsigned(tmp)),7)(0);

					tmp(3 downto 0) := a(3 downto 0) xor x xor d xor i1;
					a := std_logic_vector(unsigned(a) srl 4);
					a(39 downto 36) := tmp(3 downto 0);

				else -- cycle=1

					tmp := a(24)&a(38)&a(17)&a(15)&a(4);
					x(0) <= SBox(to_integer(unsigned(tmp)),1)(1);
					tmp := a(33)&a(30)&a(19)&a(12)&a(5);
					x(1) <= SBox(to_integer(unsigned(tmp)),2)(1);
					tmp := a(39)&a(32)&a(21)&a(23)&a(18);
					x(2) <= SBox(to_integer(unsigned(tmp)),3)(0);
					tmp := a(31)&a(37)&a(35)&a(26)&a(8);
					x(3) <= SBox(to_integer(unsigned(tmp)),4)(0);

					tmp := a(39)&a(32)&a(21)&a(23)&a(18);
					y(0) <= SBox(to_integer(unsigned(tmp)),3)(1);
					tmp := a(31)&a(37)&a(35)&a(26)&a(8);
					y(1) <= SBox(to_integer(unsigned(tmp)),4)(1);
					tmp := a(22)&a(27)&a(16)&a(9)&a(6);
					y(2) <= SBox(to_integer(unsigned(tmp)),5)(0);
					tmp := a(29)&a(25)&a(20)&a(14)&a(7);
					y(3) <= SBox(to_integer(unsigned(tmp)),6)(0);

					tmp := a(22)&a(27)&a(16)&a(9)&a(6);
					z(0) <= SBox(to_integer(unsigned(tmp)),5)(1);
					tmp := a(29)&a(25)&a(20)&a(14)&a(7);
					z(1) <= SBox(to_integer(unsigned(tmp)),6)(1);
					tmp := a(24)&a(38)&a(17)&a(15)&a(4);
					z(2) <= SBox(to_integer(unsigned(tmp)),1)(0);
					tmp := a(33)&a(30)&a(19)&a(12)&a(5);
					z(3) <= SBox(to_integer(unsigned(tmp)),2)(0);

					tmp := a(34)&a(28)&a(13)&a(10)&a(11);
					p <= SBox(to_integer(unsigned(tmp)),7)(1);
					q <= SBox(to_integer(unsigned(tmp)),7)(0);

					tmp(3 downto 0) := a(3 downto 0) xor x xor d xor i2;
					a := std_logic_vector(unsigned(a) srl 4);
					a(39 downto 36) := tmp(3 downto 0);

				end if; --cycle

			else -- init=0

					tmp := a(24)&a(38)&a(17)&a(15)&a(4);
					x(0) <= SBox(to_integer(unsigned(tmp)),1)(1);
					tmp := a(33)&a(30)&a(19)&a(12)&a(5);
					x(1) <= SBox(to_integer(unsigned(tmp)),2)(1);
					tmp := a(39)&a(32)&a(21)&a(23)&a(18);
					x(2) <= SBox(to_integer(unsigned(tmp)),3)(0);
					tmp := a(31)&a(37)&a(35)&a(26)&a(8);
					x(3) <= SBox(to_integer(unsigned(tmp)),4)(0);

					tmp := a(39)&a(32)&a(21)&a(23)&a(18);
					y(0) <= SBox(to_integer(unsigned(tmp)),3)(1);
					tmp := a(31)&a(37)&a(35)&a(26)&a(8);
					y(1) <= SBox(to_integer(unsigned(tmp)),4)(1);
					tmp := a(22)&a(27)&a(16)&a(9)&a(6);
					y(2) <= SBox(to_integer(unsigned(tmp)),5)(0);
					tmp := a(29)&a(25)&a(20)&a(14)&a(7);
					y(3) <= SBox(to_integer(unsigned(tmp)),6)(0);

					tmp := a(22)&a(27)&a(16)&a(9)&a(6);
					z(0) <= SBox(to_integer(unsigned(tmp)),5)(1);
					tmp := a(29)&a(25)&a(20)&a(14)&a(7);
					z(1) <= SBox(to_integer(unsigned(tmp)),6)(1);
					tmp := a(24)&a(38)&a(17)&a(15)&a(4);
					z(2) <= SBox(to_integer(unsigned(tmp)),1)(0);
					tmp := a(33)&a(30)&a(19)&a(12)&a(5);
					z(3) <= SBox(to_integer(unsigned(tmp)),2)(0);

					tmp := a(34)&a(28)&a(13)&a(10)&a(11);
					p <= SBox(to_integer(unsigned(tmp)),7)(1);
					q <= SBox(to_integer(unsigned(tmp)),7)(0);

					tmp(3 downto 0) := a(3 downto 0) xor x;
					a := std_logic_vector(unsigned(a) srl 4);
					a(39 downto 36) := tmp(3 downto 0);

			end if; -- init
	end if; --reset
end process;

fsr2: process(clk, res) --, key)
	variable b : STD_LOGIC_VECTOR (39 downto 0);
	variable tmp : STD_LOGIC_VECTOR (3 downto 0);
begin
	if (res='0') then -- asynchronous reset
		b := key(31 downto 0) & "00000000";

		bout(3)<=b(28) xor b(17) xor b(14) xor b(7);
		bout(2)<=b(16) xor b(9) xor b(31) xor b(26);
		bout(1)<=b(23) xor b(10) xor b(24) xor b(21);
		bout(0)<=b(6) xor b(19) xor b(29) xor b(8);

	elsif rising_edge(clk) and enable='1' then

			if init='1' then
				if cycle='0' then

          tmp := b(3 downto 0) xor b(15 downto 12) xor y xor i2;
					b := std_logic_vector(unsigned(b) srl 4);
					b(39 downto 36) := tmp;

					if p='1' then
						b(39 downto 36) := tmp(2 downto 0) & tmp(3); --rol
					end if;

					bout(3)<=b(28) xor b(17) xor b(14) xor b(7);
					bout(2)<=b(16) xor b(9) xor b(31) xor b(26);
					bout(1)<=b(23) xor b(10) xor b(24) xor b(21);
					bout(0)<=b(6) xor b(19) xor b(29) xor b(8);

				else -- cycle=1

          tmp := b(3 downto 0) xor b(15 downto 12) xor y xor i1;
					b := std_logic_vector(unsigned(b) srl 4);
					b(39 downto 36) := tmp;

					if p='1' then
						b(39 downto 36) := tmp(2 downto 0) & tmp(3); --rol
					end if;

					bout(3)<=b(28) xor b(17) xor b(14) xor b(7);
					bout(2)<=b(16) xor b(9) xor b(31) xor b(26);
					bout(1)<=b(23) xor b(10) xor b(24) xor b(21);
					bout(0)<=b(6) xor b(19) xor b(29) xor b(8);

				end if; --cycle
			else -- init=0

					tmp := b(3 downto 0) xor b(15 downto 12) xor y;
					b := std_logic_vector(unsigned(b) srl 4);
					b(39 downto 36) := tmp;

					if p='1' then
						b(39 downto 36) := tmp(2 downto 0) & tmp(3); --rol
					end if;

					bout(3)<=b(28) xor b(17) xor b(14) xor b(7);
					bout(2)<=b(16) xor b(9) xor b(31) xor b(26);
					bout(1)<=b(23) xor b(10) xor b(24) xor b(21);
					bout(0)<=b(6) xor b(19) xor b(29) xor b(8);

			end if; -- init

	end if; -- reset
end process;

cmb: process(clk, res)
	variable c : STD_LOGIC;
	variable tmp : STD_LOGIC_VECTOR (3 downto 0);
	variable tmp2 : STD_LOGIC_VECTOR (4 downto 0); -- addition result
begin
	if (res='0') then -- asynchronous reset
		c := '0';
		e <= (others => '0');
		f <= (others => '0');
	elsif rising_edge(clk) and enable='1' then

			tmp := f;
			if q='0' then
				f <= e;
				e <= tmp;
			else
				if c='1' then
					tmp2 := std_logic_vector(unsigned('0' & e) + unsigned(z) + 1);
					c := tmp2(4);
				else
					tmp2 := std_logic_vector(unsigned('0' & e) + unsigned(z));
					c := tmp2(4);
				end if;
				f <= tmp2(3 downto 0);
				e <= tmp;
			end if;

	end if; -- reset
end process;


process(clk, res)
begin
	if (res='0') then -- asynchronous reset
		d <= (others => '0');
	elsif rising_edge(clk) and enable='1' then
		d <= e xor z xor bout;
	end if;
end process;

end Behavioral;

