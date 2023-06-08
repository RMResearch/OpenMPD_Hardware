library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PointHolo is
	 generic(COORDINATE_BITS: integer := 8);
    port (
		clk	  : in  std_logic;
		start	  : in  std_logic;
		xin	  : in  std_logic_vector (COORDINATE_BITS-1 downto 0);
		yin	  : in  std_logic_vector (COORDINATE_BITS-1 downto 0);
		zin	  : in  std_logic_vector (COORDINATE_BITS-1 downto 0);
		phase	  : out std_logic_vector (7 downto 0); 
		address : out std_logic_vector (7 downto 0)
	 );
end PointHolo;

architecture Behavioral of PointHolo is

	type CalcState is (Idle, Calculation);
	signal state : CalcState := Idle;

	signal xreg : std_logic_vector (COORDINATE_BITS-1 downto 0) := (others => '0');
	signal yreg : std_logic_vector (COORDINATE_BITS-1 downto 0) := (others => '0');
	signal zreg : std_logic_vector (COORDINATE_BITS-1 downto 0) := (others => '0');
 
begin

	p: process (clk) begin
		if rising_edge(clk) then
			case state is
				when Idle =>
					if (start = '1') then
						xreg <= xin;
						yreg <= yin;
						zreg <= zin;
						state <= Calculation;
					end if;
				
				when Calculation =>
				
				
				when others =>
					
			end case;
		end if;
	end process;
	 
end Behavioral;