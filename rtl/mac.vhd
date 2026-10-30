library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity mac is
	generic (
		INPUT_WIDTH : positive := 8;
		ACC_WIDTH	: positive := 24
	);
	port (
		clk		: in std_logic;
		rst		: in std_logic;
		en		: in std_logic;
		clear	: in std_logic;

		A		: in signed(INPUT_WIDTH-1 downto 0);
        B		: in  signed(INPUT_WIDTH-1 downto 0);

        Y		: out signed(ACC_WIDTH-1 downto 0)
	);
end entity mac;

architecture Behavioral of mac is

	signal accumulator	: signed(ACC_WIDTH-1 downto 0) := (others => '0');
	signal product		: signed(2*INPUT_WIDTH-1 downto 0);

begin

	product <= A * B;
	
	process(clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				accumulator <= (others => '0');
				
			elsif clear = '1' then
				accumulator <= (others => '0');
			
			elsif en = '1' then
				accumulator <= accumulator + resize(product, ACC_WIDTH);
				
			end if;
		end if;
	end process;

	Y <= accumulator;
	
end architecture Behavioral;