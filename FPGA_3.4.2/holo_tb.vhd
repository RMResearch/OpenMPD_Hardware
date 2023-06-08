-- Testbench File for MAX(R) 10 FPGA Evaluation Kit or Intel(R) Cyclone(R) 10 LP FPGA Evaluation Kit ##

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library modelsim_lib;
use modelsim_lib.util.all;

entity holo_tb is

end holo_tb;

architecture rtl of holo_tb is

	component Masterclock is
		port (
			inclk0 : in  std_logic;
			c0 	 : out std_logic;
			c1		 : out std_logic );
	end component;

	component Counter is
		generic (
			COUNTER_BITS: integer := 10 );
		port (
			clk 		  : in  std_logic;
			clk_8 	  : in  std_logic;
			sync_reset : in  std_logic;
			count		  : out std_logic_vector (COUNTER_BITS-1 downto 0);
			timing	  : out std_logic );
	end component;

	component FrameBufferController is
		generic (
			NUM_TRANSDUCERS : integer := 256 );
		port (
			clk		: in  std_logic;
			new_rx	: in  std_logic;
			rx_data	: in  std_logic_vector (7 downto 0);
			timing	: in  std_logic;
			divider	: in	std_logic_vector (7 downto 0);
			ready		: out std_logic;
			byte_in	: out std_logic;
			q_in		: out std_logic_vector (7 downto 0);
			debugled : out std_logic_vector (3 downto 0)		
	);
	end component;
	
	constant	BOARD_ID			 : integer := 0;
	constant	COUNTER_BITS	 : integer := 10;
	constant	NUM_TRANSDUCERS : integer := 256;


   --Inputs
	signal clk			: std_logic := '0';
	signal q   			: std_logic_vector (6 downto 0) := (others => '0');
	
   signal clk_8		: std_logic := '0';
   signal nclk_8		: std_logic := '0';
   signal count 		: std_logic_vector (9 downto 0) := (others => '0');
	signal sync_reset	: std_logic := '0';
	signal timing		: std_logic := '0';
	
	signal rx_data 	: std_logic_vector (7 downto 0) := (others => '0');
	signal new_rx		: std_logic := '0';
	signal divider		: std_logic_vector (7 downto 0) := "00000100";
	signal ready		: std_logic := '0';
	signal byte_in		: std_logic := '0';
	signal q_in			: std_logic_vector (7 downto 0) := (others => '0');
	signal debugled	: std_logic_vector (3 downto 0) := (others => '0');		


   -- Clock period definitions
   constant CLK_period : time := 20 ns;

begin

	-- This block generates 40.96MHz clocks
	inst_Masterclock : Masterclock 
		port map (
			inclk0 => clk,
			c0		 => clk_8,
			c1		 => nclk_8 );

	-- This block creates the count signal used for timing
	inst_Counter : Counter 
	   generic map (
			COUNTER_BITS => COUNTER_BITS )
		port map (
			clk		  => clk,
			clk_8		  => clk_8,
			sync_reset => sync_reset,
			count		  => count,
			timing	  => timing );

	
	inst_FrameBufferController : FrameBufferController 
	   generic map (
			NUM_TRANSDUCERS => NUM_TRANSDUCERS )
		port map (
			clk	  	=> clk,
			new_rx  	=> new_rx,
			rx_data 	=> rx_data,
			timing 	=> timing,
			divider	=> divider,
			ready	  	=> ready,
			byte_in 	=> byte_in,
			q_in	 	=> q_in,
			debugled => debugled );
			
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
     wait for CLK_period*400;
	
		for j in 0 to 31 loop		
			for i in 0 to 511 loop
				if (i < 26) then
					rx_data <= '1' & q;
				else
					rx_data <= '0' & q;
				end if;
				new_rx <= '1';
				q <= q + '1';
				wait for CLK_period;
			end loop;
			rx_data <= (others => '0');
			new_rx <= '0';
			wait for CLK_period * 10;
		end loop;
		
      wait;
   end process;
	
end rtl;