library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ArctanLUTController is
	port (
		clk	  : in  std_logic;
		re		  : in  std_logic_vector (11 downto 0);
		im		  : in  std_logic_vector (11 downto 0);
		ri_en	  : in  std_logic;
		ri_addr : in  std_logic_vector (7 downto 0);
		arctan  : out std_logic_vector (5 downto 0);
		at_en	  : out std_logic;
		at_addr : out std_logic_vector (7 downto 0)
	);
end ArctanLUTController;

architecture Behavioral of ArctanLUTController is
	
	component ArctanLUT is
	port (
		address : in  std_logic_vector (9 downto 0);
		clock	  : in  std_logic  := '1';
		q		  : out std_logic_vector (5 downto 0) );
	end component;

	signal address	  : std_logic_vector (9 downto 0) := (others => '0');
	signal readdr	  : std_logic_vector (4 downto 0) := (others => '0');
	signal imaddr	  : std_logic_vector (4 downto 0) := (others => '0');
	
	signal arctan_s  : std_logic_vector (5 downto 0) := (others => '0');
	signal at_en_s	  : std_logic := '0';
	signal at_addr_s : std_logic_vector (7 downto 0) := (others => '0');
	
	signal at_en_d	  : std_logic := '0';
	signal at_addr_d : std_logic_vector(7 downto 0) := (others => '0');
	

	
begin

	arctan <= arctan_s;
	at_en <= at_en_s;
	at_addr <= at_addr_s;

	address <= readdr & imaddr;
	
	inst_ArctanLUT : ArctanLUT
		port map (
			address => address,
			clock	  => clk,
			q		  => arctan_s );

	process (clk) begin
		if rising_edge(clk) then
			if (re(11) /= re(10) or im(11) /= im(10)) then
				readdr <= re(11 downto 7);
				imaddr <= im(11 downto 7);
			elsif (re(11) /= re(9) or im(11) /= im(9)) then
				readdr <= re(10 downto 6);
				imaddr <= im(10 downto 6);
			elsif (re(11) /= re(8) or im(11) /= im(8)) then
				readdr <= re(9 downto 5);
				imaddr <= im(9 downto 5);
			elsif (re(11) /= re(7) or im(11) /= im(7)) then
				readdr <= re(8 downto 4);
				imaddr <= im(8 downto 4);
			elsif (re(11) /= re(6) or im(11) /= im(6)) then
				readdr <= re(7 downto 3);
				imaddr <= im(7 downto 3);
			elsif (re(11) /= re(5) or im(11) /= im(5)) then
				readdr <= re(6 downto 2);
				imaddr <= im(6 downto 2);
			elsif (re(11) /= re(4) or im(11) /= im(4)) then
				readdr <= re(5 downto 1);
				imaddr <= im(5 downto 1);
			else
				readdr <= re(4 downto 0);
				imaddr <= im(4 downto 0);
			end if;
			
			at_en_d <= ri_en;
			at_en_s <= at_en_d;
			at_addr_d <= ri_addr;
			at_addr_s <= at_addr_d;
		end if;
	end process;
	
end Behavioral;