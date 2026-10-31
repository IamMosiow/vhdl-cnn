library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity parallel_dot is
	generic (
		INPUT_WIDTH : positive := 8
	);
	
	port (
		A0, A1, A2, A3 : in signed(INPUT_WIDTH-1 downto 0);
		B0, B1, B2, B3 : in signed(INPUT_WIDTH-1 downto 0);
		Y : out signed(2*INPUT_WIDTH+1 downto 0)
	);
end entity parallel_dot;

architecture Behavioral of parallel_dot is
	constant PRODUCT_WIDTH : positive := 2 * INPUT_WIDTH;
	constant RESULT_WIDTH : positive := 2 * INPUT_WIDTH + 2;

	-- Four multiplication results
	signal P0, P1, P2, P3:	signed (PRODUCT_WIDTH-1 downto 0);
	
	--First level of the adder tree
	signal S01, S23 : signed (PRODUCT_WIDTH downto 0);
	
	-- Final result
	signal TOTAL : signed(RESULT_WIDTH-1 downto 0);
begin

	-- Parallel multipliers
	P0 <= A0 * B0;
	P1 <= A1 * B1;
	P2 <= A2 * B2;
	P3 <= A3 * B3;
	
	-- First adder level
	S01 <= resize(P0, S01'length) + resize(P1, S01'length);
	S23 <= resize(P2, S23'length) + resize(P3, S23'length);
	
	--Second adder level
	TOTAL <= resize(S01, TOTAL'length) + resize(S23, TOTAL'length);
	
	--Output
	Y <= TOTAL;

end architecture Behavioral;