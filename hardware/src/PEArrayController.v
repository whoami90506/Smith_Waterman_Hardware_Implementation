`ifdef PE_ARRAY_CONTROLLER
`else
`define PE_ARRAY_CONTROLLER

`include "src/PE.v"

module PEArrayController (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//S
	output reg o_request_s,
	input [`PE_Array_size*2-1:0] i_s,
	input [`PE_Array_size_log-1 :0] i_s_valid,
	input i_s_last,

	//parameter
	input [`V_E_F_Bit-1:0] i_match,
	input [`V_E_F_Bit-1:0] i_mismatch,
	input [`V_E_F_Bit-1:0] i_minusAlpha,
	input [`V_E_F_Bit-1:0] i_minusBeta,
	input i_param_valid,

	//sram
	output reg o_readSram,
	input [`Sram_Word-1:0] i_readData,
	input i_readValid,
	output reg o_writeSram,
	output reg [`Sram_Word-1:0] o_writeData,

	//top
	input [`TOP_STATE_BIT-1 :0] i_top_state,
	output reg [`V_E_F_Bit-1:0] o_result,
	output reg o_valid
);
endmodule // PEArrayController
`endif