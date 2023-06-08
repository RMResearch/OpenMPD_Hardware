library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity Calibration is
	port (
		clk		  : in  std_logic;
		cen		  : in  std_logic;
		calib 	  : in  std_logic_vector (6 downto 0);
		caddress   : in  std_logic_vector (7 downto 0);
		arctan	  : in  std_logic_vector (6 downto 0);
		at_addr	  : in  std_logic_vector (7 downto 0);
		calibphase : out std_logic_vector (6 downto 0)
	);
end Calibration;

architecture Behavioral of Calibration is


component CalibrationRAM IS
	port (
		address : in  std_logic_vector (7 downto 0);
		clock	  : in  std_logic  := '1';
		data	  : in  std_logic_vector (6 downto 0);
		wren	  : in  std_logic ;
		q		  : out std_logic_vector (6 downto 0) );
end component;

	signal address		  : std_logic_vector (7 downto 0) := (others => '0');
	signal original	  : std_logic_vector (7 downto 0) := (others => '0');
	signal calib_out	  : std_logic_vector (6 downto 0) := (others => '0');
	signal calibphase_s : std_logic_vector (7 downto 0) := (others => '0');

begin

	address <= caddress when cen = '1' else at_addr;
	calibphase <= calibphase_s(6 downto 0);
	
	inst_CalibrationRAM : CalibrationRAM
		port map (
			address => address,
			clock	  => clk,
			data	  => calib,
			wren	  => cen,
			q		  => calib_out);

	process (clk) begin
		if rising_edge(clk) then
			original <= ("0" & arctan);
			calibphase_s <= original - ("0" & calib_out);
		end if;
	end process;
	 
end Behavioral;