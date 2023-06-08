-----------------------------------------------------------------------------------
--     This block creates the count signal used for timing                       --
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Counter is
	generic(COUNTER_BITS: integer := 10);
	port (
		clk		  : in  std_logic;
		clk_8		  : in  std_logic;
		sync_reset : in  std_logic;
		count		  : out std_logic_vector (COUNTER_BITS-1 downto 0);
		timing	  : out std_logic
	);
end Counter;

architecture Behavioral of Counter is

	-- This block filters the synchronization signal from other board
	component RSSFilter is
	generic (
		TAPS: integer := 31 );
	port (
		clk	  : in  std_logic;
		bit_in  : in  std_logic;
		bit_out : out std_logic );
	end component;
	
	signal count_s		 : std_logic_vector (COUNTER_BITS-1 downto 0) := (others => '0');
	signal current_res : std_logic := '0';
	signal prev_res	 : std_logic := '0';

	signal dflag 	 	 : std_logic := '0';
	signal dcount	 	 : std_logic_vector (7 downto 0) := (others => '0');
	 
	signal timing_s	 : std_logic := '0';
	signal timing_ff1	 : std_logic := '0';
	signal timing_ff2	 : std_logic := '0';
begin

	count <= count_s;
	timing <= timing_s;

	inst_RSSFilter : RSSFilter 
	   generic map (
			TAPS => 31 )
		port map (
			clk	  => clk_8,
			bit_in  => sync_reset,
			bit_out => current_res );

	pCounter: process (clk_8) begin
		if rising_edge(clk_8) then
			prev_res <= current_res;
			if (dflag = '0') then
				if (current_res = '1' and prev_res = '0') then
					dflag <= '1';
				end if;
				count_s <= count_s + 1;
			else
				if (dcount = "11111001") then
					dcount <= (others => '0');
					dflag <= '0';
					count_s <= (others => '0');
				else
					dcount <= dcount + 1;
					count_s <= count_s + 1;
				end if;			
			end if;	
		end if;
	end process;

	process(clk) begin
		if (rising_edge(clk)) then
			timing_ff1 <= count_s(COUNTER_BITS-1);
			timing_ff2 <= timing_ff1;
			timing_s <= timing_ff2;
		end if;
	end process;
	
end Behavioral;