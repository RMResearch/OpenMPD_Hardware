library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity GammaCorrection is
	port (
		clk		  : in  std_logic;
		start		  : in  std_logic;
		gammain	  : in  std_logic_vector (23 downto 0);
		gammastart : out std_logic;
		gammaout	  : out std_logic_vector (26 downto 0)
	);
end GammaCorrection;

architecture Behavioral of GammaCorrection is

	component GammaCorrectionLUT is
		port (
			address : in  std_logic_vector(7 downto 0);
			clock	  : in  std_logic;
			q		  : out std_logic_vector(8 downto 0) );
	end component;

	type CorrectionState is (Idle, Red, Green, Blue, Output);
	signal state : CorrectionState := Idle;
	
   signal gammareg		: std_logic_vector (15 downto 0) := (others => '0');
   signal gammaout_s		: std_logic_vector (26 downto 0) := (others => '0');
	signal gammastart_s	: std_logic := '0';

   signal address			: std_logic_vector (7 downto 0) := (others => '0');
	signal q					: std_logic_vector (8 downto 0) := (others => '0');	
	
begin

	gammaout <= gammaout_s;
	gammastart <= gammastart_s;
	
	inst_GammaCorrectionLUT : GammaCorrectionLUT
		port map (
			address => address,
			clock	  => clk,
			q		  => q );

	process (clk) begin
		if rising_edge(clk) then
			case state is
				when Idle =>
					if(start = '1') then
						address <= gammain(7 downto 0);
						gammareg <= gammain(23 downto 8);
						state <= Red;
					end if;
					gammastart_s <= '0';
					gammaout_s <= (others => '0');
			
				when Red => 
					address <= gammareg(7 downto 0);
					state <= Green;
				
				when Green =>
					address <= gammareg(15 downto 8);
					gammaout_s(8 downto 0) <= q;
					gammareg <= (others => '0');
					state <= Blue;
				
				when Blue =>
					address <= (others => '0');
					gammaout_s(17 downto 9) <= q;
					state <= Output;
					
				when Output =>
					gammastart_s <= '1';
					gammaout_s(26 downto 18) <= q;
					state <= Idle;
		
				when others => 
					
			end case;
		end if;
	end process;
	 
end Behavioral;