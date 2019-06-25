`include "src/FPGA/Debounce.sv"
`include "src/FPGA/FPGAWrapper.v"
`include "src/FPGA/NumberDecoder.sv"
`include "src/FPGA/SevenHexDecoder.sv"
`include "src/FPGA/timer.sv"

module DE2_115(
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	output [8:0] LEDG,
	output [17:0] LEDR,
	input [3:0] KEY,
	input [17:0] SW,
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	// inout AUD_DACLRCK,
	input AUD_DACLRCK,
	output AUD_XCK,
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	output I2C_SCLK,
	inout I2C_SDAT,
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);
/****************
	User
*****************/
logic CLOCK, RST_N;
logic set_t, start;
logic [3:0] match, mismatch, alpha, beta;
logic [1:0] seven_state;

assign CLOCK = CLOCK_50;
assign RST_N = KEY[0];
assign set_t = ~KEY[1];
assign start = ~KEY[2];
assign match = SW[17:14];
assign mismatch = SW[13:10];
assign alpha = SW[9:6];
assign beta = SW[5:2];
assign seven_state = SW[1:0];

/***************
	Moudle
***************/
//wrapper
logic sw_busy, sw_valid;
logic [17:0] sw_data;

//score
logic [31:0] score_decode, ans_timer, busy_timer;

logic [17:0] data, n_data;
logic is_set, n_is_set;
logic [31:0] seven;

assign LEDR = data;
assign LEDG[8] = sw_busy;
assign LEDG[0] = is_set;

assign n_data = sw_valid ? sw_data : data;
assign n_is_set = is_set ? 1'b1 : set_t;

always_comb begin
	case (seven_state)
		2'b00 : seven = score_decode;
		2'b01 : seven = ans_timer;
		2'b10 : seven = busy_timer;
		2'b11 : seven = 32'd0;
	endcase

end

always_ff @(posedge CLOCK or negedge RST_N) begin
	if(~RST_N) begin
		data <= 18'd0;
		is_set <= 1'b0;
	end else begin
		data <= n_data;
		is_set <= n_is_set;
	end
end

FPGAWrapper fw(.clk(CLOCK), .rst_n(RST_N), .i_set_t(set_t), .i_start_cal(start), .o_busy(sw_busy), .o_result(sw_data), .o_valid(sw_valid), 
	.i_match(match), .i_mismatch(mismatch), .i_minusAlpha(alpha), .i_minusBeta(beta));

NumberDecoder nd(.clk(CLOCK), .rst_n(RST_N), .i_data({9'd0, data}), .o_seven(score_decode));
timer ans(.clk(CLOCK), .rst_n(RST_N), .i_start(start), .i_end(sw_valid), .o_seven(ans_timer));
timer busy(.clk(CLOCK), .rst_n(RST_N), .i_start(sw_busy), .i_end(~sw_busy), .o_seven(busy_timer));

SevenHexDecoder s0(.i_data(seven[ 3: 0]), .o_seven(HEX0));
SevenHexDecoder s1(.i_data(seven[ 7: 4]), .o_seven(HEX1));
SevenHexDecoder s2(.i_data(seven[11: 8]), .o_seven(HEX2));
SevenHexDecoder s3(.i_data(seven[15:12]), .o_seven(HEX3));
SevenHexDecoder s4(.i_data(seven[19:16]), .o_seven(HEX4));
SevenHexDecoder s5(.i_data(seven[23:20]), .o_seven(HEX5));
SevenHexDecoder s6(.i_data(seven[27:24]), .o_seven(HEX6));
SevenHexDecoder s7(.i_data(seven[31:28]), .o_seven(HEX7));

endmodule
