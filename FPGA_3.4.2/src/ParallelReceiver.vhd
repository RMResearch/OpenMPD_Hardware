library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity ParallelReceiver is
	Port (
		CLK		: in  std_logic;
		rxf_n		: in  std_logic;
		txe_n		: in  std_logic;
		rd_n		: out std_logic;
		wr_n		: out std_logic;
		usb_data : inout std_logic_vector(7 downto 0);
		bus_busy : out std_logic;
		tg_ready : in  std_logic;
		tg_wr    : in  std_logic;
		tg_di    : in  std_logic_vector(7 downto 0);
		tg_rd    : out std_logic;
		tg_do    : out std_logic_vector(7 downto 0) );
end ParallelReceiver;

architecture rtl of ParallelReceiver is

	signal rd_n_s     : std_logic := '1';
	signal wr_n_s	   : std_logic := '1';
	signal usb_data_s : std_logic_vector(7 downto 0) := (others => '0');
	signal bus_busy_s : std_logic := '0';
	signal tg_rd_s    : std_logic := '0';
	signal tg_do_s		: std_logic_vector(7 downto 0) := (others => '0');

	signal rxf_reg		: std_logic := '0';
	signal txe_reg		: std_logic := '0';

	signal dir			: std_logic := '0';

	signal rd_state	: std_logic_vector(1 downto 0) := "00";
	signal wr_state	: std_logic_vector(1 downto 0) := "00";
	  
	constant S0			: std_logic_vector := "00";
	constant S1			: std_logic_vector := "01";
	constant S2			: std_logic_vector := "10";
	constant S3			: std_logic_vector := "11";
	
begin

	rd_n		<= rd_n_s;
	wr_n 		<= wr_n_s;
	usb_data <= usb_data_s when( dir = '1') else "ZZZZZZZZ";
	bus_busy <= '0' when( WR_STATE = "00" and RD_STATE = "00" ) else '1';
	tg_rd 	<= tg_rd_s;
	tg_do 	<= tg_do_s;

	process(clk) begin
		if (rising_edge(clk)) then	
			rxf_reg <= not rxf_n;
			txe_reg <= not txe_n;
		end if;
	end process;

	--***                      *--
	--**  READ STATE MACHINE  **--
	--*                      ***--
	process(clk) begin
		if (rising_edge(clk)) then	
			case rd_state is
				when S0 =>
					if(rxf_reg = '1' and tg_ready = '1') then
						rd_n_s <= '0';
						rd_state <= S1;
					else
						rd_n_s <= '1';
						rd_state <= S0;
					end if;
				when S1 =>
					rd_state <= S2;
				when S2 =>
					rd_n_s <= '1'; 
					tg_do_s <= usb_data;
					tg_rd_s <= '1';
					rd_state <= S3;
				when S3 =>
					tg_rd_s <= '0';
					rd_state <= S0;
				when others =>
					rd_state <= S0;
			end case;
		end if;
	end process;

	
end rtl;

