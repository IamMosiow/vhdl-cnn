library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mac_array is
    generic (
        INPUT_WIDTH : positive := 8;
        ACC_WIDTH   : positive := 24
    );
    port (
        clk   : in std_logic;
        rst   : in std_logic;
        en    : in std_logic;
        clear : in std_logic;

        A0, A1, A2, A3 : in signed(INPUT_WIDTH-1 downto 0);
        B0, B1, B2, B3 : in signed(INPUT_WIDTH-1 downto 0);

        Y0, Y1, Y2, Y3 : out signed(ACC_WIDTH-1 downto 0)
    );
end entity mac_array;

architecture Structural of mac_array is

begin

	MAC0: entity work.mac
	
        generic map (
            INPUT_WIDTH => INPUT_WIDTH,
            ACC_WIDTH   => ACC_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            en => en,
            clear => clear,
            A => A0,
            B => B0,
            Y => Y0
        );

    MAC1: entity work.mac
        generic map (
            INPUT_WIDTH => INPUT_WIDTH,
            ACC_WIDTH   => ACC_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            en => en,
            clear => clear,
            A => A1,
            B => B1,
            Y => Y1
        );

    MAC2: entity work.mac
        generic map (
            INPUT_WIDTH => INPUT_WIDTH,
            ACC_WIDTH   => ACC_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            en => en,
            clear => clear,
            A => A2,
            B => B2,
            Y => Y2
        );

    MAC3: entity work.mac
        generic map (
            INPUT_WIDTH => INPUT_WIDTH,
            ACC_WIDTH   => ACC_WIDTH
        )
        port map (
            clk => clk,
            rst => rst,
            en => en,
            clear => clear,
            A => A3,
            B => B3,
            Y => Y3
        );

end architecture Structural;