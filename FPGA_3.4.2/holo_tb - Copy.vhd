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

	component ParallelReceiver is
		Port (
			clk		: in  std_logic;
			rxf_n		: in  std_logic;
			txe_n		: in  std_logic;
			rd_n		: out std_logic;
			wr_n		: out std_logic;
			usb_data : inout std_logic_vector(7 downto 0);
			bus_busy : out std_logic;
			tg_ready : in  std_logic;
			tg_wr    : in  std_logic;
			tg_di    : in  std_logic_vector(7 downto 0);
			tg_rd    : out std_logic;
			tg_do    : out std_logic_vector(7 downto 0) );
	end component;

	component Distribute is
		generic (
			NUM_TRANSDUCERS : integer := 256
		);
		port (
			clk		 : in  std_logic;
			new_rx	 : in  std_logic;
			rx_data	 : in  std_logic_vector (7 downto 0);
			timing	 : in  std_logic;
			ready	    : out std_logic;
			t_en	    : out std_logic;
			t_flag	 : out std_logic;
			t_data	 : out std_logic_vector (6 downto 0);
			t_address : out std_logic_vector (7 downto 0);
			t_pswap	 : out std_logic;
			t_aswap	 : out std_logic;
			rgb_data	 : out std_logic_vector (26 downto 0);
			rgb_en	 : out std_logic;
			debugled	 : out std_logic_vector (3 downto 0) );
	end component;
	
	component CalibrationAndMapping is
		generic (
			BOARD_ID	: integer := 0
		);
		port (
			clk	     : in  std_logic;
			t_en	     : in  std_logic;
			t_flag	  : in  std_logic;
			t_data	  : in  std_logic_vector (6 downto 0);
			t_address  : in  std_logic_vector (7 downto 0);
			t_pswap	  : in  std_logic;
			t_aswap	  : in  std_logic;
			rgb_data	  : in  std_logic_vector (26 downto 0);
			rgb_en	  : in  std_logic;
			phase		  : out std_logic_vector (6 downto 0);
			amplitude  : out std_logic_vector (6 downto 0);
			color		  : out std_logic_vector (26 downto 0);
			address 	  : out std_logic_vector (7 downto 0);
			p_enable   : out std_logic;
			a_enable   : out std_logic;
			c_enable	  : out std_logic;
			p_swap 	  : out std_logic;
			a_swap 	  : out std_logic;
			c_swap 	  : out std_logic );
	end component;
	
	component AllChannels is
		generic (
			NUM_TRANSDUCERS: integer := 256 );
		port (
			clk		 : in  std_logic;
			clk_8		 : in  std_logic;
			count		 : in  std_logic_vector (9 downto 0);
			phase		 : in  std_logic_vector (6 downto 0);
			amplitude : in  std_logic_vector (6 downto 0);
			color		 : in  std_logic_vector (26 downto 0);
			address	 : in  std_logic_vector (7 downto 0);
			p_enable  : in  std_logic;
			a_enable  : in  std_logic;
			c_enable	 : in  std_logic;
			p_swap 	 : in  std_logic;
			a_swap	 : in  std_logic;
			c_swap	 : in  std_logic;
			data		 : out std_logic_vector (31 downto 0);
			illumi	 : out std_logic_vector (2 downto 0);
			rclk		 : out std_logic;
			synccnt	 : out std_logic_vector (7 downto 0)	);
	end component;
	
	constant	BOARD_ID			 : integer := 0;
	constant	COUNTER_BITS	 : integer := 10;
	constant	NUM_TRANSDUCERS : integer := 256;


   --Inputs
	signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	signal q 	 : std_logic_vector(6 downto 0) := (others => '0');

	
   signal clk_8		 : std_logic := '0';
   signal nclk_8		 : std_logic := '0';
   signal count 		 : std_logic_vector(9 downto 0) := (others => '0');
	signal rx_data 	 : std_logic_vector(7 downto 0) := (others => '0');
	signal new_rx		 : std_logic := '0';
	signal sync_reset	 : std_logic := '0';
	signal timing		 : std_logic := '0';
	
	signal ready		 : std_logic := '0';
	signal t_en			 : std_logic := '0';
	signal t_flag		 : std_logic := '0';
	signal t_data		 : std_logic_vector (6 downto 0) := (others => '0');
	signal t_address	 : std_logic_vector (7 downto 0) := (others => '0');
	signal t_pswap		 : std_logic := '0';
	signal t_aswap		 : std_logic := '0';
	signal rgb_data	 : std_logic_vector (26 downto 0) := (others => '0');
	signal rgb_en		 : std_logic := '0';
	signal synccnt		 : std_logic_vector (7 downto 0) := (others => '0');
	
	signal phase		 : std_logic_vector (6 downto 0) := (others => '0');
	signal amplitude	 : std_logic_vector (6 downto 0) := (others => '0');
	signal color		 : std_logic_vector (26 downto 0) := (others => '0');
	signal address 	 : std_logic_vector (7 downto 0) := (others => '0');
	signal p_enable	 : std_logic := '0';
	signal a_enable	 : std_logic := '0';
	signal c_enable	 : std_logic := '0';
	signal p_swap		 : std_logic := '0';
	signal a_swap		 : std_logic := '0';
	signal c_swap		 : std_logic := '0';
	
	signal data_s		 : std_logic_vector (31 downto 0) := (others => '0');
	signal data_0		 : std_logic_vector (31 downto 0) := (others => '0');
	signal illumi_s	 : std_logic_vector (2 downto 0) := (others => '0');
	signal rclk_s		 : std_logic := '0';
	signal debugled_s	 : std_logic_vector (3 downto 0) := (others => '0');
	
	signal prev_ms		 : std_logic := '0';
	signal led_s		 : std_logic_vector (15 downto 0) := (others => '0');

	signal clk_1s		 : std_logic := '0';
	signal count_1sec	 : std_logic_vector(25 downto 0) := (others=>'0');

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

	-- This block converts the input signal into the actual data (e.g. xyz position, RGB colour, phase and amplitude)
	inst_Distribute : Distribute 
	   generic map (
			NUM_TRANSDUCERS => NUM_TRANSDUCERS )
		port map (
			clk		 => clk,
			new_rx	 => new_rx,
			rx_data	 => rx_data,
			timing	 => timing,
			ready		 => ready,
			t_en		 => t_en,
			t_flag	 => t_flag,
			t_data	 => t_data,
			t_address => t_address,
			t_pswap	 => t_pswap,
			t_aswap	 => t_aswap,
			rgb_data	 => rgb_data,
			rgb_en	 => rgb_en,
			debugled	 => debugled_s	);

   inst_CalibrationAndMapping : CalibrationAndMapping 
	   generic map (
			BOARD_ID => BOARD_ID )
		port map (
			clk		  => clk,
			t_en		  => t_en,
			t_flag	  => t_flag,
			t_data	  => t_data,
			t_address  => t_address,
			t_pswap	  => t_pswap,
			t_aswap	  => t_aswap,
			rgb_data	  => rgb_data,
			rgb_en	  => rgb_en,
			phase		  => phase,
			amplitude  => amplitude,
			color		  => color,
			address	  => address,
			p_enable	  => p_enable,
			a_enable	  => a_enable,
			c_enable	  => c_enable,
			p_swap	  => p_swap,
			a_swap	  => a_swap,
			c_swap	  => c_swap );
			
   inst_AllChannels : AllChannels
	   generic map (
			NUM_TRANSDUCERS => NUM_TRANSDUCERS )
		port map (
			clk		 => clk,
			clk_8		 => clk_8,
			count		 => count,
			phase	 	 => phase,
			amplitude => amplitude,
			color		 => color,
			address	 => address,
			p_enable	 => p_enable,
			a_enable	 => a_enable,
			c_enable	 => c_enable,
			p_swap	 => p_swap,
			a_swap	 => a_swap,
			c_swap	 => c_swap,
			data		 => data_s,
			illumi	 => illumi_s,
			rclk		 => rclk_s,
			synccnt	 => synccnt	);
			
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
		rst <= '1';
		wait for CLK_period;
		rst <= '0';
      wait for CLK_period*200;
		
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
			wait for CLK_period * 100;
		end loop;
		
      wait;
   end process;
	
end rtl;