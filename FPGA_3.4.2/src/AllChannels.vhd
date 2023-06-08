library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity AllChannels is
   generic (
		NUM_TRANSDUCERS: integer := 256 );	
	port (
		clk		 : in  std_logic;
		clk_8		 : in  std_logic;
		count		 : in  std_logic_vector(9 downto 0);
		phase	 	 : in  std_logic_vector(6 downto 0);
		amplitude : in  std_logic_vector(6 downto 0);
		color		 : in  std_logic_vector(26 downto 0);
		address	 : in  std_logic_vector(7 downto 0);
		p_enable  : in  std_logic;
		a_enable  : in  std_logic;
		c_enable	 : in  std_logic;
		p_swap 	 : in  std_logic;
		a_swap	 : in  std_logic;
		c_swap	 : in  std_logic;
		data		 : out std_logic_vector(31 downto 0);
		illumi	 : out std_logic_vector(2 downto 0);
		rclk		 : out std_logic;
		synccnt	 : out std_logic_vector(7 downto 0)
	);
	
end AllChannels;

architecture Behavioral of AllChannels is

component PhaseRAM
	port (
		data		 : in  std_logic_vector (6 downto 0);
		rdaddress : in  std_logic_vector (3 downto 0);
		rdclock	 : in  std_logic;
		wraddress : in  std_logic_vector (8 downto 0);
		wrclock	 : in  std_logic;
		wren		 : in  std_logic;
		q			 : out std_logic_vector (223 downto 0) );
end component;

component AmplitudeRAM
	port (
		data		 : in  std_logic_vector (6 downto 0);
		rdaddress : in  std_logic_vector (3 downto 0);
		rdclock	 : in  std_logic;
		wraddress : in  std_logic_vector (8 downto 0);
		wrclock	 : in  std_logic;
		wren		 : in  std_logic;
		q			 : out std_logic_vector (223 downto 0) );
end component;

component MuxPhase
	port ( 
		clk 		 : in  std_logic;
		phase		 : in  std_logic_vector(6 downto 0);
		amplitude : in  std_logic_vector(6 downto 0);
		count		 : in  std_logic_vector(6 downto 0);
		mux_pulse : out std_logic );
end component;

component PulseWidthModulator is
	port (
		clk_8		 : in  std_logic;
		color_in	 : in	std_logic_vector (26 downto 0);
		count 	 : in  std_logic_vector (8 downto 0);
		color_out : out std_logic_vector (2 downto 0)
	);
end component;

signal data_s		 : std_logic_vector(31 downto 0) := (others=>'0');
signal illumi_s	 : std_logic_vector(2 downto 0) := (others => '0');
signal rclk_s		 : std_logic := '0';
signal synccnt_s	 : std_logic_vector(7 downto 0) := (others=>'0');

signal mux_count	 : std_logic_vector(6 downto 0) := (others=>'0');
signal old_enable	 : std_logic := '0';
signal p_state		 : std_logic := '0';
signal a_state		 : std_logic := '0';
signal c_state		 : std_logic := '0';
signal p_state_n		 : std_logic := '1';
signal a_state_n		 : std_logic := '1';
signal c_state_n		 : std_logic := '1';
signal p_state_ff	 : std_logic_vector(1 downto 0) := (others=>'0');
signal a_state_ff	 : std_logic_vector(1 downto 0) := (others=>'0');
signal c_state_ff	 : std_logic_vector(1 downto 0) := (others=>'0');

signal p_data	 : std_logic_vector(6 downto 0) := (others=>'0');
signal a_data	 : std_logic_vector(6 downto 0) := (others => '0');
signal p_wren	 : std_logic := '0';
signal a_wren		 : std_logic := '0';
signal p_wraddr		 : std_logic_vector(8 downto 0) := (others=>'0');
signal a_wraddr		 : std_logic_vector(8 downto 0) := (others=>'0');
signal p_rdaddr		 : std_logic_vector(3 downto 0) := (others=>'0');
signal a_rdaddr		 : std_logic_vector(3 downto 0) := (others=>'0');
signal phases		 : std_logic_vector(223 downto 0) := (others=>'0');
signal amplitudes  : std_logic_vector(223 downto 0) := (others => '0');

