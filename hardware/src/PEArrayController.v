`ifdef PE_ARRAY_CONTROLLER
`else
`define PE_ARRAY_CONTROLLER

`include "src/PE.v"

module PEArrayController (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//parameter
	input [`V_E_F_Bit-1:0] i_match,
	input [`V_E_F_Bit-1:0] i_mismatch,
	input [`V_E_F_Bit-1:0] i_minusAlpha,
	input [`V_E_F_Bit-1:0] i_minusBeta,

	//top && controll
	input i_start,
	output reg o_busy,
	output reg [`V_E_F_Bit-1:0] o_result,
	output reg o_valid,
	output reg o_init,

	//Data Processor
	input i_data_valid,

	output reg o_update_s_w,
	input [`PE_Array_size*2-1:0] i_s,
	input i_s_last,

	output reg  o_update_t_w,
	output reg [1:0] o_t,
	output reg [`V_E_F_Bit-1:0] o_v,
	output reg [`V_E_F_Bit-1:0] o_f,
	input [1:0] i_t,
	input [`V_E_F_Bit-1 : 0] i_v,
	input [`V_E_F_Bit-1 : 0] i_f,
	input i_t_last
);
endmodule // PEArrayController
`endif