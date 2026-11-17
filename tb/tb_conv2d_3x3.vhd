
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_conv2d_3x3 is
end entity tb_conv2d_3x3;

architecture Behavioral of tb_conv2d_3x3 is

    constant DATA_WIDTH : positive := 8;
    constant ACC_WIDTH  : positive := 24;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal start : std_logic := '0';

    signal X0, X1, X2 : signed(DATA_WIDTH-1 downto 0);
    signal X3, X4, X5 : signed(DATA_WIDTH-1 downto 0);
    signal X6, X7, X8 : signed(DATA_WIDTH-1 downto 0);

    signal W0, W1, W2 : signed(DATA_WIDTH-1 downto 0);
    signal W3, W4, W5 : signed(DATA_WIDTH-1 downto 0);
    signal W6, W7, W8 : signed(DATA_WIDTH-1 downto 0);

    signal result : signed(ACC_WIDTH-1 downto 0);
    signal valid  : std_logic;

begin

    -- Clock generation: 10 ns period
    clk <= not clk after 5 ns;

    -- DUT instantiation
    DUT: entity work.conv2d_3x3
        generic map (
            DATA_WIDTH => DATA_WIDTH,
            ACC_WIDTH  => ACC_WIDTH
        )
        port map (
            clk   => clk,
            rst   => rst,
            start => start,

            X0 => X0, X1 => X1, X2 => X2,
            X3 => X3, X4 => X4, X5 => X5,
            X6 => X6, X7 => X7, X8 => X8,

            W0 => W0, W1 => W1, W2 => W2,
            W3 => W3, W4 => W4, W5 => W5,
            W6 => W6, W7 => W7, W8 => W8,

            result => result,
            valid  => valid
        );

    stimulus: process
    begin

        -- Initial values
        rst   <= '1';
        start <= '0';

        X0 <= (others => '0'); X1 <= (others => '0');
        X2 <= (others => '0'); X3 <= (others => '0');
        X4 <= (others => '0'); X5 <= (others => '0');
        X6 <= (others => '0'); X7 <= (others => '0');
        X8 <= (others => '0');

        W0 <= (others => '0'); W1 <= (others => '0');
        W2 <= (others => '0'); W3 <= (others => '0');
        W4 <= (others => '0'); W5 <= (others => '0');
        W6 <= (others => '0'); W7 <= (others => '0');
        W8 <= (others => '0');

        wait for 20 ns;
        rst <= '0';

        -- Test 1: Basic convolution, expected result = 25
        X0 <= to_signed(1, DATA_WIDTH);
        X1 <= to_signed(2, DATA_WIDTH);
        X2 <= to_signed(3, DATA_WIDTH);
        X3 <= to_signed(4, DATA_WIDTH);
        X4 <= to_signed(5, DATA_WIDTH);
        X5 <= to_signed(6, DATA_WIDTH);
        X6 <= to_signed(7, DATA_WIDTH);
        X7 <= to_signed(8, DATA_WIDTH);
        X8 <= to_signed(9, DATA_WIDTH);

        W0 <= to_signed(1, DATA_WIDTH);
        W1 <= to_signed(0, DATA_WIDTH);
        W2 <= to_signed(1, DATA_WIDTH);
        W3 <= to_signed(0, DATA_WIDTH);
        W4 <= to_signed(1, DATA_WIDTH);
        W5 <= to_signed(0, DATA_WIDTH);
        W6 <= to_signed(1, DATA_WIDTH);
        W7 <= to_signed(0, DATA_WIDTH);
        W8 <= to_signed(1, DATA_WIDTH);

        wait until rising_edge(clk);
        start <= '1';

        wait until rising_edge(clk);
        start <= '0';

        wait until valid = '1';
        wait for 1 ns;

        assert result = to_signed(25, ACC_WIDTH)
            report "Test 1 FAILED: Expected 25"
            severity error;

        report "Test 1 PASSED: Result = 25"
            severity note;

        -- Wait until the FSM returns to IDLE
        wait until rising_edge(clk);
        wait for 1 ns;

        -- Test 2: All weights = -1, expected result = -45
        W0 <= to_signed(-1, DATA_WIDTH);
        W1 <= to_signed(-1, DATA_WIDTH);
        W2 <= to_signed(-1, DATA_WIDTH);
        W3 <= to_signed(-1, DATA_WIDTH);
        W4 <= to_signed(-1, DATA_WIDTH);
        W5 <= to_signed(-1, DATA_WIDTH);
        W6 <= to_signed(-1, DATA_WIDTH);
        W7 <= to_signed(-1, DATA_WIDTH);
        W8 <= to_signed(-1, DATA_WIDTH);

        wait until rising_edge(clk);
        start <= '1';

        wait until rising_edge(clk);
        start <= '0';

        wait until valid = '1';
        wait for 1 ns;

        assert result = to_signed(-45, ACC_WIDTH)
            report "Test 2 FAILED: Expected -45"
            severity error;

        report "Test 2 PASSED: Result = -45"
            severity note;

        -- Wait until the FSM returns to IDLE
        wait until rising_edge(clk);
        wait for 1 ns;

        -- Test 3: All weights = 0, expected result = 0
        W0 <= (others => '0'); W1 <= (others => '0');
        W2 <= (others => '0'); W3 <= (others => '0');
        W4 <= (others => '0'); W5 <= (others => '0');
        W6 <= (others => '0'); W7 <= (others => '0');
        W8 <= (others => '0');

        wait until rising_edge(clk);
        start <= '1';

        wait until rising_edge(clk);
        start <= '0';

        wait until valid = '1';
        wait for 1 ns;

        assert result = to_signed(0, ACC_WIDTH)
            report "Test 3 FAILED: Expected 0"
            severity error;

        report "Test 3 PASSED: Result = 0"
            severity note;

        report "All convolution tests completed."
            severity note;

        wait;
    end process stimulus;

end architecture Behavioral;
