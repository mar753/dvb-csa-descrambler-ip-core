--------------------------------------------------------------------------------
-- Company: -
-- Engineer: Marcel Szewczyk
--
-- Create Date:     15:12:35 08/02/2012
-- Design Name:
-- Module Name:     BlockCipher_tb.vhd testbench
-- Project Name:    DVB-CSA implementation
-- Target Device:   FPGAs
-- Tool versions:   Xilinx ISE 13.2
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 1.0
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY BlockCipher_tb IS
END BlockCipher_tb;

ARCHITECTURE behavior OF BlockCipher_tb IS

	COMPONENT BlockCipher
	Port ( clk : in STD_LOGIC;
		   enable : in STD_LOGIC;
		   res : in STD_LOGIC;
		   key : in  STD_LOGIC_VECTOR (63 downto 0);
		   IBi : in  STD_LOGIC_VECTOR (63 downto 0);
		   output : out  STD_LOGIC_VECTOR (63 downto 0);
		   ready : out STD_LOGIC
	);
	END COMPONENT;

	--Inputs
	signal clk : std_logic := '0';
	signal enable : std_logic := '1';
	signal res : std_logic := '0';
	signal key : std_logic_vector(63 downto 0) := (5 => '1', 0 => '1', others => '0');
	signal IBi : std_logic_vector(63 downto 0) := x"8000000000000001";

	--Outputs
	signal output : std_logic_vector(63 downto 0);
	signal ready : std_logic;

	-- Clock period definitions
	constant clk_period : time := 10 ns;

BEGIN

	uut: BlockCipher PORT MAP (
		clk => clk,
		enable => enable,
		res => res,
		key => key,
		IBi => IBi,
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

		wait for 2 ns;	--hold reset
		res<='1';

		wait;
	end process;

END;
