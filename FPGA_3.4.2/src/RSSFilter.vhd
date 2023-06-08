-----------------------------------------------------------------------------------
--     This block filters the synchronization signal from other board            --
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RSSFilter is
	generic (
		TAPS: integer := 15 );
	port (
		clk	  : in  std_logic;
		bit_in  : in  std_logic;
		bit_out : out std_logic );
end RSSFilter;

architecture Behavioral of RSSFilter is
	signal data		: std_logic_vector (TAPS-1 downto 0) := (others => '1');
	signal sout		: std_logic := '1';
	signal count_0 : integer range 0 to TAPS := 0;
	signal count_1 : integer range 0 to TAPS := TAPS;
begin

	pRSSFilter: process (clk) begin
		if rising_edge(clk) then
			--update the value counters
			if (data(0) = '0' and data(TAPS-1) = '1') then
				count_0 <= count_0 + 1;
				count_1 <= count_1 - 1;
			elsif (data(0) = '1' and data(TAPS-1) = '0') then
				count_0 <= count_0 - 1;
				count_1 <= count_1 + 1;
			end if;

			--shift data
			data <= data(TAPS-2 downto 0) & bit_in;

			-- the output depends on the value that has the most appearances
			if (count_1 > count_0) then
				sout <= '1';
			else
				sout <= '0';
			end if;
		end if;
	end process;

	bit_out <= sout;
	
end Behavioral;