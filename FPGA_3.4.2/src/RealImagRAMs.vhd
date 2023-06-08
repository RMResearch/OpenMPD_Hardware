library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity RealImagRAMs is
	port (
		clk	  : in  std_logic;
		bfstate : in  std_logic;
		init	  : in  std_logic;
		din	  : in  std_logic_vector (7 downto 0);
		wren	  : in  std_logic;
		wraddr  : in  std_logic_vector (7 downto 0);
		rden	  : in  std_logic;
		rdaddr  : in  std_logic_vector (7 downto 0);
		dout	  : out std_logic_vector (11 downto 0)
	);
end RealImagRAMs;

architecture Behavioral of RealImagRAMs is
	
	component SummationRAM IS
		port (
			clock		 : in  std_logic  := '1';
			data		 : in  std_logic_vector (11 downto 0);
			rdaddress : in  std_logic_vector (7 downto 0);
			wraddress : in  std_logic_vector (7 downto 0);
			wren		 : in  std_logic  := '0';
			q			 : out std_logic_vector (11 downto 0)
		);
	end component;

	signal dout_s	  : std_logic_vector (11 downto 0) := (others => '0');
	
	signal data1	  : std_logic_vector (11 downto 0) := (others => '0');
	signal data2	  : std_logic_vector (11 downto 0) := (others => '0');
	signal rdaddr1   : std_logic_vector (7 downto 0) := (others => '0');
	signal rdaddr2   : std_logic_vector (7 downto 0) := (others => '0');
	signal wraddr1   : std_logic_vector (7 downto 0) := (others => '0');
	signal wraddr2   : std_logic_vector (7 downto 0) := (others => '0');
	signal wren1	  : std_logic := '0';
	signal wren2	  : std_logic := '0';
	signal q1	     : std_logic_vector (11 downto 0) := (others => '0');
	signal q2	     : std_logic_vector (11 downto 0) := (others => '0');
	
	signal rden_d    : std_logic := '0';
	signal sig		  : std_logic := '0';
	signal sumin	  : std_logic_vector (7 downto 0) := (others => '0');
	signal sumen     : std_logic := '0';
	signal sumen_d   : std_logic := '0';
	signal sumaddr	  : std_logic_vector (7 downto 0) := (others => '0');
	signal sumaddr_d : std_logic_vector (7 downto 0) := (others => '0');
	
begin

	dout <= dout_s;

	rdaddr1 <= wraddr when bfstate = '0' else rdaddr; 
	rdaddr2 <= wraddr when bfstate = '1' else rdaddr;
	wraddr1 <= sumaddr when bfstate = '0' else (others => '0');
	wraddr2 <= sumaddr when bfstate = '1' else (others => '0');
	wren1	  <= sumen when bfstate = '0' else '0';
	wren2	  <= sumen when bfstate = '1' else '0';

	inst_SummationRAM1 : SummationRAM
		port map (
			clock		 => clk,
			data		 => data1,
			rdaddress => rdaddr1,
			wraddress => wraddr1,
			wren		 => wren1,
			q			 => q1 );

	inst_SummationRAM2 : SummationRAM
		port map (
			clock		 => clk,
			data		 => data2,
			rdaddress => rdaddr2,
			wraddress => wraddr2,
			wren		 => wren2,
			q			 => q2 );
				
	process (clk) begin
		if rising_edge(clk) then
			sumin <= din;
			sig <= din(7);
			
			if(init = '1') then
				data1 <= (sig & sig & sig & sig & sumin);
				data2 <= (sig & sig & sig & sig & sumin);
			else
				data1 <= (sig & sig & sig & sig & sumin) + q1;
				data2 <= (sig & sig & sig & sig & sumin) + q2;
			end if;
			
			sumen_d <= wren;
			sumen <= sumen_d;
			sumaddr_d <= wraddr;
			sumaddr <= sumaddr_d;
			
			rden_d <= rden;
			if(rden_d = '1') then
				if(bfstate = '0') then
					dout_s <= q2;
				else
					dout_s <= q1;
				end if;
			else
				dout_s <= (others => '0');
			end if;				
		end if;
	end process;
end Behavioral;