library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity InterpolationControl is
	port (
		clk	 	 	 : in  std_logic;
		ten_in		 : in  std_logic;
		tflag_in		 : in  std_logic;
		tdata_in		 : in  std_logic_vector (6 downto 0);
		taddress_in  : in  std_logic_vector (7 downto 0);
		tswap_in		 : in  std_logic;
		synccnt		 : in  std_logic_vector (7 downto 0);
		ten_out		 : out std_logic;
		tflag_out	 : out std_logic;
		tdata_out	 : out std_logic_vector (6 downto 0);
		taddress_out : out std_logic_vector (7 downto 0);
		tswap_out	 : out std_logic
	);
end InterpolationControl;

architecture Behavioral of InterpolationControl is
	
	component InterpolationRAM IS
		port (
			clock	 	 : in  std_logic;
			data	 	 : in  std_logic_vector (6 downto 0);
			rdaddress : in  std_logic_vector (7 downto 0);
			wraddress : in  std_logic_vector (7 downto 0);
			wren		 : in  std_logic;
			q		 	 : out std_logic_vector (6 downto 0) );
	end component;

	component Interpolation is
	port (
		clk			: in  std_logic;
		enable_in	: in  std_logic;
		data_a		: in  std_logic_vector (6 downto 0);
		data_b		: in  std_logic_vector (6 downto 0);
		ratio_count	: in  std_logic_vector (1 downto 0);
		address_in	: in  std_logic_vector (7 downto 0);
		swap_in		: in  std_logic;
		enable_out	: out std_logic;
		data_out		: out std_logic_vector (6 downto 0);
		address_out : out std_logic_vector (7 downto 0);
		swap_out		: out std_logic );
	end component;
	
	type WriteControlState is (WriteToRAM1, WriteToRAM2, WriteToRAM3);
	signal wrstate : WriteControlState := WriteToRAM1;

	type ReadControlState is (Ready, ReadFromRAM12, ReadFromRAM23, ReadFromRAM31);
	signal rdstate : ReadControlState := Ready;

	signal ten_out_s		 : std_logic := '0';
	signal tflag_out_s	 : std_logic := '0';
	signal tdata_out_s	 : std_logic_vector (6 downto 0) := (others => '0'); 
	signal taddress_out_s : std_logic_vector (7 downto 0) := (others => '0');
	signal tswap_out_s	 : std_logic := '0';

	signal data				 : std_logic_vector (6 downto 0) := (others => '0');
	signal rdaddress		 : std_logic_vector (7 downto 0) := (others => '0');
	signal wraddress	 : std_logic_vector (7 downto 0) := (others => '0');
	signal old_rdaddress	 : std_logic_vector (7 downto 0) := (others => '0');
	signal wren_1			 : std_logic := '0';
	signal wren_2			 : std_logic := '0';
	signal wren_3			 : std_logic := '0';
	signal q_1				 : std_logic_vector (6 downto 0) := (others => '0');
	signal q_2				 : std_logic_vector (6 downto 0) := (others => '0');
	signal q_3				 : std_logic_vector (6 downto 0) := (others => '0');

	signal intr_enable	 : std_logic := '0';
	signal intr_data_a	 : std_logic_vector (6 downto 0) := (others => '0');
	signal intr_data_b	 : std_logic_vector (6 downto 0) := (others => '0'); 
	signal intr_address	 : std_logic_vector (7 downto 0) := (others => '0');
	signal intr_swap		 : std_logic := '0';
	signal intr_count		 : std_logic_vector (1 downto 0) := (others => '0');

	signal cnt_reg			 : std_logic_vector (7 downto 0) := (others => '0');
	signal old_synccnt	 : std_logic_vector (7 downto 0) := (others => '0');
	signal outflag			 : std_logic := '0';
	signal old_outflag	 : std_logic := '0';

