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
    
	-- Inputs to the four MAC units
	signal mac_a0, mac_a1, mac_a2, mac_a3 : signed(DATA_WIDTH-1 downto 0);
	signal mac_b0, mac_b1, mac_b2, mac_b3 : signed(DATA_WIDTH-1 downto 0);
	
	-- Intermediate result for summing the four MAC outputs
	signal reduced_sum : signed(ACC_WIDTH+1 downto 0);

begin

	result <= result_reg;

	reduced_sum <=
		resize(mac_y0, ACC_WIDTH+2) +
		resize(mac_y1, ACC_WIDTH+2) +
		resize(mac_y2, ACC_WIDTH+2) +
		resize(mac_y3, ACC_WIDTH+2);
	
	-- Operand scheduler
	scheduler: process(
		state, cycle_count,
		X0, X1, X2, X3, X4, X5, X6, X7, X8,
		W0, W1, W2, W3, W4, W5, W6, W7, W8
	)
	begin
	
		-- Default values
		mac_a0 <= (others => '0');
		mac_a1 <= (others => '0');
		mac_a2 <= (others => '0');
		mac_a3 <= (others => '0');
	
		mac_b0 <= (others => '0');
		mac_b1 <= (others => '0');
		mac_b2 <= (others => '0');
		mac_b3 <= (others => '0');
	
		if state = COMPUTE then
	
			case cycle_count is
	
				when 0 =>
					mac_a0 <= X0;
					mac_b0 <= W0;
	
					mac_a1 <= X1;
					mac_b1 <= W1;
	
					mac_a2 <= X2;
					mac_b2 <= W2;
	
					mac_a3 <= X3;
					mac_b3 <= W3;
	
				when 1 =>
					mac_a0 <= X4;
					mac_b0 <= W4;
	
					mac_a1 <= X5;
					mac_b1 <= W5;
	
					mac_a2 <= X6;
					mac_b2 <= W6;
	
					mac_a3 <= X7;
					mac_b3 <= W7;
	
				when 2 =>
					mac_a0 <= X8;
					mac_b0 <= W8;
	
				when others =>
					null;
	
			end case;
	
		end if;
	
	end process scheduler;	
	
	control: process(state)
	begin
		-- Default values
		mac_en    <= '0';
		mac_clear <= '0';
		valid     <= '0';
	
		case state is
	
			when CLEAR_ACC =>
				mac_clear <= '1';
	
			when COMPUTE =>
				mac_en <= '1';
	
			when DONE =>
				valid <= '1';
	
			when others =>
				null;
	
		end case;
	end process control;
	
	fsm: process(clk)
	begin
		if rising_edge(clk) then
	
			if rst = '1' then
				state       <= IDLE;
				cycle_count <= 0;
				result_reg  <= (others => '0');
	
			else
				case state is
	
					when IDLE =>
						cycle_count <= 0;
	
						if start = '1' then
							state <= CLEAR_ACC;
						end if;
	
	
					when CLEAR_ACC =>
						cycle_count <= 0;
						state <= COMPUTE;
	
	
					when COMPUTE =>
						if cycle_count = 2 then
							state <= REDUCE;
						else
							cycle_count <= cycle_count + 1;
						end if;
	
	
					when REDUCE =>
						result_reg <= resize(reduced_sum, ACC_WIDTH);
						state <= DONE;
	
	
					when DONE =>
						state <= IDLE;
	
	
					when others =>
						state <= IDLE;
	
				end case;
			end if;
	
		end if;
	end process fsm;
		
-- MAC unit 0
MAC0: entity work.mac
    generic map (
        INPUT_WIDTH => DATA_WIDTH,
        ACC_WIDTH   => ACC_WIDTH
    )
    port map (
        clk   => clk,
        rst   => rst,
        en    => mac_en,
        clear => mac_clear,
        A     => mac_a0,
        B     => mac_b0,
        Y     => mac_y0
    );

	-- MAC unit 1
	MAC1: entity work.mac
		generic map (
			INPUT_WIDTH => DATA_WIDTH,
			ACC_WIDTH   => ACC_WIDTH
		)
		port map (
			clk   => clk,
			rst   => rst,
			en    => mac_en,
			clear => mac_clear,
			A     => mac_a1,
			B     => mac_b1,
			Y     => mac_y1
		);
	
	-- MAC unit 2
	MAC2: entity work.mac
		generic map (
			INPUT_WIDTH => DATA_WIDTH,
			ACC_WIDTH   => ACC_WIDTH
		)
		port map (
			clk   => clk,
			rst   => rst,
			en    => mac_en,
			clear => mac_clear,
			A     => mac_a2,
			B     => mac_b2,
			Y     => mac_y2
		);
	
	-- MAC unit 3
	MAC3: entity work.mac
		generic map (
			INPUT_WIDTH => DATA_WIDTH,
			ACC_WIDTH   => ACC_WIDTH
		)
		port map (
			clk   => clk,
			rst   => rst,
			en    => mac_en,
			clear => mac_clear,
			A     => mac_a3,
			B     => mac_b3,
			Y     => mac_y3
		);
		
end architecture Behavioral;