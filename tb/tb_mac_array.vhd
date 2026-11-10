
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_mac_array is
end entity tb_mac_array;

architecture Behavioral of tb_mac_array is

    constant INPUT_WIDTH : positive := 8;
    constant ACC_WIDTH   : positive := 24;
    constant CLK_PERIOD  : time := 10 ns;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal en    : std_logic := '0';
    signal clear : std_logic := '0';

    signal A0, A1, A2, A3 : signed(INPUT_WIDTH-1 downto 0)
                           := (others => '0');

    signal B0, B1, B2, B3 : signed(INPUT_WIDTH-1 downto 0)
                           := (others => '0');

    signal Y0, Y1, Y2, Y3 : signed(ACC_WIDTH-1 downto 0);

begin

    -- Clock generation
    clk <= not clk after CLK_PERIOD / 2;

    -- Device Under Test
    DUT: entity work.mac_array
        generic map (
            INPUT_WIDTH => INPUT_WIDTH,
            ACC_WIDTH   => ACC_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            en => en,
            clear => clear,

            A0 => A0, B0 => B0,
            A1 => A1, B1 => B1,
            A2 => A2, B2 => B2,
            A3 => A3, B3 => B3,

            Y0 => Y0,
            Y1 => Y1,
            Y2 => Y2,
            Y3 => Y3
        );

    -- Test sequence
    stimulus: process
    begin

        -- Test 1: Reset
        rst <= '1';
        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y0 = to_signed(0, ACC_WIDTH) and
               Y1 = to_signed(0, ACC_WIDTH) and
               Y2 = to_signed(0, ACC_WIDTH) and
               Y3 = to_signed(0, ACC_WIDTH)
            report "TEST 1 FAILED: Reset"
            severity error;

        rst <= '0';
        en  <= '1';

        -- Test 2: First accumulation
        A0 <= to_signed(2, INPUT_WIDTH);
        B0 <= to_signed(5, INPUT_WIDTH);

        A1 <= to_signed(4, INPUT_WIDTH);
        B1 <= to_signed(5, INPUT_WIDTH);

        A2 <= to_signed(5, INPUT_WIDTH);
        B2 <= to_signed(6, INPUT_WIDTH);

        A3 <= to_signed(8, INPUT_WIDTH);
        B3 <= to_signed(5, INPUT_WIDTH);

        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y0 = to_signed(10, ACC_WIDTH) and
               Y1 = to_signed(20, ACC_WIDTH) and
               Y2 = to_signed(30, ACC_WIDTH) and
               Y3 = to_signed(40, ACC_WIDTH)
            report "TEST 2 FAILED: First accumulation"
            severity error;

        -- Test 3: Second accumulation
        A0 <= to_signed(4, INPUT_WIDTH);
        B0 <= to_signed(5, INPUT_WIDTH);

        A1 <= to_signed(8, INPUT_WIDTH);
        B1 <= to_signed(5, INPUT_WIDTH);

        A2 <= to_signed(10, INPUT_WIDTH);
        B2 <= to_signed(6, INPUT_WIDTH);

        A3 <= to_signed(16, INPUT_WIDTH);
        B3 <= to_signed(5, INPUT_WIDTH);

        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y0 = to_signed(30, ACC_WIDTH) and
               Y1 = to_signed(60, ACC_WIDTH) and
               Y2 = to_signed(90, ACC_WIDTH) and
               Y3 = to_signed(120, ACC_WIDTH)
            report "TEST 3 FAILED: Second accumulation"
            severity error;

        -- Test 4: Disable accumulation
        en <= '0';

        A0 <= to_signed(10, INPUT_WIDTH);
        B0 <= to_signed(10, INPUT_WIDTH);

        A1 <= to_signed(10, INPUT_WIDTH);
        B1 <= to_signed(10, INPUT_WIDTH);

        A2 <= to_signed(10, INPUT_WIDTH);
        B2 <= to_signed(10, INPUT_WIDTH);

        A3 <= to_signed(10, INPUT_WIDTH);
        B3 <= to_signed(10, INPUT_WIDTH);

        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y0 = to_signed(30, ACC_WIDTH) and
               Y1 = to_signed(60, ACC_WIDTH) and
               Y2 = to_signed(90, ACC_WIDTH) and
               Y3 = to_signed(120, ACC_WIDTH)
            report "TEST 4 FAILED: Enable hold"
            severity error;

        -- Test 5: Clear accumulators
        clear <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y0 = to_signed(0, ACC_WIDTH) and
               Y1 = to_signed(0, ACC_WIDTH) and
               Y2 = to_signed(0, ACC_WIDTH) and
               Y3 = to_signed(0, ACC_WIDTH)
            report "TEST 5 FAILED: Clear"
            severity error;

        clear <= '0';

        -- Test 6: Accumulation after clear
        en <= '1';

        A0 <= to_signed(-3, INPUT_WIDTH);
        B0 <= to_signed(4, INPUT_WIDTH);

        A1 <= to_signed(5, INPUT_WIDTH);
        B1 <= to_signed(-6, INPUT_WIDTH);

        A2 <= to_signed(-7, INPUT_WIDTH);
        B2 <= to_signed(-8, INPUT_WIDTH);

        A3 <= to_signed(9, INPUT_WIDTH);
        B3 <= to_signed(3, INPUT_WIDTH);

        wait until rising_edge(clk);
        wait for 1 ns;

        assert Y0 = to_signed(-12, ACC_WIDTH) and
               Y1 = to_signed(-30, ACC_WIDTH) and
               Y2 = to_signed(56, ACC_WIDTH) and
               Y3 = to_signed(27, ACC_WIDTH)
            report "TEST 6 FAILED: Negative multiplication"
            severity error;

        -- All tests passed
        report "ALL MAC ARRAY TESTS PASSED!"
            severity note;

        wait;

    end process;

end architecture Behavioral;
