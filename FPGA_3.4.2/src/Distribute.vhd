-----------------------------------------------------------------------------------
--     This block converts the input signal into the actual data                 --
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Distribute is
	generic (
		NUM_TRANSDUCERS : integer := 256
	);
	port (
		clk	 	 : in  std_logic;
		new_rx	 : in  std_logic;
		rx_data	 : in  std_logic_vector (7 downto 0);
		timing	 : in  std_logic;
		ready		 : out std_logic;
		t_en		 : out std_logic;
		t_flag	 : out std_logic;
		t_data	 : out std_logic_vector (6 downto 0);
		t_address : out std_logic_vector (7 downto 0);
		t_pswap	 : out std_logic;
		t_aswap	 : out std_logic;
		rgb_data	 : out std_logic_vector (26 downto 0);
		rgb_en	 : out std_logic;
		debugled  : out std_logic_vector (3 downto 0)		
	 );
end Distribute;

architecture Behavioral of Distribute is
	
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
	
	component CommandReader is
		generic (
			NUM_TRANSDUCERS : integer := 256 );
		port (
			clk		 : in  std_logic;
			byte_in	 : in  std_logic;
			q_in		 : in  std_logic_vector (7 downto 0);
			divider	 : out std_logic_vector (7 downto 0);
			t_en		 : out std_logic;
			t_flag	 : out std_logic;
			t_data	 : out std_logic_vector (6 downto 0);
			t_address : out std_logic_vector (7 downto 0);
			t_pswap	 : out std_logic;
			t_aswap	 : out std_logic;
			rgb_data	 : out std_logic_vector (23 downto 0);
			rgb_en	 : out std_logic;
			debugled  : out std_logic_vector (3 downto 0)		
	);
	end component;
	
	component GammaCorrection is
		port (
			clk		  : in  std_logic;
			start		  : in  std_logic;
			gammain	  : in  std_logic_vector (23 downto 0);
			gammastart : out std_logic;
			gammaout	  : out std_logic_vector (26 downto 0) );
	end component;
	
	signal byte_in		  : std_logic := '0';
	signal q_in			  : std_logic_vector (7 downto 0) := (others => '0');
	signal ready_s		  : std_logic := '0';
	signal divider_s	  : std_logic_vector (7 downto 0) := (others => '0');

	signal t_en_s		  : std_logic := '0';
	signal t_flag_s	  : std_logic := '0';
	signal t_data_s	  : std_logic_vector (6 downto 0) := (others => '0');
	signal t_address_s  : std_logic_vector (7 downto 0) := (others => '0');
	signal t_pswap_s	  : std_logic := '0';
	signal t_aswap_s	  : std_logic := '0';

	signal rgb_data_s   : std_logic_vector (26 downto 0) := (others => '0');
	signal rgb_en_s	  : std_logic := '0';

	signal gamma_in	  : std_logic_vector (23 downto 0) := (others => '0');
	signal gamma_en	  : std_logic := '0';
	
	signal debugled_cr  : std_logic_vector(3 downto 0) := (others => '0');
	signal debugled_fbr : std_logic_vector(3 downto 0) := (others => '0');
		
begin

	ready		 <= ready_s;
	t_en 		 <= t_en_s;
	t_flag 	 <= t_flag_s;
	t_data 	 <= t_data_s;
	t_address <= t_address_s;
	t_pswap 	 <= t_pswap_s;
	t_aswap 	 <= t_aswap_s;
	rgb_data  <= rgb_data_s;
	rgb_en    <= rgb_en_s;
	debugled  <= debugled_fbr;
	
	inst_FrameBufferController : FrameBufferController 
	   generic map (
			NUM_TRANSDUCERS => NUM_TRANSDUCERS )
		port map (
			clk	  	=> clk,
			new_rx  	=> new_rx,
			rx_data 	=> rx_data,
			timing 	=> timing,
			divider	=> divider_s,
			ready	  	=> ready_s,
			byte_in 	=> byte_in,
			q_in	 	=> q_in,
			debugled => debugled_fbr );
			
	inst_CommandReader : CommandReader 
	   generic map (
			NUM_TRANSDUCERS => NUM_TRANSDUCERS )
		port map (
			clk		 => clk,
			byte_in	 => byte_in,
			q_in		 => q_in,
			divider	 => divider_s,
			t_en		 => t_en_S,
			t_flag	 => t_flag_S,
			t_data	 => t_data_S,
			t_address => t_address_S,
			t_pswap	 => t_pswap_S,
			t_aswap	 => t_aswap_S,
			rgb_data	 => gamma_in,
			rgb_en	 => gamma_en,
			debugled	 => debugled_cr );

	inst_GammaCorrection : GammaCorrection
		port map (
			clk	  	  => clk,
			start		  => gamma_en,
			gammain	  => gamma_in,
			gammastart => rgb_en_s,
			gammaout	  => rgb_data_s );
			
end Behavioral;
