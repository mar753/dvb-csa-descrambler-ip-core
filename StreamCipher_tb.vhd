--------------------------------------------------------------------------------
-- Company: -
-- Engineer: Marcel Szewczyk
--
-- Create Date:     15:27:49 07/26/2012
-- Design Name:
-- Module Name:     StreamCipher.vhd testbench
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
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;


ENTITY StreamCipher_tb IS
END StreamCipher_tb;

ARCHITECTURE behavior OF StreamCipher_tb IS

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT StreamCipher
	Port ( clk : in STD_LOGIC;
		   enable : in STD_LOGIC;
		   res : in STD_LOGIC;
		   key : in  STD_LOGIC_VECTOR (63 downto 0);
		   SB0 : in  STD_LOGIC_VECTOR (63 downto 0);
		   output : out  STD_LOGIC_VECTOR (1 downto 0);
		   ready : out STD_LOGIC );
	END COMPONENT;

	--Inputs
	signal clk : std_logic := '0';
	signal enable : std_logic := '1';
	signal res : std_logic := '0';
	signal key : std_logic_vector(63 downto 0) := x"07e01b02c9e045ee";--(0 => '1' , others => '0');--"0000000000000000000000000000000000000000000000000000000000000000";--"0000011111100000000110110000001011001001111000000100010111101110";
	signal SB0 : std_logic_vector(63 downto 0) := "1101111011001111000010100000110110110010110101111100010001000000";

	--Outputs
	signal output : std_logic_vector(1 downto 0);
	signal ready : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: StreamCipher PORT MAP (
		clk => clk,
		enable => enable,
		res => res,
		key => key,
		SB0 => SB0,
		output => output,
		ready => ready
	);

	-- Clock process definitions
	clk_process :process
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
	end process;


	-- Stimulus process
	stim_proc: process
	begin

		-- hold reset state
		res <= '1';
		wait for 2 ns;

		-- wait for clk_period*10;

		wait;
	end process;

END;
