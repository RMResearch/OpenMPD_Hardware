library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MuxPhase is
	port ( 
		clk 		 : in   std_logic;
		phase		 : in   std_logic_vector (6 downto 0);
		amplitude : in   std_logic_vector (6 downto 0);
		count		 : in   std_logic_vector (6 downto 0);
		mux_pulse : out  std_logic );
end MuxPhase;

architecture Behavioral of MuxPhase is
	
	signal s_phase	  : std_logic_vector(7 downto 0) := (others=>'0');
	signal s_count	  : std_logic_vector(7 downto 0) := (others=>'0');
	signal end_count : std_logic_vector(7 downto 0) := (others=>'0');
	
begin

	MuxPhase: process (clk) begin 
		if (rising_edge(clk)) then
			s_phase <= '0' & phase;
			s_count <= '0' & count;
			end_count <= ('0' & phase) + ('0' & amplitude);
			
			if(((s_count >= s_phase) and (s_count < end_count)) or ((end_count(7) = '1') and (s_count(6 downto 0) < end_count(6 downto 0)))) then
				mux_pulse <= '1';
			else
				mux_pulse <= '0';
			end if;
		end if;
	end process;

end Behavioral;

