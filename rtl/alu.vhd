library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;

entity alu is
	generic (
		WIDTH : positive := 16
	);
	port (
		A	: in signed(WIDTH-1 downto 0);
		B	: in signed(WIDTH-1 downto 0);
		OP	: std_logic_vector(2 downto 0);
		
		Y	: out signed(WIDTH-1 downto 0)
	);
end entity alu;

architecture Behavioral of alu is
begin

	process(A, B, OP)
	begin
		case OP is
            when "000" =>
                Y <= A + B;

            when "001" =>
                Y <= A - B;

            when "010" =>
                Y <= A and B;

            when "011" =>
                Y <= A or B;

            when "100" =>
                Y <= A xor B;

            when "101" =>
                Y <= not A;

            when "110" =>
                Y <= shift_left(A, 1);

            when "111" =>
                Y <= shift_right(A, 1);

            when others =>
                Y <= (others => '0');
        end case;
    end process;

end architecture Behavioral;