library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PhaseShiftCorrection is
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
		address	  : out std_logic_vector (7 downto 0)
	);
end PhaseShiftCorrection;

architecture Behavioral of PhaseShiftCorrection is

	signal phase_s		 : std_logic_vector (6 downto 0) := (others => '0');
	signal amplitude_s : std_logic_vector (6 downto 0) := (others => '0');
	signal color_s		 : std_logic_vector (26 downto 0) := (others => '0');
	signal enable_s	 : std_logic := '0';
	signal address_s	 : std_logic_vector (7 downto 0) := (others => '0');

	signal old_cpen	 : std_logic := '0';
	signal ampreg	 	 : std_logic_vector (6 downto 0) := (others => '0');
	signal ampreg2		 : std_logic_vector (6 downto 0) := (others => '0');
	signal phareg	 	 : std_logic_vector (6 downto 0) := (others => '0');
	signal rgbreg	 	 : std_logic_vector (26 downto 0) := (others => '0');
	signal rgbreg2		 : std_logic_vector (26 downto 0) := (others => '0');
	signal shift		 : std_logic_vector (6 downto 0) := (others => '0');
	signal correctreg	 : std_logic_vector (6 downto 0) := (others => '0');
	signal correct		 : std_logic_vector (6 downto 0) := (others => '0');

begin

	phase		 <= phase_s;
	amplitude <= amplitude_s;
	color		 <= color_s;
	enable	 <= enable_s;
	address   <= address_s;
	
	process(clk) begin
		if (rising_edge(clk)) then
			if(ampstart = '1') then
				ampreg <= ampout;
				shift <= "1000000" - ampout;
			end if;
			if(phastart = '1') then
				phareg <= phaout;
			end if;
			if(rgbstart = '1') then
				rgbreg <= rgbout;
			end if;
	
			correctreg <= phareg + ('0' & shift(6 downto 1));
	
			old_cpen <= cpen;
			if(cpen = '1' and old_cpen = '0') then
				phase_s <= calibphase + correctreg;
				amplitude_s <= ampreg;
				correct <= correctreg;
				ampreg2 <= ampreg;
				color_s <= rgbreg;
				rgbreg2 <= rgbreg;
			else
				phase_s <= calibphase + correct;
				amplitude_s <= ampreg2;
				color_s <= rgbreg2;
			end if;
			
			enable_s <= cpen;
			address_s <= cpaddr;
		end if;
	end process;
	 
end Behavioral;