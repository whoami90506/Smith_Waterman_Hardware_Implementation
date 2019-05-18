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

	output reg o_update_s_w,
	input [1:0] i_s,
	input i_s_last,

	output reg  o_update_t_w,
	output [1:0] o_t,
	output [`V_E_F_Bit-1:0] o_v,
	output [`V_E_F_Bit-1:0] o_f,
	output reg o_t_valid,
	input [1:0] i_t,
	input [`V_E_F_Bit-1 : 0] i_v,
	input [`V_E_F_Bit-1 : 0] i_f,
	input i_t_last
);

genvar idx;
integer i;

//IO
reg n_o_busy, n_o_valid, n_o_init, n_o_t_valid;

//control
localparam IDLE = 3'd0;
reg [3:0] state, n_state;
reg [`PE_Array_size_log-1 : 0] s_counter, n_s_counter;
reg max_init, n_max_init;

//PE 
reg newline, n_newline;
reg [`PE_Array_size-1 : 0] PE_enable, n_PE_enable;
reg PE_lock, n_PE_lock;
wire PE_newline [0 : `PE_Array_size];

reg [1:0] PE_s [0: `PE_Array_size-1];
reg [1:0] n_PE_s [0: `PE_Array_size-1];
wire [1:0] PE_t [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_v [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_v_a [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_f [0 : `PE_Array_size];

//Max
wire [`V_E_F_Bit * `PE_Array_size -1 : 0] PE_v_1D;

//assignment
assign PE_t[0] = i_t;
assign PE_v[0] = i_v;
assign PE_v_a[0] = i_v + i_minusAlpha;
assign PE_f[0] = i_f;
assign PE_newline[0] = newline;
assign o_t = PE_t[`PE_Array_size];
assign o_v = PE_v[`PE_Array_size];
assign o_f = PE_f[`PE_Array_size];

generate
	for(idx = 0; idx < `PE_Array_size; idx = idx+1)
		assign PE_v_1D[`V_E_F_Bit * (idx+1) -1 : `V_E_F_Bit * idx] = PE_v[idx+1];
endgenerate

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		
	end else begin
		
	end
end

generate
	for(idx = 0; idx < `PE_Array_size; idx = idx+1) PE PE_cell(.clk(clk), .rst(rst_n), .enable(PE_enable[`PE_Array_size - idx - 1]), 
		.lock(PE_lock), .newLineIn(PE_newline[idx]), .newLineOut(PE_newline[idx+1]), .s(PE_s[idx]), 
		.tIn(PE_t[idx]), .tOut(PE_t[idx+1]), .match(i_match), .mismatch(i_mismatch), .minusAlpha(i_minusAlpha), 
		.minusBeta(i_minusBeta), .vIn(PE_v[idx]), .vIn_alpha(PE_v_a[idx]), .fIn(PE_f[idx]), .vOut(PE_v[idx+1]), 
		.vOut_alpha(PE_v_a[idx+1]), .fOut(PE_f[idx+1]));
endgenerate

myMax64 maxTree(.clk(clk), .rst_n(rst_n), .in(PE_v_1D), .result(o_result), .init(max_init));

endmodule // PEArrayController
`endif