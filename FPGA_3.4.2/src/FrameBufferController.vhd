-----------------------------------------------------------------------------------
--     This block converts the input signal into the actual data                 --
-----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity FrameBufferController is
	generic (
		NUM_TRANSDUCERS : integer := 256
	);
	port (
		clk		: in  std_logic;
		new_rx	: in  std_logic;
		rx_data	: in  std_logic_vector (7 downto 0);
		timing	: in  std_logic;
		divider	: in  std_logic_vector (7 downto 0);
		ready		: out std_logic;
		byte_in	: out std_logic;
		q_in		: out std_logic_vector (7 downto 0);
		debugled	: out std_logic_vector (3 downto 0)
	);
end FrameBufferController;

architecture Behavioral of FrameBufferController is
	
	component FrameBufferFIFO IS
		port (
			clock	: in  std_logic;
			data	: in  std_logic_vector (7 downto 0);
			rdreq	: in  std_logic;
			sclr	: in  std_logic;
			wrreq	: in  std_logic;
			empty	: out std_logic;
			full	: out std_logic;
			q		: out std_logic_vector (7 downto 0);
			usedw : out std_logic_vector (13 downto 0) );
	end component;
	
	type ControlState is (Start, Init, Idle, ReadFIFO, WaitFrame );
	signal ReadState : ControlState := Start;

	signal byte_in_s  : std_logic := '0';
	signal ready_s	   : std_logic := '1';
	signal debugled_s : std_logic_vector (3 downto 0) := (others => '0');
	
	signal data			: std_logic_vector (7 downto 0) := (others => '0');
	signal rdreq		: std_logic := '0';
	signal sclr			: std_logic := '0';
	signal wrreq		: std_logic := '0';
	signal empty		: std_logic := '0';
	signal full			: std_logic := '0';
	signal q				: std_logic_vector (7 downto 0) := (others => '0');
	signal usedw		: std_logic_vector (13 downto 0) := (others => '0');

	signal q_init		: std_logic_vector (7 downto 0) := (others => '0');
	signal bytecnt		: std_logic_vector (8 downto 0) := (others => '0');
	signal seccnt  	: std_logic_vector (25 downto 0) := (others => '0');
	signal divcnt  	: std_logic_vector (7 downto 0) := (others => '0');
	signal oldtiming	: std_logic := '0';

	signal sclrcnt  	: std_logic_vector (25 downto 0) := (others => '0');

begin

	byte_in <= byte_in_s;
	q_in <= q_init when ReadState = Init else q;
	ready <= ready_s;
	
	data <= rx_data;
	wrreq <= new_rx when full = '0' else '0';

	debugled <= "0000" when usedw = 0 else 
					"0001" when usedw < NUM_TRANSDUCERS * 2 else 
					"0010" when usedw < NUM_TRANSDUCERS * 2 * 16 else
					"0100" when usedw < NUM_TRANSDUCERS * 2 * 28 else
					"1000";
					
	inst_FrameBufferFIFO : FrameBufferFIFO
		port map (
			clock	=> clk,
			data	=> data,
			rdreq => rdreq,
			sclr	=> sclr,
			wrreq => wrreq,
			empty	=> empty,
			full	=> full,
			q		=> q,
			usedw	=> usedw );
	
	-- this reads data from the FIFO
	process (clk) begin
		if rising_edge(clk) then
			case ReadState is
				when Start =>
					seccnt <= seccnt + '1';
					if(seccnt = "10111110101111000001111111") then
						ReadState <= Init;
						q_init <= "10000000";
						byte_in_s <= '1';
					end if;
					
				when Init =>
					q_init <= (others=>'0');
					if(bytecnt = NUM_TRANSDUCERS * 2 - 1) then
						ReadState <= Idle;
						byte_in_s <= '0';
						bytecnt <= (others=>'0');
					else
						bytecnt <= bytecnt + '1';
					end if;
	
				when Idle =>
					if(usedw >= NUM_TRANSDUCERS * 2) then
						ReadState <= ReadFIFO;
						rdreq <= '1';
					end if;
					byte_in_s <= rdreq;
				
				when ReadFIFO =>
					if(bytecnt = NUM_TRANSDUCERS * 2 - 1) then
						ReadState <= WaitFrame;
						rdreq <= '0';
						bytecnt <= (others=>'0');
					else
						bytecnt <= bytecnt + '1';
					end if;
					byte_in_s <= rdreq;
					
				when WaitFrame =>
					oldtiming <= timing;
					if(timing = '0' and oldtiming = '1') then
						if(divcnt = divider - '1') then
							if(usedw >= NUM_TRANSDUCERS * 2) then
								ReadState <= ReadFIFO;
								rdreq <= '1';
							else
								ReadState <= Idle;
							end if;
							divcnt <= (others => '0');
						else
							divcnt <= divcnt + '1';
						end if;
					end if;					
					byte_in_s <= rdreq;			
								
				when others =>
					ReadState <= Idle;					
			end case;	
		end if;
	end process;
	
	process (clk) begin
		if rising_edge(clk) then
			-- tell the USB port that the buffer is almost full
			if (usedw >= NUM_TRANSDUCERS * 2 * 28) then
				ready_s <= '0';
			else
				ready_s <= '1';
			end if;
			
			-- reset the FIFO if no data is coming for 1 sec
			if(sclrcnt = "10111110101111000001111111") then
				sclr <= '1';
				sclrcnt <= (others => '0');
			else
				sclr <= '0';
				if(usedw >= NUM_TRANSDUCERS * 2) then
					sclrcnt <= (others => '0');
				else
					sclrcnt <= sclrcnt + '1';
				end if;	
			end if;
		end if;
	end process;
	
end Behavioral;