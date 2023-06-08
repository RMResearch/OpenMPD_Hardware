library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity AmplitudeCorrection is
	port (
		clk		: in  std_logic;
		start		: in  std_logic;
		ampin		: in	 std_logic_vector (7 downto 0);
		ampstart : out std_logic;
		ampout	: out std_logic_vector (6 downto 0)
	);
end AmplitudeCorrection;

architecture Behavioral of AmplitudeCorrection is

	component AmplitudeCorrectionLUT is
		port (
			address : in  std_logic_vector(7 downto 0);
			clock	  : in  std_logic;
			q		  : out std_logic_vector(6 downto 0) );
	end component;

   signal ampout_s   : std_logic_vector(6 downto 0) := (others => '0');
	signal ampstart_s	: std_logic := '0';

begin

	ampstart <= ampstart_s;
	ampout <= ampout_s;
	
	inst_AmplitudeCorrectionLUT : AmplitudeCorrectionLUT
		port map (
			address => ampin,
			clock	  => clk,
			q		  => ampout_s );

	process (clk) begin
		if rising_edge(clk) then
			ampstart_s <= start;
		end if;
	end process;
	 
end Behavioral;