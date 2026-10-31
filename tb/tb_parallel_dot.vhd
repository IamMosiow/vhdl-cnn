
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_parallel_dot is
end entity tb_parallel_dot;

architecture sim of tb_parallel_dot is

    constant INPUT_WIDTH : positive := 8;
    constant RESULT_WIDTH : positive := 2*INPUT_WIDTH+2;

    signal A0, A1, A2, A3 :
        signed(INPUT_WIDTH-1 downto 0);

    signal B0, B1, B2, B3 :
        signed(INPUT_WIDTH-1 downto 0);

    signal Y : signed(RESULT_WIDTH-1 downto 0);

begin

    DUT : entity work.parallel_dot
        generic map (
            INPUT_WIDTH => INPUT_WIDTH
        )
        port map (
            A0 => A0,
            A1 => A1,
            A2 => A2,
            A3 => A3,

            B0 => B0,
            B1 => B1,
            B2 => B2,
            B3 => B3,

            Y => Y
        );

    stimulus : process
    begin

        -- TEST 1: Positive values
        -- 2*3 + 4*5 + 1*6 + 3*2 = 38

        A0 <= to_signed(2, INPUT_WIDTH);
        A1 <= to_signed(4, INPUT_WIDTH);
        A2 <= to_signed(1, INPUT_WIDTH);
        A3 <= to_signed(3, INPUT_WIDTH);

        B0 <= to_signed(3, INPUT_WIDTH);
        B1 <= to_signed(5, INPUT_WIDTH);
        B2 <= to_signed(6, INPUT_WIDTH);
        B3 <= to_signed(2, INPUT_WIDTH);

        wait for 10 ns;

        assert Y = to_signed(38, RESULT_WIDTH)
            report "TEST 1 FAILED: Positive values"
            severity error;


        -- TEST 2: Mixed positive and negative products
        -- (-3*4) + (4*5) + (1*6) + (-2*7) = 0

        A0 <= to_signed(-3, INPUT_WIDTH);
        A1 <= to_signed(4, INPUT_WIDTH);
        A2 <= to_signed(1, INPUT_WIDTH);
        A3 <= to_signed(-2, INPUT_WIDTH);

        B0 <= to_signed(4, INPUT_WIDTH);
        B1 <= to_signed(5, INPUT_WIDTH);
        B2 <= to_signed(6, INPUT_WIDTH);
        B3 <= to_signed(7, INPUT_WIDTH);

        wait for 10 ns;

        assert Y = to_signed(0, RESULT_WIDTH)
            report "TEST 2 FAILED: Mixed signed values"
            severity error;


        -- TEST 3: Maximum positive products
        -- (-128)*(-128) * 4 = 65536

        A0 <= to_signed(-128, INPUT_WIDTH);
        A1 <= to_signed(-128, INPUT_WIDTH);
        A2 <= to_signed(-128, INPUT_WIDTH);
        A3 <= to_signed(-128, INPUT_WIDTH);

        B0 <= to_signed(-128, INPUT_WIDTH);
        B1 <= to_signed(-128, INPUT_WIDTH);
        B2 <= to_signed(-128, INPUT_WIDTH);
        B3 <= to_signed(-128, INPUT_WIDTH);

        wait for 10 ns;

        assert Y = to_signed(65536, RESULT_WIDTH)
            report "TEST 3 FAILED: Maximum positive result"
            severity error;


        -- TEST 4: Large negative result
        -- 4 * (-128 * 127) = -65024

        A0 <= to_signed(-128, INPUT_WIDTH);
        A1 <= to_signed(-128, INPUT_WIDTH);
        A2 <= to_signed(-128, INPUT_WIDTH);
        A3 <= to_signed(-128, INPUT_WIDTH);

        B0 <= to_signed(127, INPUT_WIDTH);
        B1 <= to_signed(127, INPUT_WIDTH);
        B2 <= to_signed(127, INPUT_WIDTH);
        B3 <= to_signed(127, INPUT_WIDTH);

        wait for 10 ns;

        assert Y = to_signed(-65024, RESULT_WIDTH)
            report "TEST 4 FAILED: Negative result"
            severity error;


        report "All parallel dot product tests passed."
            severity note;

        std.env.stop;
        wait;

    end process;

end architecture sim;
