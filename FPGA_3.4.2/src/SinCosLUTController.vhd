library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity SinCosLUTController is
	port (
		clk	  : in  std_logic;
		pdelay  : in  std_logic_vector (7 downto 0);
		pd_en	  : in  std_logic;
		pd_addr : in  std_logic_vector (7 downto 0);
		sin	  : out std_logic_vector (7 downto 0);
		cos	  : out std_logic_vector (7 downto 0);
		sc_en	  : out std_logic;
		sc_addr : out std_logic_vector (7 downto 0)
	);
end SinCosLUTController;

architecture Behavioral of SinCosLUTController is
	
	signal address	  : std_logic_vector (7 downto 0) := (others => '0');
	signal flag		  : std_logic_vector (1 downto 0) := (others => '0');
	
	signal sin_s	  : std_logic_vector (7 downto 0) := (others => '0');
	signal cos_s	  : std_logic_vector (7 downto 0) := (others => '0');
	signal sc_en_s	  : std_logic := '0';
	signal sc_addr_s : std_logic_vector (7 downto 0) := (others => '0');
	
	signal sc_en_d	  : std_logic := '0';
	signal sc_addr_d : std_logic_vector(7 downto 0) := (others => '0');
		
	subtype WAVE is std_logic_vector(6 downto 0);
	type ROM is array (0 to 64) of WAVE;
	constant SIN_ROM : ROM := (	
		"0000000", "0000011", "0000110", "0001001", "0001100", "0010000", "0010011", "0010110", 
		"0011001", "0011100", "0011111", "0100010", "0100101", "0101000", "0101011", "0101110", 
		"0110001", "0110011", "0110110", "0111001", "0111100", "0111111", "1000001", "1000100", 
		"1000111", "1001001", "1001100", "1001110", "1010001", "1010011", "1010101", "1011000", 
		"1011010", "1011100", "1011110", "1100000", "1100010", "1100100", "1100110", "1101000", 
		"1101010", "1101011", "1101101", "1101111", "1110000", "1110001", "1110011", "1110100", 
		"1110101", "1110110", "1111000", "1111001", "1111010", "1111010", "1111011", "1111100", 
		"1111101", "1111101", "1111110", "1111110", "1111110", "1111111", "1111111", "1111111", "1111111" );

	
	constant COS_ROM : ROM := (
		"1111111", "1111111", "1111111", "1111111", "1111110", "1111110", "1111110", "1111101", 
		"1111101", "1111100", "1111011", "1111010", "1111010", "1111001", "1111000", "1110110", 
		"1110101", "1110100", "1110011", "1110001", "1110000", "1101111", "1101101", "1101011", 
		"1101010", "1101000", "1100110", "1100100", "1100010", "1100000", "1011110", "1011100", 
		"1011010", "1011000", "1010101", "1010011", "1010001", "1001110", "1001100", "1001001", 
		"1000111", "1000100", "1000001", "0111111", "0111100", "0111001", "0110110", "0110011", 
		"0110001", "0101110", "0101011", "0101000", "0100101", "0100010", "0011111", "0011100", 
		"0011001", "0010110", "0010011", "0010000", "0001100", "0001001", "0000110", "0000011", "0000000" );	
	
begin

	sin <= sin_s;
	cos <= cos_s;
	sc_en <= sc_en_s;
	sc_addr <= sc_addr_s;
	
	process (clk) begin
		if rising_edge(clk) then		
			if(pdelay(6) = '0') then 
				address <= "00" & pdelay(5 downto 0);
			else
				address <= "01000000" - ('0' & pdelay(5 downto 0));
			end if;
			
			flag <= pdelay(7 downto 6);
		
			if(flag(1) = '0') then
				sin_s <= '0' & SIN_ROM(CONV_INTEGER(address));
			else
				sin_s <= - ('0' & SIN_ROM(CONV_INTEGER(address)));
			end if;
			
			if(flag(0) = flag(1)) then
				cos_s <= '0' & COS_ROM(CONV_INTEGER(address));
			else
				cos_s <= - ('0' & COS_ROM(CONV_INTEGER(address)));			
			end if;
			
			sc_en_d <= pd_en;
			sc_en_s <= sc_en_d;
			sc_addr_d <= pd_addr;
			sc_addr_s <= sc_addr_d;
		end if;
	end process;
	
end Behavioral;