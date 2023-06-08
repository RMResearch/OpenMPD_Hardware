-----------------------------------------------------------------------------------
--     This block converts the input signal into the actual data                 --
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity CommandReader is
	generic (
		NUM_TRANSDUCERS : integer := 256
	);
	port (
		clk		 : in  std_logic;
		byte_in   : in  std_logic;
		q_in 	    : in  std_logic_vector (7 downto 0);
		divider	 : out std_logic_vector (7 downto 0);
		t_en		 : out std_logic;
		t_flag	 : out std_logic;
		t_data	 : out std_logic_vector (6 downto 0);
		t_address : out std_logic_vector (7 downto 0);
		t_pswap   : out std_logic;
		t_aswap   : out std_logic;
		rgb_data	 : out std_logic_vector (23 downto 0);
		rgb_en	 : out std_logic;
		debugled  : out std_logic_vector (3 downto 0)
	);
end CommandReader;

architecture Behavioral of CommandReader is
	
	component RSSFilter is
	generic (
		TAPS: integer := 7 );
	port (
		clk	  : in  std_logic;
		bit_in  : in  std_logic;
		bit_out : out std_logic );
	end component;

	signal mode 		: std_logic := '0';
	type GSPATCommandState is (GSPATIdle, GSPATReadPhases, GSPATReadAmplitudes, GSPATDataSwap );
	signal GSPATstate : GSPATCommandState := GSPATIdle;	

	signal modeCount 	: std_logic_vector (7 downto 0) := (others => '0'); 
	
	signal divider_s	 : std_logic_vector (7 downto 0) := "00000100"; 
	signal t_en_s		 : std_logic := '0';
	signal t_flag_s	 : std_logic := '0';
	signal t_data_s	 : std_logic_vector (6 downto 0) := (others => '0');
	signal t_address_s : std_logic_vector (7 downto 0) := (others => '0');
	signal t_pswap_s	 : std_logic := '0';
	signal t_aswap_s	 : std_logic := '0';

	signal rgb_data_s	 : std_logic_vector (23 downto 0) := (others => '0');
	signal rgb_en_s	 : std_logic := '0';
	signal debugled_s  : std_logic_vector (3 downto 0) := (others => '0');

	signal byteCount	 : std_logic_vector (7 downto 0) := (others => '0');
	signal rgbFlag		 : std_logic := '0';
	signal divider_reg : std_logic_vector (7 downto 0) := (others => '0');
begin

	divider	 <= divider_s;
	t_en      <= t_en_s;
	t_flag    <= t_flag_s;
	t_data    <= t_data_s;
	t_address <= t_address_s;
	t_pswap   <= t_pswap_s;
	t_aswap   <= t_aswap_s;

	rgb_data  <= rgb_data_s;
	rgb_en	 <= rgb_en_s;
	debugled  <= debugled_s;
	
	process (clk) begin
		if (rising_edge(clk)) then
			debugled_s <= "0010";
			case GSPATstate is
				when GSPATIdle => 
					if (byte_in = '1' and q_in(7) = '1') then
						GSPATstate <= GSPATReadPhases;
						t_en_s <= '1';
						t_data_s <= q_in(6 downto 0);
						byteCount <= byteCount + '1';
					else
						GSPATstate <= GSPATIdle;
						t_en_s <= '0';
						t_data_s <= (others => '0');
						byteCount <= (others => '0');				
					end if;
					t_address_s <= (others => '0');
					t_flag_s <= '0';
					t_pswap_s <= '0';
					t_aswap_s <= '0';
					rgb_en_s <= '0';
					rgbFlag <= '0';
				
				when GSPATReadPhases =>
					if (byte_in = '1') then
						if (byteCount = NUM_TRANSDUCERS - 1) then
							GSPATstate <= GSPATReadAmplitudes;
							byteCount <= (others => '0');
						else
							GSPATstate <= GSPATReadPhases;
							byteCount <= byteCount + '1';
						end if;
						t_en_s <= '1';
						t_data_s <= q_in(6 downto 0);
						t_address_s <= byteCount;
						
						if(byteCount < 25) then
							rgb_data_s(CONV_INTEGER(byteCount - '1')) <= q_in(7);
						elsif(byteCount = 25) then
							rgbFlag <= q_in(7);
						elsif(byteCount < 34) then
							divider_reg(CONV_INTEGER(byteCount) - 26) <= q_in(7);
						elsif(byteCount = 34) then
							if(q_in(7) = '1') then
								divider_s <= divider_reg;
							end if;
						end if;
					else
						t_en_s <= '0';
						t_data_s <= (others => '0');
						t_address_s <= (others => '0');
					end if;
					t_flag_s <= '0';
					t_pswap_s <= '0';
					t_aswap_s <= '0';
					rgb_en_s <= '0';
					
				when GSPATReadAmplitudes =>
					if (byte_in = '1') then
						if (byteCount = NUM_TRANSDUCERS - 1) then
							GSPATstate <= GSPATDataSwap;
							byteCount <= (others => '0');
						else
							GSPATstate <= GSPATReadAmplitudes;
							byteCount <= byteCount + '1';
						end if;
						t_en_s <= '1';
						t_data_s <= q_in(6 downto 0);
						t_address_s <= byteCount;
					else
						t_en_s <= '0';
						t_data_s <= (others => '0');
						t_address_s <= (others => '0');
					end if;
					t_flag_s <= '1';
					t_pswap_s <= '0';
					t_aswap_s <= '0';
					rgb_en_s <= '0';

				when GSPATDataSwap =>
					GSPATstate <= GSPATIdle;
					t_en_s <= '0';
					t_data_s <= (others => '0');
					t_address_s <= (others => '0');
					t_flag_s <= '0';			
					t_pswap_s <= '1';
					t_aswap_s <= '1';
					rgb_en_s <= rgbFlag;
					
				when others =>
					GSPATstate <= GSPATIdle;
			
			end case;
			
		end if;
	end process;
		
end Behavioral;
