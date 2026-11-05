
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_pipelined_dot is
end entity tb_pipelined_dot;

architecture sim of tb_pipelined_dot is

    constant INPUT_WIDTH  : positive := 8;
    constant RESULT_WIDTH : positive := 18;
    constant CLK_PERIOD   : time := 10 ns;

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal valid_in  : std_logic := '0';
    signal valid_out : std_logic;

    signal A0, A1, A2, A3 :
        signed(INPUT_WIDTH-1 downto 0) := (others => '0');

    signal B0, B1, B2, B3 :
        signed(INPUT_WIDTH-1 downto 0) := (others => '0');

    signal Y : signed(RESULT_WIDTH-1 downto 0);

begin

    DUT : entity work.pipelined_dot
        generic map (
            INPUT_WIDTH => INPUT_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_in,

            A0 => A0,
            A1 => A1,
            A2 => A2,
            A3 => A3,

            B0 => B0,
            B1 => B1,
            B2 => B2,
            B3 => B3,

            Y => Y,
            valid_out => valid_out
        );

    -- Clock generation
    clk <= not clk after CLK_PERIOD/2;

    stimulus : process
    begin

        -- Reset
        wait until falling_edge(clk);
        rst <= '1';

        wait until falling_edge(clk);
        rst <= '0';

        -- Vector 1: Expected 38
        A0 <= to_signed(2, INPUT_WIDTH);
        A1 <= to_signed(4, INPUT_WIDTH);
        A2 <= to_signed(1, INPUT_WIDTH);
        A3 <= to_signed(3, INPUT_WIDTH);

        B0 <= to_signed(3, INPUT_WIDTH);
        B1 <= to_signed(5, INPUT_WIDTH);
        B2 <= to_signed(6, INPUT_WIDTH);
        B3 <= to_signed(2, INPUT_WIDTH);

        valid_in <= '1';

        -- Vector 2: Expected 0
        wait until falling_edge(clk);

        A0 <= to_signed(-3, INPUT_WIDTH);
        A1 <= to_signed(4, INPUT_WIDTH);
        A2 <= to_signed(1, INPUT_WIDTH);
        A3 <= to_signed(-2, INPUT_WIDTH);

        B0 <= to_signed(4, INPUT_WIDTH);
        B1 <= to_signed(5, INPUT_WIDTH);
        B2 <= to_signed(6, INPUT_WIDTH);
        B3 <= to_signed(7, INPUT_WIDTH);

        -- Vector 3: Expected 65536
        wait until falling_edge(clk);

        A0 <= to_signed(-128, INPUT_WIDTH);
        A1 <= to_signed(-128, INPUT_WIDTH);
        A2 <= to_signed(-128, INPUT_WIDTH);
        A3 <= to_signed(-128, INPUT_WIDTH);

        B0 <= to_signed(-128, INPUT_WIDTH);
        B1 <= to_signed(-128, INPUT_WIDTH);
        B2 <= to_signed(-128, INPUT_WIDTH);
        B3 <= to_signed(-128, INPUT_WIDTH);

        -- Vector 4: Expected -65024
        wait until falling_edge(clk);

        A0 <= to_signed(-128, INPUT_WIDTH);
        A1 <= to_signed(-128, INPUT_WIDTH);
        A2 <= to_signed(-128, INPUT_WIDTH);
        A3 <= to_signed(-128, INPUT_WIDTH);

        B0 <= to_signed(127, INPUT_WIDTH);
        B1 <= to_signed(127, INPUT_WIDTH);
        B2 <= to_signed(127, INPUT_WIDTH);
        B3 <= to_signed(127, INPUT_WIDTH);

        -- No more valid inputs
        wait until falling_edge(clk);
        valid_in <= '0';

        -- Allow pipeline to finish
        wait until falling_edge(clk);
        wait until falling_edge(clk);
        wait until falling_edge(clk);

        report "Pipeline test completed." severity note;

        wait;

    end process;


    -- Independent output checker
    checker : process
        variable output_count : integer := 0;
    begin

        wait until rising_edge(clk);
        wait for 1 ns;

        if rst = '0' and valid_out = '1' then

            output_count := output_count + 1;

            case output_count is

                when 1 =>
                    assert Y = to_signed(38, RESULT_WIDTH)
                        report "Vector 1 FAILED"
                        severity error;

                when 2 =>
                    assert Y = to_signed(0, RESULT_WIDTH)
                        report "Vector 2 FAILED"
                        severity error;

                when 3 =>
                    assert Y = to_signed(65536, RESULT_WIDTH)
                        report "Vector 3 FAILED"
                        severity error;

                when 4 =>
                    assert Y = to_signed(-65024, RESULT_WIDTH)
                        report "Vector 4 FAILED"
                        severity error;

                    report "All pipeline tests passed."
                        severity note;

                when others =>
                    assert false
                        report "Unexpected extra output"
                        severity error;

            end case;

        end if;

    end process;

end architecture sim;
