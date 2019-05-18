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
	output [`V_E_F_Bit-1:0] o_result,
	output reg o_valid,
	output reg o_init,

	//Data Processor
	input i_data_valid,
	input [`PE_Array_size_log : 0] i_init_s_len,

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

//IO
reg n_o_busy, n_o_valid, n_o_init;

//control
localparam IDLE = 'd0;
reg [:0] state, n_state;
reg newline, n_newline;

//PE 
reg [`PE_Array_size-1 : 0] PE_enable, n_PE_enable;
reg PE_lock, n_PE_lock;
wire PE_newline [0 : `PE_Array_size];
wire [1:0] PE_t [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_v [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_v_a [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_f [0 : `PE_Array_size];

assign PE_t[0] = i_t;
assign PE_v[0] = i_v;
assign PE_v_a[0] = i_v + i_minusAlpha;
assign PE_f[0] = i_f;
assign PE_newline[0] = newline;
assign o_t = PE_t[`PE_Array_size];
assign o_v = PE_v[`PE_Array_size];
assign o_f = PE_f[`PE_Array_size];

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		
	end else begin
		
	end
end


genvar idx;
	for(idx = 0; idx < `PE_Array_size; idx = idx+1) PE PE_cell(.clk(clk), .rst(rst_n), .enable(PE_enable[`PE_Array_size - idx - 1]), 
		.lock(PE_lock), .newLineIn(PE_newline[idx]), .newLineOut(PE_newline[idx+1]), .s(i_s[(`PE_Array_size - idx)*2-1 : (`PE_Array_size - idx)*2-2]), 
		.tIn(PE_t[idx]), .tOut(PE_t[idx+1]), .match(i_match), .mismatch(i_mismatch), .minusAlpha(i_minusAlpha), 
		.minusBeta(i_minusBeta), .vIn(PE_v[idx]), .vIn_alpha(PE_v_a[idx]), .fIn(PE_f[idx]), .vOut(PE_v[idx+1]), 
		.vOut_alpha(PE_v_a[idx+1]), .fOut(PE_f[idx+1]));
generate

endgenerate
endmodule // PEArrayController
`endif