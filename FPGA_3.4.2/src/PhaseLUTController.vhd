library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PhaseLUTController is
	port (
		clk	  : in  std_logic;
		r2		  : in  std_logic_vector (23 downto 0);
		r2_en	  : in  std_logic;
		r2_addr : in  std_logic_vector (7 downto 0);
		pdelay  : out std_logic_vector (6 downto 0);
		pd_en	  : out std_logic;
		pd_addr : out std_logic_vector (7 downto 0)
	);
end PhaseLUTController;

architecture Behavioral of PhaseLUTController is
	
	component PhaseLUT is
		port (
			address : in  std_logic_vector(13 downto 0);
			clock	  : in  std_logic;
			q		  : out std_logic_vector(6 downto 0) );
	end component;
	
   signal pdelay_s   : std_logic_vector(6 downto 0) := (others => '0');
	signal pd_en_s	   : std_logic := '0';
	signal pd_addr_s  : std_logic_vector(7 downto 0) := (others => '0');
			
	signal address	   : std_logic_vector(13 downto 0) := (others => '0');	
	signal pd_en_d	   : std_logic := '0';
	signal pd_addr_d  : std_logic_vector(7 downto 0) := (others => '0');

begin

	pdelay <= pdelay_s;
	pd_en <= pd_en_s;
	pd_addr <= pd_addr_s;
	
	inst_PhaseLUT : PhaseLUT
		port map (
			address => address,
			clock	  => clk,
			q		  => pdelay_s );

	process (clk) begin
		if rising_edge(clk) then
			if(r2 < "000000000000000000001000") then
				address <= "00000000000" & r2(2 downto 0);
			elsif(r2 < "000000000000000000100000") then
				address <= "1000000000" & r2(4 downto 1);
			elsif(r2 < "000000000000000010000000") then
				address <= "000000000" & r2(6 downto 2);
			elsif(r2 < "000000000000001000000000") then
				address <= "10000000" & r2(8 downto 3);
			elsif(r2 < "000000000000100000000000") then
				address <= "0000000" & r2(10 downto 4);
			elsif(r2 < "000000000010000000000000") then
				address <= "100000" & r2(12 downto 5);
			elsif(r2 < "000000001000000000000000") then
				address <= "00000" & r2(14 downto 6);
			elsif(r2 < "000000100000000000000000") then
				address <= "1000" & r2(16 downto 7);
			elsif(r2 < "000010000000000000000000") then
				address <= "000" & r2(18 downto 8);
			elsif(r2 < "001000000000000000000000") then
				address <= "10" & r2(20 downto 9);
			elsif(r2 < "100000000000000000000000") then
				address <= "0" & r2(22 downto 10);
			else
				address <= "1" & r2(23 downto 11);
			end if;
				
			pd_en_d <= r2_en;
			pd_en_s <= pd_en_d;
			pd_addr_d <= r2_addr;
			pd_addr_s <= pd_addr_d;
		end if;
	end process;
	 
end Behavioral;