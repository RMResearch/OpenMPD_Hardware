library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Interpolation is
	port (
		clk			: in  std_logic;
		enable_in	: in  std_logic;
		data_a		: in  std_logic_vector (6 downto 0);
		data_b		: in  std_logic_vector (6 downto 0);
		ratio_count	: in  std_logic_vector (1 downto 0);
		address_in	: in  std_logic_vector (7 downto 0);
		swap_in		: in  std_logic;
		enable_out	: out std_logic;
		data_out		: out std_logic_vector (6 downto 0);
		address_out : out std_logic_vector (7 downto 0);
		swap_out		: out std_logic
	);
end Interpolation;

architecture Behavioral of Interpolation is
	
	signal enable_out_s	: std_logic := '0';
	signal data_out_s	 	: std_logic_vector (8 downto 0) := (others => '0'); 
	signal address_out_s : std_logic_vector (7 downto 0) := (others => '0');
	signal swap_out_s		: std_logic := '0';

	signal enable_reg		: std_logic := '0';
	signal data_reg	 	: std_logic_vector (8 downto 0) := (others => '0'); 
	signal address_reg	: std_logic_vector (7 downto 0) := (others => '0');
	signal swap_reg		: std_logic := '0';

	signal count_reg	 	: std_logic_vector (1 downto 0) := (others => '0'); 
	signal d				 	: std_logic_vector (8 downto 0) := (others => '0'); 
	signal d_2			 	: std_logic_vector (8 downto 0) := (others => '0'); 
	signal d_4			 	: std_logic_vector (8 downto 0) := (others => '0'); 

begin

	enable_out <= enable_out_s;	
	data_out <= data_out_s(6 downto 0);
	address_out <= address_out_s;
	swap_out <= swap_out_s;			
			
	d_2 <= d(8) & d(8 downto 1) when count_reg(1) = '1' else (others => '0');
	d_4 <= d(8) & d(8) & d(8 downto 2) when count_reg(0) = '1' else (others => '0');
			
	process (clk) begin 
		if (rising_edge(clk)) then
			count_reg <= ratio_count;
			if((('0' & data_b) - ('0' & data_a) < "11000000") or (('0' & data_b) - ('0' & data_a) > "01000000")) then
				if(data_a(6) = '0') then
					d <= ("00" & data_b) - ("01" & data_a);
				else
					d <= ("01" & data_b) - ("00" & data_a);
				end if;
			else
				d <= ("00" & data_b) - ("00" & data_a);
			end if;
			data_reg <= "00" & data_a;
			enable_reg <= enable_in;
			address_reg <= address_in;
			swap_reg <= swap_in;
			
			data_out_s <= data_reg + d_2 + d_4;
			enable_out_s <= enable_reg;
			address_out_s <= address_reg;
			swap_out_s <= swap_reg;
		end if;
	end process;		
		
end Behavioral;