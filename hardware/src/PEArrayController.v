`ifdef PE_ARRAY_CONTROLLER
`else
`define PE_ARRAY_CONTROLLER

`include "src/PE.v"

module PEArrayController (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//parameter
	input [`Match_bit-1:0] i_match,
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
	output [1:0] o_t,
	output [`V_E_F_Bit-1:0] o_v,
	output [`V_E_F_Bit-1:0] o_f,
	input [1:0] i_t,
	input [`V_E_F_Bit-1 : 0] i_v,
	input [`V_E_F_Bit-1 : 0] i_f,
	input i_t_last
);

//PE 
reg [`PE_Array_size-1 : 0] PE_enable, n_PE_enable;
reg PE_lock, n_PE_lock;
wire PE_newline [0 : `PE_Array_size];
wire [1:0] PE_t [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_v [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_v_a [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_f [0 : `PE_Array_size];


genvar idx;
	for(idx = 0; idx < `PE_Array_size; idx = idx+1) PE cell(.clk(clk), .rst(rst_n), .enable(PE_enable[`PE_Array_size - idx - 1]), 
		.lock(PE_lock), .newLineIn(PE_newline[idx]), .newLineOut[idx+1], .s(i_s[(`PE_Array_size - idx)*2-1 : (`PE_Array_size - idx)*2-2]), 
		.tIn(PE_t[idx]), .tOut(PE_t[idx+1]), .match(i_match), .mismatch(i_mismatch), .minusAlpha(i_minusAlpha), 
		.minusBeta(i_minusBeta), .vIn(PE_v[idx]), .vIn_alpha(PE_v_a[idx]), .fIn(PE_f[idx]), .vOut);
generate

endgenerate
endmodule // PEArrayController
`endif