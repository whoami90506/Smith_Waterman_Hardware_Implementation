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

	//Data Processor
	input i_data_valid,

	output reg o_update_s_w,
	input [1:0] i_s,
	input i_s_last,

	output reg  o_update_t_w,
	output reg [1:0] o_t,
	output reg [`V_E_F_Bit-1:0] o_v,
	output reg [`V_E_F_Bit-1:0] o_f,
	output reg o_t_valid,
	input [1:0] i_t,
	input [`V_E_F_Bit-1 : 0] i_v,
	input [`V_E_F_Bit-1 : 0] i_f,
	input i_t_last
);

genvar idx;
integer i;

//IO
reg n_o_busy, n_o_valid, n_o_t_valid;
reg update_s_r, update_t_r;
reg [1:0] n_o_t;
reg [`V_E_F_Bit-1:0] n_o_v, n_o_f;

//control
localparam IDLE    = 3'd0;
localparam READ_ST = 3'd1;
localparam READ_T  = 3'd2;
localparam FINAL_T = 3'd3;
localparam RESULT  = 3'd4;
localparam END     = 3'd5;

reg [3:0] state, n_state;
reg [`PE_Array_size_log-1 : 0] s_counter, n_s_counter;
reg max_init, n_max_init;
reg first_itr, n_first_itr;

//PE 
reg newline, n_newline;
reg PE_lock_w;
reg [`PE_Array_size_log-1 : 0] s_using, n_s_using;

reg PE_enable [0 : `PE_Array_size-1];
reg n_PE_enable [0 : `PE_Array_size-1];
reg [1:0] PE_s [0: `PE_Array_size-1];
reg [1:0] n_PE_s [0: `PE_Array_size-1];

wire PE_newline [0 : `PE_Array_size];
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

//control
always @(*) begin
	n_state = state;
	n_s_counter = 0;
	n_max_init = 1'd0;
	n_first_itr = first_itr;

	case (state)
		IDLE : if(i_start)n_state = READ_ST;
	endcase
end

//IO
always @(*) begin
	n_o_busy = 1'b0;
	n_o_valid = 1'b0;
	n_o_t_valid = 1'b0;
	n_o_t = o_t;
	n_o_v = o_v;
	n_o_f = o_f;
	o_update_s_w = update_s_r;
	o_update_t_w = update_t_r;

	case (state)
		IDLE : begin
			o_update_s_w = 1'b1;
			o_update_t_w = 1'b1;
		end
	endcase
end

//PE
always @(*) begin
	n_newline = newline;
	PE_lock_w = 1'd0;
	n_s_using = s_using;
	
	for(i = 0; i < `PE_Array_size; i = i+1) begin
		n_PE_enable[i] = PE_enable[i];
		n_PE_s[i] = PE_s[i];
	end
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		//control
		state <= IDLE;
		s_counter <= 0;
		max_init <= 1'd0;
		first_itr <= 1'd1;

		//IO
		o_busy <= 1'd0;
		o_valid <= 1'd0;
		o_t <= 2'd0;
		o_v <= 0;
		o_f <= 0;
		o_t_valid <= 1'd0;
		update_s_r <= 1'd0;
		update_t_r <= 1'd0;

		//PE
		newline <= 1'd0;
		s_using <= `PE_Array_size;

		for(i = 0; i < `PE_Array_size; i = i+1) begin
			PE_enable[i] = 1'b1;
			PE_s[i] = 2'd0;
		end
	end else begin
		
	end
end

generate
	for(idx = 0; idx < `PE_Array_size; idx = idx+1) PE PE_cell(.clk(clk), .rst(rst_n), .enable(PE_enable[idx]), 
		.lock(PE_lock_w), .newLineIn(PE_newline[idx]), .newLineOut(PE_newline[idx+1]), .s(PE_s[idx]), 
		.tIn(PE_t[idx]), .tOut(PE_t[idx+1]), .match(i_match), .mismatch(i_mismatch), .minusAlpha(i_minusAlpha), 
		.minusBeta(i_minusBeta), .vIn(PE_v[idx]), .vIn_alpha(PE_v_a[idx]), .fIn(PE_f[idx]), .vOut(PE_v[idx+1]), 
		.vOut_alpha(PE_v_a[idx+1]), .fOut(PE_f[idx+1]));
endgenerate

myMax64 maxTree(.clk(clk), .rst_n(rst_n), .in(PE_v_1D), .result(o_result), .init(max_init));

generate
	for(idx = 0; idx < `PE_Array_size; idx = idx+1)
		assign PE_v_1D[`V_E_F_Bit * (idx+1) -1 : `V_E_F_Bit * idx] = PE_v[idx+1];
endgenerate

endmodule // PEArrayController
`endif