library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity SerialReceiver is
	generic (
		CLKS_PER_BIT : integer := 200 );
	port (
		clk       : in  std_logic;
		rx_serial : in  std_logic;
		rx_en     : out std_logic;
		rx_byte   : out std_logic_vector(7 downto 0) );
end SerialReceiver;

architecture rtl of SerialReceiver is

	type t_SM_Main is (s_Idle, s_RX_Start_Bit, s_RX_Data_Bits, s_RX_Stop_Bit, s_Cleanup);
	signal r_SM_Main : t_SM_Main := s_Idle;

	signal r_RX_Data_R : std_logic := '0';
	signal r_RX_Data   : std_logic := '0';

	signal r_Clk_Count : integer range 0 to CLKS_PER_BIT-1 := 0;
	signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
	signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
	signal r_RX_DV     : std_logic := '0';
 
begin

	-- Purpose: Double-register the incoming data.
	-- This allows it to be used in the UART RX Clock Domain.
	-- (It removes problems caused by metastabiliy)
	p_SAMPLE : process (clk) begin
		if rising_edge(clk) then
			r_RX_Data_R <= rx_serial;
			r_RX_Data   <= r_RX_Data_R;
		end if;
	end process p_SAMPLE;


	-- Purpose: Control RX state machine
	p_UART_RX : process (clk) begin
		if rising_edge(clk) then
			case r_SM_Main is
				when s_Idle =>
					r_RX_DV     <= '0';
					r_Clk_Count <= 0;
					r_Bit_Index <= 0;
					if r_RX_Data = '0' then       -- Start bit detected
						r_SM_Main <= s_RX_Start_Bit;
					else
						r_SM_Main <= s_Idle;
					end if;
				-- Check middle of start bit to make sure it's still low
				when s_RX_Start_Bit =>
					if r_Clk_Count = (CLKS_PER_BIT-1)/2 then
						if r_RX_Data = '0' then
							r_Clk_Count <= 0;  -- reset counter since we found the middle
							r_SM_Main   <= s_RX_Data_Bits;
						else
							r_SM_Main   <= s_Idle;
						end if;
					else
						r_Clk_Count <= r_Clk_Count + 1;
						r_SM_Main   <= s_RX_Start_Bit;
					end if;
				-- Wait CLKS_PER_BIT-1 clock cycles to sample serial data
				when s_RX_Data_Bits =>
					if r_Clk_Count < CLKS_PER_BIT-1 then
						r_Clk_Count <= r_Clk_Count + 1;
						r_SM_Main   <= s_RX_Data_Bits;
					else
						r_Clk_Count            <= 0;
						r_RX_Byte(r_Bit_Index) <= r_RX_Data;
						-- Check if we have sent out all bits
						if r_Bit_Index < 7 then
							r_Bit_Index <= r_Bit_Index + 1;
							r_SM_Main   <= s_RX_Data_Bits;
						else
							r_Bit_Index <= 0;
							r_SM_Main   <= s_RX_Stop_Bit;
						end if;
					end if;
				-- Receive Stop bit.  Stop bit = 1
				when s_RX_Stop_Bit =>
					-- Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
					if r_Clk_Count < CLKS_PER_BIT-1 then
						r_Clk_Count <= r_Clk_Count + 1;
						r_SM_Main   <= s_RX_Stop_Bit;
					else
						r_RX_DV     <= '1';
						r_Clk_Count <= 0;
						r_SM_Main   <= s_Cleanup;
					end if;				 
				-- Stay here 1 clock
				when s_Cleanup =>
					r_SM_Main <= s_Idle;
					r_RX_DV   <= '0';
				when others =>
					r_SM_Main <= s_Idle;
			end case;
		end if;
	end process p_UART_RX;

	rx_en   <= r_RX_DV;
	rx_byte <= r_RX_Byte;

end rtl;

