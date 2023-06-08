-- Testbench File for MAX(R) 10 FPGA Evaluation Kit or Intel(R) Cyclone(R) 10 LP FPGA Evaluation Kit ##

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library modelsim_lib;
use modelsim_lib.util.all;

entity output_tb is

end output_tb;

architecture rtl of output_tb is

	COMPONENT PointHoloController
		port (
			clk	  : in  std_logic;
			start	  : in  std_logic;
			xin	  : in  std_logic_vector (9 downto 0);
			yin	  : in  std_logic_vector (9 downto 0);
			zin	  : in  std_logic_vector (9 downto 0);
			pen	  : out std_logic;
			phase	  : out std_logic_vector (5 downto 0);
			address : out std_logic_vector (7 downto 0) );
	end COMPONENT;

   --Inputs
	signal clk 		: std_logic := '0';
   signal start 	: std_logic := '0';
   signal xin		: std_logic_vector (9 downto 0) := (others => '0');
   signal yin		: std_logic_vector (9 downto 0) := (others => '0');
   signal zin		: std_logic_vector (9 downto 0) := (others => '0');
	
 	--Outputs
	signal pen		: std_logic := '0';
	signal phase	: std_logic_vector (5 downto 0) := (others => '0');
	signal address : std_logic_vector (7 downto 0) := (others => '0');

   -- Clock period definitions
   constant CLK_period : time := 20 ns;


begin

	-- Instantiate the Unit Under Test (UUT)
   uut1: PointHoloController 
		PORT MAP (
          clk 		=> clk,
          start 	=> start,
          xin 		=> xin,
          yin 		=> yin,
          zin 		=> zin,
			 pen		=> pen,
			 phase	=> phase,
			 address => address
		);
		  			
	-- Clock process definitions
   CLK_process :process
   begin
		clk <= '0';
		wait for CLK_period/2;
		clk <= '1';
		wait for CLK_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
		xin <= "0000000000";
		yin <= "0000000000";
		zin <= "0001111000"; -- 30 mm above
		start <= '1';
		wait for CLK_period;
		
		xin <= "0000000000";
		yin <= "0000000000";
		zin <= "0000000000";
		start <= '0';

      wait;
   end process;
	
end rtl;