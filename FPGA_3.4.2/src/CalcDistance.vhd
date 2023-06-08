library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity CalcDistance is
	port (
		clk	  : in  std_logic;
		start	  : in  std_logic;
		xin	  : in  std_logic_vector (12 downto 0);
		yin	  : in  std_logic_vector (12 downto 0);
		zin	  : in  std_logic_vector (12 downto 0);
		ack	  : out std_logic;
		r2		  : out std_logic_vector (23 downto 0);
		r2_en	  : out std_logic;
		r2_addr : out std_logic_vector (7 downto 0)		
	);
end CalcDistance;

architecture Behavioral of CalcDistance is
	
	component PowerXYZ is
		port (
			clk	  : in  std_logic;
			xjn	  : in  std_logic_vector (12 downto 0);
			yjn	  : in  std_logic_vector (12 downto 0);
			zjn	  : in  std_logic_vector (12 downto 0);
			r2		  : out std_logic_vector (26 downto 0) );
	end component;

	type CalcState is (Idle, Calculation);
	signal state : CalcState := Idle;

	signal xj		  : std_logic_vector (12 downto 0) := (others => '0');
	signal yj		  : std_logic_vector (12 downto 0) := (others => '0');
	signal zj		  : std_logic_vector (12 downto 0) := (others => '0');
	signal xn		  : std_logic_vector (12 downto 0) := (others => '0');
	signal yn		  : std_logic_vector (12 downto 0) := (others => '0');	
	
	signal xjn		  : std_logic_vector (13 downto 0) := (others => '0');
	signal yjn		  : std_logic_vector (13 downto 0) := (others => '0');
	signal zjn		  : std_logic_vector (12 downto 0) := (others => '0');
	
	signal ack_s	  : std_logic := '0';
	signal r2_en_s	  : std_logic := '0';
	signal r2_s	 	  : std_logic_vector (26 downto 0) := (others => '0');
	signal r2_addr_s : std_logic_vector (7 downto 0) := (others => '0');

	signal pen_d	  : std_logic_vector (2 downto 0) := (others => '0');
	signal addr_d0	  : std_logic_vector (7 downto 0) := (others => '0');
	signal addr_d1	  : std_logic_vector (7 downto 0) := (others => '0');
	signal addr_d2	  : std_logic_vector (7 downto 0) := (others => '0');
	
begin

	r2		  <= r2_s(26 downto 3);
	r2_en   <= r2_en_s;
	r2_addr <= r2_addr_s;
	ack	  <= ack_S;
	
	
	inst_PowerXYZ : PowerXYZ
		port map (
			clk => clk,
			xjn => xjn(12 downto 0),
			yjn => yjn(12 downto 0),
			zjn => zjn,
			r2	 => r2_s );
	
	process (clk) begin
		if rising_edge(clk) then
			case state is
				when Idle =>
					if (start = '1') then
						xj <= xin;
						yj <= yin;
						zj <= zin;
						state <= Calculation;
						xn <= "1011000101000"; 			-- -7.5 * 10.5 mm
						yn <= "1011000101000"; 			-- -7.5 * 10.5 mm
						pen_d(0) <= '1';
						addr_d0 <= "00000000";
					end if;
				
				when Calculation =>
					if(xn = "0100111011000") then		-- +7.5 * 10.5 mm
						if(yn = "0100111011000") then -- +7.5 * 10.5 mm
							state <= Idle;
							xj <= (others => '0');
							yj <= (others => '0');
							zj <= (others => '0');							
							xn <= (others => '0');
							yn <= (others => '0');
							pen_d(0) <= '0';
							addr_d0 <= (others => '0');
						else
							xn <= "1011000101000";
							yn <= yn + "0000101010000";
							addr_d0 <= addr_d0 + '1';
						end if;
					else
						xn <= xn + "0000101010000";
						addr_d0 <= addr_d0 + '1';
					end if;
					
				when others =>
					
			end case;
			xjn <= abs((xj(12) & xj) - (xn(12) & xn));
			yjn <= abs((yj(12) & yj) - (yn(12) & yn));
			zjn <= zj;
			
			pen_d(1) <= pen_d(0);
			pen_d(2) <= pen_d(1);
			r2_en_s <= pen_d(2);
			addr_d1 <= addr_d0;
			addr_d2 <= addr_d1;
			r2_addr_s <= addr_d2;
			if(r2_en_s = '1' and pen_d(2) = '0') then
				ack_s <= '1';
			else
				ack_s <= '0';
			end if;
		end if;
	end process;
end Behavioral;