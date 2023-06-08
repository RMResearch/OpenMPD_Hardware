-----------------------------------------------------------------------------------
--     This block converts the input signal into the actual data                 --
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PointDataController is
	port (
		clk	 	: in  std_logic;
		pen	 	: in  std_logic;
		xin	 	: in  std_logic_vector (12 downto 0); 
		yin	 	: in  std_logic_vector (12 downto 0); 
		zin	 	: in  std_logic_vector (12 downto 0);
		ampin	 	: in  std_logic_vector (7 downto 0);
		phain	 	: in  std_logic_vector (6 downto 0);
		rgbin	 	: in  std_logic_vector (23 downto 0);
		nframes 	: in  std_logic_vector (7 downto 0);
		swap	 	: in  std_logic;
		fiforst 	: in  std_logic;
		ack	 	: in  std_logic;
		synccnt  : in  std_logic_vector (7 downto 0);
		almost 	: out std_logic;
		start	 	: out std_logic;
		xout	 	: out std_logic_vector (12 downto 0);
		yout	 	: out std_logic_vector (12 downto 0); 
		zout	 	: out std_logic_vector (12 downto 0);
		ampout 	: out std_logic_vector (7 downto 0);
		phaout 	: out std_logic_vector (6 downto 0);
		rgbout	: out std_logic_vector (23 downto 0);
		debugled : out std_logic_vector (3 downto 0)
	);
end PointDataController;

architecture Behavioral of PointDataController is
	
	component PointDataFIFO IS
		port (
			clock			: in  std_logic;
			data			: in  std_logic_vector (85 downto 0);
			rdreq 		: in  std_logic;
			sclr			: in  std_logic;
			wrreq			: in  std_logic;
			almost_full : out std_logic ;
			empty			: out std_logic;
			full			: out std_logic;
			q				: out std_logic_vector (85 downto 0) );
	end component;
	
	component SwapFIFO IS
		port (
			clock	: in  std_logic;
			data	: in  std_logic_vector (0 downto 0);
			rdreq : in  std_logic;
			sclr	: in  std_logic;
			wrreq : in  std_logic;
			empty	: out std_logic;
			full	: out std_logic;
			q		: out std_logic_vector (0 downto 0) );
	end component;

	type ControlState is (Idle, WaitData, WaitAck);
	signal state : ControlState := Idle;
	
	signal start_s		 : std_logic := '0';

	signal data			 : std_logic_vector (85 downto 0) := (others => '0');
	signal rdreq		 : std_logic := '0';
	signal wrreq		 : std_logic := '0';
	signal almost_full : std_logic := '0';
	signal empty		 : std_logic := '0';
	signal full			 : std_logic := '0';
	signal q				 : std_logic_vector (85 downto 0) := (others => '0');

	signal sw_rdreq	 : std_logic := '0';
	signal sw_wrreq	 : std_logic := '0';
	signal sw_empty	 : std_logic := '0';
	signal sw_full		 : std_logic := '0';
	signal sw_q			 : std_logic_vector (0 downto 0) := (others => '0');

	signal nfout		 : std_logic_vector (7 downto 0) := (others => '0');
	signal fcount		 : std_logic_vector (7 downto 0) := (others => '0');

	signal old_start	 : std_logic := '0';
	signal old_synccnt : std_logic_vector (7 downto 0) := (others => '0');
	signal outflag		 : std_logic := '0';
	
	signal fifo_rst	 : std_logic := '0';
	signal rst_cnt		 : std_logic_vector (26 downto 0) := (others => '0');

begin

	almost <= almost_full;
	start  <= start_s;
	
	nfout <= q(7 downto 0);
	xout <= q(20 downto 8);
	yout <= q(33 downto 21);
	zout <= q(46 downto 34);
	ampout <= q(54 downto 47);
	phaout <= q(61 downto 55);
	rgbout <= q(85 downto 62);
	
	data <= rgbin & phain & ampin & zin & yin & xin & nframes;
	wrreq <= pen when full = '0' else '0';
	
	sw_wrreq <= swap when full = '0' else '0';
	
	debugled <= '0' & almost_full & empty & full;
	
	inst_PointDataFIFO : PointDataFIFO
		port map (
			clock			=> clk,
			data			=> data,
			rdreq 		=> rdreq,
			sclr	 		=> fifo_rst or fiforst,
			wrreq 		=> wrreq,
			almost_full => almost_full,
			empty			=> empty,
			full			=> full,
			q				=> q );
	
	inst_SwapFIFO : SwapFIFO
		port map (
			clock	=> clk,
			data	=> "1",
			rdreq => sw_rdreq,
			sclr	=> fifo_rst or fiforst,
			wrreq => sw_wrreq,
			empty	=> sw_empty,
			full	=> sw_full,
			q		=> sw_q );
			
	process (clk) begin
		if rising_edge(clk) then
			case state is
				when Idle =>
					if(empty = '0') then
						state <= WaitData;
						rdreq <= '1';
					end if;			
					
				when WaitData =>
					if(fcount = "00000000") then
						if(outflag = '1' and sw_empty = '0') then
							state <= WaitAck;
							start_s <= '1';
							sw_rdreq <= '1';
							if(fcount = nfout - '1') then
								fcount <= (others => '0');
							else
								fcount <= fcount + '1';
							end if;
						end if;
					else
						if(outflag = '1') then
							state <= WaitAck;
							start_s <= '1';
							if(fcount = nfout - '1') then
								fcount <= (others => '0');
							else
								fcount <= fcount + '1';
							end if;
						end if;
					end if;
					rdreq <= '0';
					
				when WaitAck =>
					if(ack = '1') then
						state <= Idle;
					end if;
					start_s  <= '0';
					sw_rdreq <= '0';

				when others =>
					
			end case;
			
			old_synccnt <= synccnt;
			old_start <= start_s;
			if(synccnt = "00000000" and old_synccnt /= "00000000") then
				outflag <= '1';
			elsif(start_s = '1' and old_start = '0') then
				outflag <= '0';
			end if;

			
			
			if(wrreq = '1') then
				rst_cnt <= (others => '0');
				fifo_rst <= '0';
			else
				if(rst_cnt = "101111101011110000100000000") then
					rst_cnt <= (others => '0');
					fifo_rst <= '1';
				else
					rst_cnt <= rst_cnt + '1';
					fifo_rst <= '0';
				end if;
			end if;
			
		end if;
	end process;	
		
		
end Behavioral;