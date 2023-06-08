library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity PointHoloController is
	port (
		clk		  : in  std_logic;
		start		  : in  std_logic;
		xin		  : in  std_logic_vector (12 downto 0);
		yin		  : in  std_logic_vector (12 downto 0);
		zin		  : in  std_logic_vector (12 downto 0);
		ampin	 	  : in  std_logic_vector (7 downto 0);
		phain	 	  : in  std_logic_vector (6 downto 0);
		rgbin		  : in  std_logic_vector (23 downto 0);
		cen		  : in  std_logic;
		calib		  : in  std_logic_vector (6 downto 0);
		caddress	  : in  std_logic_vector (7 downto 0);
		ack		  : out std_logic;
		holo_en	  : out std_logic;
		holo_phase : out std_logic_vector (6 downto 0);
		holo_amp	  : out std_logic_vector (6 downto 0);
		holo_color : out std_logic_vector (26 downto 0);
		holo_addr  : out std_logic_vector (7 downto 0)
	);
end PointHoloController;

architecture Behavioral of PointHoloController is

	component CalcDistance is
		port (
			clk	  : in  std_logic;
			start	  : in  std_logic;
			xin	  : in  std_logic_vector (12 downto 0);
			yin	  : in  std_logic_vector (12 downto 0);
			zin	  : in  std_logic_vector (12 downto 0);
			ack	  : out std_logic;
			r2		  : out std_logic_vector (23 downto 0);
			r2_en	  : out std_logic;
			r2_addr : out std_logic_vector (7 downto 0) );
	end component;	
	
	component PhaseLUTController is
		port (
			clk	  : in  std_logic;
			r2		  : in  std_logic_vector (23 downto 0);
			r2_en	  : in  std_logic;
			r2_addr : in  std_logic_vector (7 downto 0);
			pdelay  : out std_logic_vector (6 downto 0);
			pd_en	  : out std_logic;
			pd_addr : out std_logic_vector (7 downto 0) );
	end component;
	
	component Calibration is
		port (
			clk		  : in  std_logic;
			cen		  : in  std_logic;
			calib		  : in  std_logic_vector (6 downto 0);
			caddress   : in  std_logic_vector (7 downto 0);
			arctan	  : in  std_logic_vector (6 downto 0);
			at_addr	  : in  std_logic_vector (7 downto 0);
			calibphase : out std_logic_vector (6 downto 0) );
	end component;
	
	component AddressConverter is
		port (
			clk	  : in  std_logic;
			at_en	  : in  std_logic;
			at_addr : in  std_logic_vector (7 downto 0);
			cpen	  : out std_logic;
			cpaddr  : out std_logic_vector (7 downto 0) );
	end component;

	component AmplitudeCorrection is
		port (
			clk		: in  std_logic;
			start		: in  std_logic;
			ampin		: in	 std_logic_vector (7 downto 0);
			ampstart : out std_logic;
			ampout	: out std_logic_vector (6 downto 0) );
	end component;
	
	component GammaCorrection is
		port (
			clk		  : in  std_logic;
			start		  : in  std_logic;
			gammain	  : in  std_logic_vector (23 downto 0);
			gammastart : out std_logic;
			gammaout	  : out std_logic_vector (26 downto 0) );
	end component;

	component PhaseShiftCorrection is
		port (
			clk		  : in  std_logic;
			ampstart	  : in  std_logic;
			ampout	  : in  std_logic_vector (6 downto 0);
			phastart	  : in  std_logic;
			phaout	  : in  std_logic_vector (6 downto 0);
			calibphase : in  std_logic_vector (6 downto 0);
			cpen		  : in  std_logic;
			cpaddr	  : in  std_logic_vector (7 downto 0);
			rgbstart	  : in  std_logic;
			rgbout	  : in  std_logic_vector (26 downto 0);
			phase		  : out std_logic_vector (6 downto 0);
			amplitude  : out std_logic_vector (6 downto 0);
			color		  : out std_logic_vector (26 downto 0);
			enable	  : out std_logic;
			address	  : out std_logic_vector (7 downto 0) );
	end component;	

	signal ack_s	    : std_logic := '0';
	signal r2		    : std_logic_vector (23 downto 0) := (others => '0');
	signal r2_en		 : std_logic := '0';	
	signal r2_addr		 : std_logic_vector (7 downto 0) := (others => '0');
	signal pdelay		 : std_logic_vector (6 downto 0) := (others => '0');
	signal pd_en		 : std_logic := '0';	
	signal pd_addr		 : std_logic_vector (7 downto 0) := (others => '0');
	signal ampstart	 : std_logic := '0';	
	signal ampout		 : std_logic_vector (6 downto 0) := (others => '0');
	signal phastart	 : std_logic := '0';	
	signal phaout		 : std_logic_vector (6 downto 0) := (others => '0');
	signal rgbstart	 : std_logic := '0';	
	signal rgbout		 : std_logic_vector (26 downto 0) := (others => '0');
	
	signal calibphase  : std_logic_vector (6 downto 0) := (others => '0');
	signal cpen		    : std_logic := '0';
	signal cpaddr		 : std_logic_vector (7 downto 0) := (others => '0');

	signal phase_s		 : std_logic_vector (6 downto 0) := (others => '0');
	signal amplitude_s : std_logic_vector (6 downto 0) := (others => '0');
	signal color_s 	 : std_logic_vector (26 downto 0) := (others => '0');
	signal enable_s	 : std_logic := '0';
	signal address_s	 : std_logic_vector (7 downto 0) := (others => '0');

