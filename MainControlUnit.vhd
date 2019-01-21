----------------------------------------------------------------------------------
-- Company: -
-- Engineer: Marcel Szewczyk (marcel.szewczyk@gmail.com)
--
-- Create Date:     12:41:36 07/31/2012
-- Design Name:
-- Module Name:     MainControlUnit - Behavioral
-- Project Name:    DVB-CSA implementation
-- Target Device:   FPGAs
-- Tool versions:   Xilinx ISE 13.2
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
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

entity MainControlUnit is
	Port ( clk : in STD_LOGIC;
			res : in STD_LOGIC;
			cw : in  STD_LOGIC_VECTOR (63 downto 0);
			residue : in STD_LOGIC; -- if residue
			stream : in  STD_LOGIC_VECTOR (63 downto 0); -- scrambled 8 bytes input data stream
			output : out STD_LOGIC_VECTOR (63 downto 0); -- descrambled 8 bytes output data stream
			ready : out STD_LOGIC ); -- output data ready
end MainControlUnit;

architecture Behavioral of MainControlUnit is

	component StreamCipher
	port (
		clk : in  std_logic;
		enable : in  std_logic;
		res : in  std_logic;
		key : in  std_logic_vector(63 downto 0);
		SB0 : in  std_logic_vector(63 downto 0);
		output : out  std_logic_vector(1 downto 0);
		ready : out std_logic
	);
	end component;

	component BlockCipher
	port (
		clk : in  std_logic;
		enable : in  std_logic;
		res : in  std_logic;
		key : in  std_logic_vector(63 downto 0);
		IBi : in  std_logic_vector(63 downto 0);
		output : out  std_logic_vector(63 downto 0);
		ready : out std_logic
	);
	end component;

	signal enablesc : std_logic;
	signal enablebc : std_logic;
	signal readysc : std_logic;
	signal readybc : std_logic;
	signal IBi : std_logic_vector(63 downto 0);
	signal scOut : std_logic_vector(1 downto 0);
	signal bcOut : std_logic_vector(63 downto 0);

begin


u1:  StreamCipher port map (
	clk => clk,
	enable => enablesc,
	res => res,
	key => cw,
	SB0 => stream,
	output => scOut,
	ready => readysc
);

u2: BlockCipher port map (
	clk => clk,
	enable => enablebc,
	res => res,
	key => cw,
	IBi => IBi,
	output => bcOut,
	ready => readybc
);

ctrl: process(clk, res)
	variable iter : integer;
	variable init : std_logic;
	variable tmpIBi : std_logic_vector(63 downto 0);
begin
	if res='0' then

		ready <= '0';
		init := '1';
		iter := 0;
		IBi <= stream;
		output <= (others => '0');
		tmpIBi := (others => '0');
		enablesc <= '0';
		enablebc <= '0';

	elsif rising_edge(clk) then

		if init='1' then

			iter := iter+1;
			if (iter <= 65) then

				if (iter <= 56) then
					enablesc <= '1';
					enablebc <= '1';
				else
					enablesc <= '1';
					enablebc <= '0';
				end if;

			elsif (iter=67) then

				output <= IBi;
				ready <= '1';

			else

				if residue='0' then

					enablesc <= '1';
					enablebc <= '1';
					IBi <= tmpIBi xor stream; -- here stream = next 8 bytes
					output <= tmpIBi xor stream xor bcOut;
					init := '0';
					iter := 0;
					ready <= '1';

				else

					enablesc <= '0';
					enablebc <= '0';
					IBi <= tmpIBi xor stream;
					output <= bcOut;
					iter := iter+1;

				end if;

			end if;

			if iter>=35 then
				tmpIBi(63-(iter-35)*2 downto 62-(iter-35)*2) := Scout;
			end if;

		else -- init = '0'

			iter := iter+1;
			if iter<=56 then

				ready <= '0';
				if iter<=32 then
					tmpIBi(63-(iter-1)*2 downto 62-(iter-1)*2) := Scout;
					if iter<32 then
						enablesc <= '1';
					else
						enablesc <= '0';
					end if;
					enablebc <= '1';
				else
					if iter=56 then
						enablesc <= '1';
						IBi <= tmpIBi xor stream; --nowa wartosc stream co kazde 56 cykli
					end if;
				end if;

			elsif iter=57 then

				tmpIBi(63 downto 62) := Scout;

				if residue='0' then --c ?
					output <= IBi xor bcOut;
				else
					enablesc <= '0';
					enablebc <= '0';
					output <= bcOut;
					iter := iter+1;
				end if;

				ready <= '1';
				iter := 1;

			elsif iter=58 then

				output <= IBi;
				ready <= '1';

			end if;

		end if; -- init

	end if;

end process;

end Behavioral;

