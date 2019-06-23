`ifdef FPGA_WRAPPER
`else
`define FPGA_WRAPPER

`include "src/top.v"

module FPGAWrapper (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//user
	input i_set_t,
	input i_start_cal,
	output reg o_busy,

	input [`Match_bit-1 : 0] i_match,
	input [`Match_bit-1 : 0] i_mismatch,
	input [`Alpha_Beta_Bit-1:0] i_minusAlpha,
	input [`Alpha_Beta_Bit-1:0] i_minusBeta
);

endmodule
`endif