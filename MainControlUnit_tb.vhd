--------------------------------------------------------------------------------
-- Company: -
-- Engineer: Marcel Szewczyk
--
-- Create Date:     11:36:02 08/12/2012
-- Design Name:
-- Module Name:     MainControlUnit_tb.vhd testbench
-- Project Name:    DVB-CSA implementation
-- Target Device:   FPGAs
-- Tool versions:   Xilinx ISE 13.2
-- Description:
--
-- VHDL Test Bench Created by ISE for module: MainControlUnit
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes:
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY MainControlUnit_tb IS
END MainControlUnit_tb;

ARCHITECTURE behavior OF MainControlUnit_tb IS

	COMPONENT MainControlUnit
	PORT (
		clk : IN  std_logic;
		res : IN  std_logic;
		cw : IN  std_logic_vector(63 downto 0);
		residue : IN  std_logic;
		stream : IN  std_logic_vector(63 downto 0);
		output : OUT  std_logic_vector(63 downto 0);
		ready : OUT  std_logic
	);
	END COMPONENT;

	--Inputs
	signal clk : std_logic := '0';
	signal res : std_logic := '0';
	signal cw : std_logic_vector(63 downto 0) := x"07e01b02c9e045ee";--(0 => '1' , others => '0');--
	signal residue : std_logic := '0';
	signal stream : std_logic_vector(63 downto 0) := x"DECF0A0DB2D7C440";

	--Outputs
	signal output : std_logic_vector(63 downto 0);
	signal ready : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ns;

BEGIN

	uut: MainControlUnit PORT MAP (
		clk => clk,
		res => res,
		cw => cw,
		residue => residue,
		stream => stream,
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

	stim_proc: process
	begin
		-- hold reset state
		wait for 2 ns;
		res <= '1';
		wait for 3 ns;

		wait for clk_period*33; -- possible change range from 32 to 64 cycle
		wait for 1 ns;	-- additional wait
		stream <= x"de5d63185a9817aa";
		wait for clk_period*33; -- from 65 to 121 cycle
		wait for 1 ns;
		stream <= x"c9bc27c6cb494048";
		wait for clk_period*56; -- from 122 to 178 cycle
		wait for 1 ns;
		stream <= x"fd20b7055b27cbeb";
		wait for clk_period*56; -- etc.
		wait for 1 ns;
		stream <= x"9af0ac456d56f47b";
		wait for clk_period*56;
		wait for 1 ns;
		stream <= x"6fa057f39bf7a2c7";

		-- correct output for these input data (hexadecimal):
		-- afbefbefbefbefbefbefbefbe6b5ad7cf9f3e5b16c7cf9f3e6b5ad6b5f3e7cf96c5b1f3e7cf9ad6b

		wait;
	end process;

END;
