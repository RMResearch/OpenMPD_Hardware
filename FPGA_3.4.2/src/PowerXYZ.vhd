library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PowerXYZ is
	port (
		clk	  : in  std_logic;
		xjn	  : in  std_logic_vector (12 downto 0);
		yjn	  : in  std_logic_vector (12 downto 0);
		zjn	  : in  std_logic_vector (12 downto 0);
		r2		  : out std_logic_vector (26 downto 0)		
	);
end PowerXYZ;

architecture Behavioral of PowerXYZ is
	
	signal xjn2 : std_logic_vector (25 downto 0) := (others => '0');
	signal yjn2 : std_logic_vector (25 downto 0) := (others => '0');
	signal zjn2 : std_logic_vector (25 downto 0) := (others => '0');
	signal r2_s : std_logic_vector (26 downto 0) := (others => '0');
	
begin

	r2 <= r2_s;
	
	process (clk) begin
		if rising_edge(clk) then
			xjn2 <= xjn * xjn;
			yjn2 <= yjn * yjn;
			zjn2 <= zjn * zjn;	
			r2_s <= ('0' & xjn2) + ('0' & yjn2) + ('0' & zjn2);
		end if;
	end process;
	
end Behavioral;