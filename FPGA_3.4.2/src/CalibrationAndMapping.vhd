-----------------------------------------------------------------------------------
--     This block manages the calibration and the pin mapping                    --
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CalibrationAndMapping is
	generic (
		BOARD_ID : integer := 0
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
		p_swap	  : out std_logic;
		a_swap	  : out std_logic;
		c_swap	  : out std_logic
	);
end CalibrationAndMapping;

architecture Behavioral of CalibrationAndMapping is
	
	component PhaseCalibration is
		generic (
			BOARD_ID : integer := 0 );
		port (
			clk		 	  : in  std_logic;
			phase_in	 	  : in  std_logic_vector (6 downto 0);
			amplitude_in  : in  std_logic_vector (6 downto 0);
			color_in		  : in  std_logic_vector (26 downto 0);
			address_in	  : in  std_logic_vector (7 downto 0);
			phase_out	  : out std_logic_vector (6 downto 0);
			amplitude_out : out std_logic_vector (6 downto 0);
			color_out 	  : out std_logic_vector (26 downto 0) );
	end component;
	
	component PinMapping is
		port (
			clk	 	   : in  std_logic;
			address_in  : in  std_logic_vector (7 downto 0);
			address_out : out std_logic_vector (7 downto 0) );
	end component;

	signal phase_s     : std_logic_vector (6 downto 0) := (others => '0');
	signal amplitude_s : std_logic_vector (6 downto 0) := (others => '0');
	signal color_s 	 : std_logic_vector (26 downto 0) := (others => '0');
	signal address_s	 : std_logic_vector (7 downto 0) := (others => '0');
	signal p_enable_s	 : std_logic := '0';
	signal a_enable_s	 : std_logic := '0';
	signal c_enable_s	 : std_logic := '0';
	signal p_swap_s 	 : std_logic := '0';
	signal a_swap_s 	 : std_logic := '0';
	signal c_swap_s 	 : std_logic := '0';

	signal old_rgben	 : std_logic := '0';
	
	signal phase_in 		: std_logic_vector (6 downto 0) := (others => '0');
	signal amplitude_in  : std_logic_vector (6 downto 0) := (others => '0');
	signal color_in 	 	: std_logic_vector (26 downto 0) := (others => '0');
	signal address_in  	: std_logic_vector (7 downto 0) := (others => '0');

	signal p_enable_d	 : std_logic := '0';
	signal a_enable_d	 : std_logic := '0';
	signal c_enable_d	 : std_logic := '0';
	signal p_swap_d 	 : std_logic := '0';
	signal a_swap_d 	 : std_logic := '0';
	signal c_swap_d 	 : std_logic := '0';

begin
	
	phase		 <= phase_s;
	amplitude <= amplitude_s;
	color		 <= color_s;
	address	 <= address_s;

	p_enable	 <= p_enable_s;
	a_enable	 <= a_enable_s;
	c_enable	 <= c_enable_s;
	p_swap	 <= p_swap_s;
	a_swap	 <= a_swap_s;
	c_swap	 <= c_swap_s;

	phase_in		 <= t_data when t_en = '1' else (others =>'0');
	amplitude_in <= t_data when t_en = '1' else (others =>'0');
	color_in		 <= rgb_data when rgb_en = '1' else (others =>'0');
	address_in	 <= t_address when t_en = '1' else (others =>'0');
	
	inst_PhaseCalibration : PhaseCalibration
	   generic map (
			BOARD_ID => BOARD_ID )
		port map (
			clk	  	 	  => clk,
			phase_in	 	  => phase_in,
			amplitude_in  => amplitude_in,
			color_in	 	  => color_in,
			address_in	  => address_in,
			phase_out 	  => phase_s,
			amplitude_out => amplitude_s,
			color_out	  => color_s );

	inst_PinMapping : PinMapping
		port map (
			clk			=> clk,
			address_in	=> address_in,
			address_out	=> address_s );

	process (clk) begin
		if rising_edge(clk) then
			if(t_en = '1') then
				p_enable_d <= not t_flag;
				a_enable_d <= t_flag;
			else
				p_enable_d <= '0';
				a_enable_d <= '0';
			end if;		
			p_enable_s <= p_enable_d;
			a_enable_s <= a_enable_d;

			c_enable_d <= rgb_en;
			c_enable_s <= c_enable_d;
			
			old_rgben  <= rgb_en;
			if((old_rgben = '1') and (rgb_en = '0')) then
				p_swap_d <= '0';
				a_swap_d <= '0';
				c_swap_d <= '1';
			else
				p_swap_d <= t_pswap;
				a_swap_d <= t_aswap;
				c_swap_d <= '0';
			end if;
			p_swap_s <= p_swap_d;
			a_swap_s <= a_swap_d;
			c_swap_s <= c_swap_d;
		end if;
	end process;

end Behavioral;
