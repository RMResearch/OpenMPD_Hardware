library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity InputSelector is
	port (
		clk		 	 : in  std_logic;
		phen		 	 : in  std_logic;
		phphase 	 	 : in  std_logic_vector (5 downto 0);
		phaddress 	 : in  std_logic_vector (7 downto 0);
		mhen		 	 : in  std_logic;
		mhphase	 	 : in  std_logic_vector (5 downto 0);
		mhaddress 	 : in  std_logic_vector (7 downto 0);
		mhswap	 	 : in  std_logic;
		ampstart	 	 : in  std_logic;
		ampout	 	 : in  std_logic_vector (5 downto 0);
		outen		 	 : out std_logic;
		outphase	 	 : out std_logic_vector (5 downto 0);
		outaddress	 : out std_logic_vector (7 downto 0);
		outstart		 : out std_logic;
		outamplitude : out std_logic_vector (5 downto 0)
	);
end InputSelector;

architecture Behavioral of InputSelector is

component InputRAM IS
	port (
		clock		 : in  std_logic  := '1';
		data		 : in  std_logic_vector (5 downto 0);
		rdaddress : in  std_logic_vector (7 downto 0);
		wraddress : in  std_logic_vector (7 downto 0);
		wren		 : in  std_logic  := '0';
		q			 : out std_logic_vector (5 downto 0) );
end component;

	type StateMachine is (Idle, ReadRAM, Update);
	signal state : StateMachine := Idle;

	signal outen_s	 	 	 : std_logic := '0';
	signal outphase_s	 	 : std_logic_vector (5 downto 0) := (others => '0');
	signal outaddress_s	 : std_logic_vector (7 downto 0) := (others => '0');
	signal outstart_s	 	 : std_logic := '0';
	signal outamplitude_s : std_logic_vector (5 downto 0) := (others => '0');

	signal q				 	 : std_logic_vector (5 downto 0) := (others => '0');
	signal rdaddress	 	 : std_logic_vector (7 downto 0) := (others => '0');
	signal count	 	 	 : std_logic_vector (7 downto 0) := (others => '0');
	
begin
	
	outen <= outen_s;
	outphase <= outphase_s;
	outaddress <= outaddress_s;
	outstart <= outstart_s;
	outamplitude <= outamplitude_s;
	
	inst_InputRAM : InputRAM
		port map (
			clock		 => clk,
			data	 	 => mhphase,
			rdaddress => rdaddress,
			wraddress => mhaddress,
			wren		 => mhen,
			q		    => q );

	process (clk) begin
		if rising_edge(clk) then
			case state is
				when Idle => 
					if(mhswap = '1') then
						state <= ReadRAM;
						rdaddress <= rdaddress + '1';
						outstart_s <= '1';
						outamplitude_s <= "100000";
					else
						rdaddress <= (others => '0');
						outstart_s <= ampstart;
						outamplitude_s <= ampout;
					end if;
					outen_s <= phen;
					outphase_s <= phphase;
					outaddress_s <= phaddress;
					count <= rdaddress;
				
				when ReadRAM =>
					if(rdaddress = "11111111") then
						state <= Update;
						rdaddress <= (others => '0');
					else
						rdaddress <= rdaddress + '1';
					end if;
					outen_s <= '1';
					outphase_s <= q;
					outaddress_s <= count;
					outstart_s <= '0';
					outamplitude_s <= "000000";
					count <= rdaddress;			
					
				when Update =>
					state <= Idle;
					outen_s <= '1';
					outphase_s <= q;
					outaddress_s <= count;
					count <= rdaddress;								
				
				when others =>
			end case;
			
		end if;
	end process;
	 
end Behavioral;