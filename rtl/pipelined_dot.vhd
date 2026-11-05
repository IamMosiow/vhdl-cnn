library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pipelined_dot is
	generic (
		INPUT_WIDTH : positive := 8
		);
	port(
		clk				: in std_logic;
		rst				: in std_logic;
		valid_in		: in std_logic;
		
        A0, A1, A2, A3	: in signed(INPUT_WIDTH-1 downto 0);
        B0, B1, B2, B3	: in signed(INPUT_WIDTH-1 downto 0);
        Y         		: out signed(2*INPUT_WIDTH+1 downto 0);
        valid_out 		: out std_logic
	);
end entity pipelined_dot;

architecture Behavioral of pipelined_dot is
	constant PRODUCT_WIDTH	: positive := 2 * INPUT_WIDTH;
	constant SUM_WIDTH		: positive := PRODUCT_WIDTH + 1;
	constant RESULT_WIDTH	: positive := PRODUCT_WIDTH + 2;
	
	-- Stage 1: Product registers
	signal P0, P1, P2, P3	: signed(PRODUCT_WIDTH - 1 downto 0);
	
    -- Stage 2: Partial sum registers
    signal S01, S23			: signed(SUM_WIDTH-1 downto 0);

    -- Stage 3: Final result register
    signal result_reg		: signed(RESULT_WIDTH-1 downto 0);	

	-- Pipeline valid signal
	signal valid_stage1		: std_logic := '0';
    signal valid_stage2 : std_logic := '0';
    signal valid_stage3 : std_logic := '0';
    
begin

    process(clk)
    begin
        if rising_edge(clk) then

            if rst = '1' then

                P0 <= (others => '0');
                P1 <= (others => '0');
                P2 <= (others => '0');
                P3 <= (others => '0');

                S01 <= (others => '0');
                S23 <= (others => '0');

                result_reg <= (others => '0');

                valid_stage1 <= '0';
                valid_stage2 <= '0';
                valid_stage3 <= '0';

            else

                -- Stage 1: Multiplication
                P0 <= A0 * B0;
                P1 <= A1 * B1;
                P2 <= A2 * B2;
                P3 <= A3 * B3;

                valid_stage1 <= valid_in;

                -- Stage 2: First-level addition
                S01 <= resize(P0, SUM_WIDTH) +
                       resize(P1, SUM_WIDTH);

                S23 <= resize(P2, SUM_WIDTH) +
                       resize(P3, SUM_WIDTH);

                valid_stage2 <= valid_stage1;

                -- Stage 3: Final addition
                result_reg <= resize(S01, RESULT_WIDTH) +
                              resize(S23, RESULT_WIDTH);

                valid_stage3 <= valid_stage2;

            end if;
        end if;
    end process;

    Y <= result_reg;
    valid_out <= valid_stage3;
	
	
end architecture Behavioral;