begin

	ten_out <= ten_out_s;	
	tflag_out <= '0';--tflag_out_s;
	tdata_out <= tdata_out_s;
	taddress_out <= taddress_out_s;
	tswap_out <= tswap_out_s;
	
	inst_InterpolationRAM_1 : InterpolationRAM
		port map (
			clock		 => clk,
			data		 => data,
			rdaddress => rdaddress,
			wraddress => wraddress,
			wren		 => wren_1,
			q			 => q_1 );
	
	inst_InterpolationRAM_2 : InterpolationRAM
		port map (
			clock		 => clk,
			data		 => data,
			rdaddress => rdaddress,
			wraddress => wraddress,
			wren		 => wren_2,
			q			 => q_2 );

	inst_InterpolationRAM_3 : InterpolationRAM
		port map (
			clock		 => clk,
			data		 => data,
			rdaddress => rdaddress,
			wraddress => wraddress,
			wren		 => wren_3,
			q			 => q_3 );
			
	inst_interpolation : Interpolation
		port map (
			clk			=> clk,
			enable_in	=> intr_enable,
			data_a		=> intr_data_a,
			data_b		=> intr_data_b,
			ratio_count	=> intr_count,
			address_in	=> intr_address,
			swap_in		=> intr_swap,
			enable_out	=> ten_out_s,
			data_out		=> tdata_out_s,
			address_out	=> taddress_out_s,
			swap_out		=> tswap_out_s	);
				
			
	WriteProcess: process (clk) begin 
		if (rising_edge(clk)) then
			case wrstate is
				when WriteToRAM1 =>
					if(tswap_in = '1') then
						wrstate <= WriteToRAM2;
						data <= (others => '0');
						wraddress <= (others => '0');
						wren_1 <= '0';
					else
						data <= tdata_in;
						wraddress <= taddress_in;
						wren_1 <= ten_in;
					end if;
					wren_2 <= '0';
					wren_3 <= '0';
				
				when WriteToRAM2 =>
					if(tswap_in = '1') then
						wrstate <= WriteToRAM3;
						data <= (others => '0');
						wraddress <= (others => '0');
						wren_2 <= '0';
					else
						data <= tdata_in;
						wraddress <= taddress_in;
						wren_2 <= ten_in;
					end if;
					wren_3 <= '0';
					wren_1 <= '0';
				
				when WriteToRAM3 =>
					if(tswap_in = '1') then
						wrstate <= WriteToRAM1;
						data <= (others => '0');
						wraddress <= (others => '0');
						wren_3 <= '0';
					else
						data <= tdata_in;
						wraddress <= taddress_in;
						wren_3 <= ten_in;
					end if;
					wren_1 <= '0';
					wren_2 <= '0';

				end case;
		end if;
	end process;
					
	ReadProcess: process (clk) begin 
		if (rising_edge(clk)) then
			case rdstate is
				when Ready =>
					if(wrstate = WriteToRAM2 and tswap_in = '1') then
						rdstate <= ReadFromRAM12;
						outflag <= '1';
						cnt_reg <= synccnt;
					end if;
					rdaddress <= (others => '0');
						
				when ReadFromRAM12 =>
					if(tswap_in = '1') then
						rdstate <= ReadFromRAM23;
						outflag <= '1';
						cnt_reg <= synccnt;
						intr_enable <= '0';
						intr_swap <= '0';
						intr_count <= (others => '0');
						rdaddress <= (others => '0');
					else
						if(outflag = '1') then
							if(old_rdaddress = "11111111") then
								outflag <= '0';
							end if;
							if(old_outflag = '1') then
								intr_enable <= '1';
								intr_data_a <= q_1;
								intr_data_b <= q_2;
								intr_address <= old_rdaddress;
							end if;
							rdaddress <= rdaddress + '1';
						else
							if(outflag = '0' and old_outflag = '1') then
								intr_count <= intr_count + '1';
								intr_swap <= '1';
							else
								intr_swap <= '0';
							end if;
							if(synccnt = cnt_reg and old_synccnt /= cnt_reg and intr_count /= "00") then
								outflag <= '1';
							end if;
							intr_enable <= '0';
							rdaddress <= (others => '0');
						end if;
					end if;
				
				when ReadFromRAM23 =>
					if(tswap_in = '1') then
						rdstate <= ReadFromRAM31;
						outflag <= '1';
						cnt_reg <= synccnt;
						intr_enable <= '0';
						intr_swap <= '0';
						intr_count <= (others => '0');
						rdaddress <= (others => '0');
					else
						if(outflag = '1') then
							if(old_rdaddress = "11111111") then
								outflag <= '0';
							end if;
							if(old_outflag = '1') then
								intr_enable <= '1';
								intr_data_a <= q_2;
								intr_data_b <= q_3;
								intr_address <= old_rdaddress;
							end if;
							rdaddress <= rdaddress + '1';
						else
							if(outflag = '0' and old_outflag = '1') then
								intr_count <= intr_count + '1';
								intr_swap <= '1';
							else
								intr_swap <= '0';
							end if;
							if(synccnt = cnt_reg and old_synccnt /= cnt_reg and intr_count /= "00") then
								outflag <= '1';
							end if;
							intr_enable <= '0';
							rdaddress <= (others => '0');
						end if;
					end if;
				
				when ReadFromRAM31 =>
					if(tswap_in = '1') then
						rdstate <= ReadFromRAM12;
						outflag <= '1';
						cnt_reg <= synccnt;
						intr_enable <= '0';
						intr_swap <= '0';
						intr_count <= (others => '0');
						rdaddress <= (others => '0');
					else
						if(outflag = '1') then
							if(old_rdaddress = "11111111") then
								outflag <= '0';
							end if;
							if(old_outflag = '1') then
								intr_enable <= '1';
								intr_data_a <= q_3;
								intr_data_b <= q_1;
								intr_address <= old_rdaddress;
							end if;
							rdaddress <= rdaddress + '1';
						else
							if(outflag = '0' and old_outflag = '1') then
								intr_count <= intr_count + '1';
								intr_swap <= '1';
							else
								intr_swap <= '0';
							end if;
							if(synccnt = cnt_reg and old_synccnt /= cnt_reg and intr_count /= "00") then
								outflag <= '1';
							end if;
							intr_enable <= '0';
							rdaddress <= (others => '0');
						end if;
					end if;

			end case;
			old_rdaddress <= rdaddress;
			old_outflag <= outflag;
			old_synccnt <= synccnt;
		end if;
	end process;		
		
end Behavioral;