
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_alu is
end entity tb_alu;

architecture sim of tb_alu is

    constant WIDTH : positive := 16;

    signal A  : signed(WIDTH-1 downto 0) := (others => '0');
    signal B  : signed(WIDTH-1 downto 0) := (others => '0');
    signal OP : std_logic_vector(2 downto 0) := (others => '0');
    signal Y  : signed(WIDTH-1 downto 0);

begin

    -- Instantiate the ALU
    DUT : entity work.alu
        generic map (
            WIDTH => WIDTH
        )
        port map (
            A  => A,
            B  => B,
            OP => OP,
            Y  => Y
        );

    -- Apply test cases
    stimulus : process
    begin

        -- Test 1: Addition (10 + 5 = 15)
        A  <= to_signed(10, WIDTH);
        B  <= to_signed(5, WIDTH);
        OP <= "000";
        wait for 10 ns;
        assert Y = to_signed(15, WIDTH)
            report "Addition failed"
            severity error;

        -- Test 2: Subtraction (10 - 5 = 5)
        OP <= "001";
        wait for 10 ns;
        assert Y = to_signed(5, WIDTH)
            report "Subtraction failed"
            severity error;

        -- Test 3: Bitwise AND
        A  <= to_signed(12, WIDTH); -- 1100
        B  <= to_signed(10, WIDTH); -- 1010
        OP <= "010";
        wait for 10 ns;
        assert Y = to_signed(8, WIDTH)
            report "AND failed"
            severity error;

        -- Test 4: Bitwise OR
        OP <= "011";
        wait for 10 ns;
        assert Y = to_signed(14, WIDTH)
            report "OR failed"
            severity error;

        -- Test 5: Bitwise XOR
        OP <= "100";
        wait for 10 ns;
        assert Y = to_signed(6, WIDTH)
            report "XOR failed"
            severity error;

        -- Test 6: NOT A
        A  <= to_signed(0, WIDTH);
        OP <= "101";
        wait for 10 ns;
        assert Y = to_signed(-1, WIDTH)
            report "NOT failed"
            severity error;

        -- Test 7: Shift left (8 << 1 = 16)
        A  <= to_signed(8, WIDTH);
        OP <= "110";
        wait for 10 ns;
        assert Y = to_signed(16, WIDTH)
            report "Shift left failed"
            severity error;

        -- Test 8: Arithmetic shift right (-8 >> 1 = -4)
        A  <= to_signed(-8, WIDTH);
        OP <= "111";
        wait for 10 ns;
        assert Y = to_signed(-4, WIDTH)
            report "Shift right failed"
            severity error;

        report "All ALU tests completed." severity note;
        wait;

    end process;

end architecture sim;
