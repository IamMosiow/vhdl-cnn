library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity conv2d_3x3 is
    generic (
        DATA_WIDTH : positive := 8;
        ACC_WIDTH  : positive := 24
    );

    port (
        clk   : in std_logic;
        rst   : in std_logic;

        start : in std_logic;

        -- Input feature map window
        X0, X1, X2 : in signed(DATA_WIDTH-1 downto 0);
        X3, X4, X5 : in signed(DATA_WIDTH-1 downto 0);
        X6, X7, X8 : in signed(DATA_WIDTH-1 downto 0);

        -- Convolution kernel
        W0, W1, W2 : in signed(DATA_WIDTH-1 downto 0);
        W3, W4, W5 : in signed(DATA_WIDTH-1 downto 0);
        W6, W7, W8 : in signed(DATA_WIDTH-1 downto 0);

        -- Result
        result : out signed(ACC_WIDTH-1 downto 0);
        valid  : out std_logic
    );
end entity conv2d_3x3;

architecture Behavioral of conv2d_3x3 is
	--FSM states
	Type state_type is (
		IDLE,
		CLEAR_ACC,
		COMPUTE,
		REDUCE,
		DONE
	);
	
	signal state : state_type := IDLE;
	
	--MAC control signals
	
    signal mac_en    : std_logic := '0';
    signal mac_clear : std_logic := '0';

    -- Computation cycle counter: 0, 1, 2
    signal cycle_count : integer range 0 to 2 := 0;

    -- Four MAC outputs
    signal mac_y0, mac_y1 : signed(ACC_WIDTH-1 downto 0);
    signal mac_y2, mac_y3 : signed(ACC_WIDTH-1 downto 0);

    -- Final result register
    signal result_reg : signed(ACC_WIDTH-1 downto 0) := (others => '0');
begin

	result <= result_reg;

end architecture Behavioral;