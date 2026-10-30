
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_mac is
end entity tb_mac;

architecture sim of tb_mac is

    constant INPUT_WIDTH : positive := 8;
    constant ACC_WIDTH   : positive := 24;
    constant CLK_PERIOD  : time := 10 ns;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal en    : std_logic := '0';
    signal clear : std_logic := '0';

    signal A : signed(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal B : signed(INPUT_WIDTH-1 downto 0) := (others => '0');
    signal Y : signed(ACC_WIDTH-1 downto 0);

begin

    -- Device under test
    DUT : entity work.mac
        generic map (
            INPUT_WIDTH => INPUT_WIDTH,
            ACC_WIDTH   => ACC_WIDTH
        )
        port map (
            clk   => clk,
            rst   => rst,
            en    => en,
            clear => clear,
            A     => A,
            B     => B,
            Y     => Y
        );

    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2;

    -- Test stimulus
    stimulus : process
    begin

        -- Test 1: Reset
        rst <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y = to_signed(0, ACC_WIDTH)
            report "TEST 1 FAILED: Reset"
            severity error;

        rst <= '0';

        -- Test 2: Accumulate 2 * 3 = 6
        A  <= to_signed(2, INPUT_WIDTH);
        B  <= to_signed(3, INPUT_WIDTH);
        en <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y = to_signed(6, ACC_WIDTH)
            report "TEST 2 FAILED: First accumulation"
            severity error;

        -- Test 3: Accumulate 4 * 5 = 20
        -- Expected total: 6 + 20 = 26
        A <= to_signed(4, INPUT_WIDTH);
        B <= to_signed(5, INPUT_WIDTH);

        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y = to_signed(26, ACC_WIDTH)
            report "TEST 3 FAILED: Second accumulation"
            severity error;

        -- Test 4: Negative multiplication (-3 * 4 = -12)
        -- Expected total: 26 - 12 = 14
        A <= to_signed(-3, INPUT_WIDTH);
        B <= to_signed(4, INPUT_WIDTH);

        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y = to_signed(14, ACC_WIDTH)
            report "TEST 4 FAILED: Signed multiplication"
            severity error;

        -- Test 5: Disable accumulation
        A  <= to_signed(10, INPUT_WIDTH);
        B  <= to_signed(10, INPUT_WIDTH);
        en <= '0';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y = to_signed(14, ACC_WIDTH)
            report "TEST 5 FAILED: Enable control"
            severity error;

        -- Test 6: Clear accumulator
        clear <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y = to_signed(0, ACC_WIDTH)
            report "TEST 6 FAILED: Clear"
            severity error;

        clear <= '0';
        en    <= '1';

        -- Test 7: Accumulate after clear
        A <= to_signed(-8, INPUT_WIDTH);
        B <= to_signed(2, INPUT_WIDTH);

        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y = to_signed(-16, ACC_WIDTH)
            report "TEST 7 FAILED: Accumulation after clear"
            severity error;

        report "All MAC tests passed." severity note;

        std.env.stop;
        wait;

    end process;

end architecture sim;
