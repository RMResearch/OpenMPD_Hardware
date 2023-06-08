library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PulseWidthModulator is
    port (
        clk_8		: in  std_logic;
		  color_in	: in	std_logic_vector (26 downto 0);
		  count 		: in  std_logic_vector (8 downto 0);
        color_out	: out std_logic_vector (2 downto 0)
	 );
end PulseWidthModulator;

architecture Behavioral of PulseWidthModulator is

    signal color_out_s : std_logic_vector (2 downto 0) := (others => '0');
    signal red			  : std_logic_vector (8 downto 0) := (others => '0');
    signal green		  : std_logic_vector (8 downto 0) := (others => '0');
    signal blue		  : std_logic_vector (8 downto 0) := (others => '0');
    signal count_d0	  : std_logic_vector (8 downto 0) := (others => '0');
    signal count_d1	  : std_logic_vector (8 downto 0) := (others => '0');
	 
begin

	color_out <= color_out_s;
	red <= color_in(8 downto 0);
	green <= color_in(17 downto 9);
	blue <= color_in(26 downto 18);
	
	process (clk_8) begin
		if rising_edge(clk_8) then
			count_d0 <= count;
			count_d1 <= count_d0;
			
			if (count_d1 < red) then
				color_out_s(0) <= '1';
			else
				color_out_s(0) <= '0';
			end if;
			
			if (count_d1 < green) then
				color_out_s(1) <= '1';
			else
				color_out_s(1) <= '0';
			end if;

			if (count_d1 < blue) then
				color_out_s(2) <= '1';
			else
				color_out_s(2) <= '0';
			end if;			
		end if;
	end process;
	 
end Behavioral;