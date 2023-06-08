library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RealImagSummation is
	port (
		clk	  : in  std_logic;
		start	  : in  std_logic;
		npoints : in  std_logic_vector (3 downto 0);
		sin	  : in  std_logic_vector (7 downto 0);
		cos	  : in  std_logic_vector (7 downto 0);
		sc_en	  : in  std_logic;
		sc_addr : in  std_logic_vector (7 downto 0);
		re		  : out std_logic_vector (11 downto 0);
		im		  : out std_logic_vector (11 downto 0);	
		ri_en	  : out std_logic;
		ri_addr : out std_logic_vector (7 downto 0)
	);
end RealImagSummation;

architecture Behavioral of RealImagSummation iS
	
	component RealImagRAMs is
		port (
			clk	  : in  std_logic;
			bfstate : in  std_logic;
			init	  : in  std_logic;
			din	  : in  std_logic_vector (7 downto 0);
			wren	  : in  std_logic;
			wraddr  : in  std_logic_vector (7 downto 0);
			rden	  : in  std_logic;
			rdaddr  : in  std_logic_vector (7 downto 0);
			dout	  : out std_logic_vector (11 downto 0) );
	end component;
	
	signal re_s		 	 : std_logic_vector (11 downto 0) := (others => '0');
	signal im_s		 	 : std_logic_vector (11 downto 0) := (others => '0');
	signal ri_en_s	 	 : std_logic := '0';
	signal ri_addr_s	 : std_logic_vector (7 downto 0) := (others => '0');
	signal ri_en_d		 : std_logic := '0';
	signal ri_addr_d	 : std_logic_vector (7 downto 0) := (others => '0');

	signal start_d		 : std_logic := '0';
	signal npoints_d	 : std_logic_vector (3 downto 0) := (others => '0');
	
	
	signal old_sc_en	 : std_logic := '0';
	signal npoints_reg : std_logic_vector (3 downto 0) := (others => '0');
	signal pcount 		 : std_logic_vector (3 downto 0) := (others => '0');
	signal bfstate 	 : std_logic := '0';
	signal init		 	 : std_logic := '1';
	signal rden		 	 : std_logic := '0';
	signal rdaddr 		 : std_logic_vector (7 downto 0) := (others => '0');
	signal sc_addr_d0	 : std_logic_vector (7 downto 0) := (others => '0');
	signal sc_addr_d1	 : std_logic_vector (7 downto 0) := (others => '0');
	signal outpulse	 : std_logic := '0';
	
begin

	re <= re_s;
	im <= im_s;
	ri_en <= ri_en_s;
	ri_addr <= ri_addr_s;
	
	inst_RealRAM : RealImagRAMs
		port map (
			clk	  => clk,
			bfstate => bfstate,
			init	  => init,
			din	  => cos,
			wren	  => sc_en,
			wraddr  => sc_addr,
			rden	  => rden,
			rdaddr  => rdaddr,
			dout	  => re_s );
			
	inst_ImagRAM : RealImagRAMs
		port map (
			clk	  => clk,
			bfstate => bfstate,
			init	  => init,
			din	  => sin,
			wren	  => sc_en,
			wraddr  => sc_addr,
			rden	  => rden,
			rdaddr  => rdaddr,
			dout	  => im_s );
			
	process (clk) begin
		if rising_edge(clk) then
			start_d <= start;
			npoints_d <= npoints;
			
			old_sc_en <= sc_en;
			if(sc_en = '1' and old_sc_en = '0') then
				npoints_reg <= npoints - '1';
			end if;
			
			sc_addr_d0 <= sc_addr;
			sc_addr_d1 <= sc_addr_d0;
			if(sc_addr_d1 = "11111111") then
				if(pcount = npoints_reg) then
					bfstate <= not bfstate;
					pcount <= (others => '0');
					outpulse <= '1';
					init <= '1';
				else
					pcount <= pcount + '1';
					init <= '0';
				end if;
			else
				outpulse <= '0';
			end if;
			
			if (outpulse = '1') then
				rden <= '1';
				rdaddr <= (others => '0');
			else
				if (rden = '1') then
					if (rdaddr = "11111111") then
						rden <= '0';
						rdaddr <= (others => '0');
					else
						rdaddr <= rdaddr + '1';
					end if;
				end if;
			end if;
			ri_en_d <= rden;
			ri_en_s <= ri_en_d;
			ri_addr_d <= rdaddr;
			ri_addr_s <= ri_addr_d;
		end if;
	end process;
end Behavioral;