begin

	ack		  <= ack_s;
	holo_en	  <= enable_s;
	holo_phase <= phase_s;
	holo_amp   <= amplitude_s;
	holo_color <= color_s;
	holo_addr  <= address_s;
	
	inst_CalcDistance : CalcDistance
		port map (
			clk	  => clk,
			start   => start,
			xin	  => xin,
			yin	  => yin,
			zin	  => zin,
			ack	  => ack_s,
			r2		  => r2,
			r2_en	  => r2_en,
			r2_addr => r2_addr );

	inst_PhaseLUTController : PhaseLUTController
		port map (
			clk	  => clk,
			r2		  => r2,
			r2_en	  => r2_en,
			r2_addr => r2_addr,
			pdelay  => pdelay,
			pd_en	  => pd_en,
			pd_addr => pd_addr );
			
	inst_Calibration : Calibration
		port map (
			clk	  	  => clk,
			cen		  => cen,
			calib		  => calib,
			caddress   => caddress,
			arctan	  => pdelay,
			at_addr	  => pd_addr,
			calibphase => calibphase );

	inst_AddressConverter : AddressConverter
		port map (
			clk	  => clk,
			at_en	  => pd_en,
			at_addr => pd_addr,
			cpen	  => cpen,
			cpaddr  => cpaddr );
			
	inst_AmplitudeCorrection : AmplitudeCorrection
		port map (
			clk	  	=> clk,
			start		=> start,
			ampin		=> ampin,
			ampstart	=> ampstart,
			ampout	=> ampout );

	inst_GammaCorrection : GammaCorrection
		port map (
			clk	  	  => clk,
			start		  => start,
			gammain	  => rgbin,
			gammastart => rgbstart,
			gammaout	  => rgbout );
			
	inst_PhaseShiftCorrection : PhaseShiftCorrection
		port map (
			clk	  	  => clk,
			ampstart	  => ampstart,
			ampout	  => ampout,
			phastart	  => start,
			phaout	  => phain,
			calibphase => calibphase,
			cpen		  => cpen,
			cpaddr	  => cpaddr,
--			calibphase => pdelay,
--			cpen		  => pd_en,
--			cpaddr	  => pd_addr,
			rgbstart	  => rgbstart,
			rgbout	  => rgbout,
			phase		  => phase_s,
			amplitude  => amplitude_s,
			color		  => color_s,
			enable	  => enable_s,
			address	  => address_s );
		
	 
end Behavioral;