signal color_reg0	 : std_logic_vector(26 downto 0) := (others => '0');
signal color_reg1	 : std_logic_vector(26 downto 0) := (others => '0');
signal color_reg0_ff0 : std_logic_vector(26 downto 0) := (others => '0');
signal color_reg0_ff1 : std_logic_vector(26 downto 0) := (others => '0');
signal color_reg1_ff0 : std_logic_vector(26 downto 0) := (others => '0');
signal color_reg1_ff1 : std_logic_vector(26 downto 0) := (others => '0');
signal color_out_d0 : std_logic_vector(26 downto 0) := (others => '0');
signal color_out_d1 : std_logic_vector(26 downto 0) := (others => '0');
		
signal rclk_d		 : std_logic_vector(5 downto 0) := (others=>'0');

signal count_ff1 : std_logic_vector(7 downto 0) := (others=>'0');
signal count_ff2 : std_logic_vector(7 downto 0) := (others=>'0');

begin
	
	data	  <= data_s;
	illumi  <= illumi_s;
	rclk	  <= rclk_s;
	synccnt <= synccnt_s;
	
	PhaseRAM_inst : PhaseRAM
	port map (
		data		 => p_data,
		rdaddress => p_rdaddr,
		rdclock	 => clk_8,
		wraddress => p_wraddr,
		wrclock	 => clk,
		wren		 => p_wren,
		q			 => phases );

	AmplitudeRAM_inst : AmplitudeRAM
	port map (
		data		 => a_data,
		rdaddress => a_rdaddr,
		rdclock	 => clk_8,
		wraddress => a_wraddr,
		wrclock	 => clk,
		wren		 => a_wren,
		q			 => amplitudes );

	MuxPhases : for i in 0 to (NUM_TRANSDUCERS/8-1) generate
	begin
		MuxPhase_inst : MuxPhase
		port map (
			clk	 	 => clk_8,
			phase	 	 => phases(i*7+6 downto i*7),
			amplitude => amplitudes(i*7+6 downto i*7),
			count		 => mux_count,		   
			mux_pulse => data_s(i) );
	end generate MuxPhases;

	PulseWidthModulator_inst : PulseWidthModulator
	port map (
		clk_8		 => clk_8,
		color_in  => color_out_d1,
		count 	 => count(9 downto 1),
		color_out => illumi_s );
	
	process(clk) begin
		if (rising_edge(clk)) then
			if(p_swap = '1') then
				p_state <= not p_state;
			end if;
			if(a_swap = '1') then
				a_state <= not a_state;
			end if;
			if(c_swap = '1') then
				c_state <= not c_state;
			end if;			
			
			p_data <= phase;
			a_data <= amplitude;
			p_wren <= p_enable;
			a_wren   <= a_enable;
			p_wraddr	<= p_state & address(2 downto 0) & address(7 downto 3);			
			a_wraddr	<= a_state & address(2 downto 0) & address(7 downto 3);				
			if(c_enable = '1') then
				if (c_state = '0') then
					color_reg0 <= color;
				else
					color_reg1 <= color;
				end if;		
			end if;
			
			count_ff1 <= count(9 downto 2);
			count_ff2 <= count_ff1;
			synccnt_s <= count_ff2;
		end if;
	end process;
	
	
	p_rdaddr	<= p_state_n & count(2 downto 0);
	a_rdaddr	<= a_state_n & count(2 downto 0);
	AllChannels: process (clk_8) begin 
		if (rising_edge(clk_8)) then
			mux_count <= count(9 downto 3);
			p_state_ff(0) <= p_state;
			p_state_ff(1) <= p_state_ff(0);
			a_state_ff(0) <= a_state;
			a_state_ff(1) <= a_state_ff(0);
			c_state_ff(0) <= c_state;
			c_state_ff(1) <= c_state_ff(0);
			if(count = "1111111111") then
				p_state_n <= not p_state_ff(1);
				a_state_n <= not a_state_ff(1);
				c_state_n <= not c_state_ff(1);
			end if;
			
			color_reg0_ff0 <= color_reg0;
			color_reg0_ff1 <= color_reg0_ff0;
			color_reg1_ff0 <= color_reg1;
			color_reg1_ff1 <= color_reg1_ff0;
			if(c_state_n = '0') then
				color_out_d0 <= color_reg0_ff1;
			else
				color_out_d0 <= color_reg1_ff1;
			end if;
			color_out_d1 <= color_out_d0;
			
			rclk_d(0) <= count(2);
			rclk_d(1) <= rclk_d(0);
			rclk_d(2) <= rclk_d(1);
			rclk_d(3) <= rclk_d(2);
			rclk_d(4) <= rclk_d(3);
			rclk_d(5) <= rclk_d(4);
			rclk_s <= rclk_d(5); -- My parameter
		end if;
	end process;

end Behavioral;