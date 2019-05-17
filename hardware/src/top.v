`ifdef TOP
`else
`define TOP

`include "src/DataProcessor.v"
`include "src/SramController.v"
`include "src/PEArrayController.v"
`include "src/util.v"

module top (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//user
	input i_set_t,
	input i_start_cal,
	output reg o_busy,
	output [`V_E_F_Bit-1:0] o_result,
	output o_valid,
	
	//data
	input [17:0] i_t,

	output o_request_s,
	input [`PE_Array_size*2-1:0] i_s,
	input [`PE_Array_size_log : 0] i_s_valid,

	input [`Match_bit-1 : 0] i_match,
	input [`Match_bit-1 : 0] i_mismatch,
	input [7:0] i_minusAlpha,
	input [7:0] i_minusBeta,
	input i_param_valid
);

//IO
reg [17:0] _t;
reg [`PE_Array_size*2-1:0] _s;
reg [`PE_Array_size_log : 0] _s_valid;

//controll
reg start_read_t;
reg start_cal;

//param
reg [`V_E_F_Bit-1 : 0] post_match, post_mismatch, post_alpha, post_beta;



//SramController
wire sram_busy;
wire [`Sram_Word-1:0] data_dp_to_sram;
wire [`Max_T_size_log-1 : 0] t_size;

//DataProcessor
wire dp_request_sram, dp_store_sram; 
wire [`Sram_Word-1:0] data_sram_to_dp;
wire dp_data_valid, seq_s_last, seq_t_last;
wire [`PE_Array_size*2-1:0] seq_s;
wire [1:0] t_dp_to_PE;
wire [`V_E_F_Bit-1 : 0] v_dp_to_PE, f_dp_to_PE;

//PEArrayController
wire init, PE_busy;
wire PE_update_s_w, PE_update_t_w;
wire [1:0] t_PE_to_dp;
wire [`V_E_F_Bit-1 : 0] v_PE_to_dp, f_PE_to_dp;

SramController mem(.clk(clk), .rst_n(rst_n), .i_PE_request(dp_request_sram), .o_request_data(data_sram_to_dp), .i_PE_send(dp_store_sram), 
	.i_send_data(data_dp_to_sram), .o_T_size(t_size), .i_init(init), .i_start_read_t(start_read_t), .i_t(_t), .o_busy(sram_busy));

DataProcessor dp(.clk(clk), .rst_n(rst_n), .o_sram_request(dp_request_sram), .i_request_data(data_sram_to_dp), .o_sram_send(dp_store_sram), 
	.o_send_data(data_dp_to_sram), .i_T_size(t_size), .o_valid(dp_data_valid), .i_init(init), .i_PE_update_s(PE_update_s_w), .o_s(seq_s), 
	.o_s_last(seq_s_last), .i_PE_update_t(PE_update_t_w), .o_t(t_dp_to_PE), .o_v(v_dp_to_PE), .o_f(f_dp_to_PE), .i_t(t_PE_to_dp), 
	.i_v(v_PE_to_dp), .i_f(f_PE_to_dp), .o_t_last(seq_t_last), .o_request_s(o_request_s), .i_s(_s), .i_s_valid(_s_valid));

PEArrayController PE(.clk(clk), .rst_n(rst_n), .i_match(post_match), .i_mismatch(post_mismatch), .i_minusAlpha(post_alpha), 
	.i_minusBeta (post_beta), .i_start(start_cal), .o_busy(PE_busy), .o_result(o_result), .o_valid(o_valid), .i_data_valid(dp_data_valid), 
	.o_update_s_w(PE_update_s_w), .i_s(seq_s), .i_s_last(seq_s_last), .o_update_t_w(PE_update_t_w), .o_t(t_PE_to_dp), .o_v(v_PE_to_dp), 
	.o_f(f_PE_to_dp), .i_t(t_dp_to_PE), .i_v(v_dp_to_PE), .i_f(f_dp_to_PE), .i_t_last(seq_t_last), .o_init(init));

endmodule
`endif