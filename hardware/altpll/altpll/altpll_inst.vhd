	component altpll is
		port (
			clk_clk       : in  std_logic := 'X'; -- clk
			clock_30_clk  : out std_logic;        -- clk
			reset_reset_n : in  std_logic := 'X'  -- reset_n
		);
	end component altpll;

	u0 : component altpll
		port map (
			clk_clk       => CONNECTED_TO_clk_clk,       --      clk.clk
			clock_30_clk  => CONNECTED_TO_clock_30_clk,  -- clock_30.clk
			reset_reset_n => CONNECTED_TO_reset_reset_n  --    reset.reset_n
		);

