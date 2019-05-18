`ifdef TOP
`else
`define TOP

`include "src/DataProcessor.v"
`include "src/SramController.v"
`include "src/PEArrayController.v"
`include "src/util.v"

module Top (
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
reg _set_t, _start_cal;
reg n_o_busy;
reg [17:0] _t;
reg [`PE_Array_size*2-1:0] _s;
reg [`PE_Array_size_log : 0] _s_valid;
reg [`Match_bit-1 : 0 ] _match, _mismatch;
reg [7:0] _minusAlpha, _minusBeta;
reg _param_valid;

//controll
localparam IDLE = 2'd0;
localparam SETT = 2'd1;
localparam CALC = 2'd2;
localparam RESET = 2'd3;

reg [1:0] state, n_state;
reg start_read_t, n_start_read_t;
reg start_cal, n_start_cal;

//param
reg [`Match_bit-1 : 0] post_match, n_post_match;
reg [`V_E_F_Bit-1 : 0] post_mismatch, post_alpha, post_beta;
reg [`V_E_F_Bit-1 : 0] n_post_mismatch, n_post_alpha, n_post_beta;

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
wire [`PE_Array_size_log : 0] init_s_len;

//PEArrayController
wire init, PE_busy, t_valid;
wire PE_update_s_w, PE_update_t_w;
wire [1:0] t_PE_to_dp;
wire [`V_E_F_Bit-1 : 0] v_PE_to_dp, f_PE_to_dp;

//control && IO
always @(*) begin
	n_state = state;
	n_start_read_t = 1'd0;
	n_start_cal = 1'd0;

	case (state)
		IDLE : begin
			n_o_busy = 1'd0;

			if(_set_t) begin
				n_state = SETT;
				n_start_read_t = 1'd1;
				n_o_busy = 1'd1;
			end else if (_start_cal && (t_size != 0)) begin
				n_state = CALC;
				n_start_cal = 1'd1;
				n_o_busy = 1'd1;
			end
		end

		SETT : begin
			if(~sram_busy & ~start_read_t)n_state = IDLE;
			n_o_busy = sram_busy | start_read_t;
		end

		CALC : begin
			if(o_valid)n_state = RESET;
			n_o_busy = 1'd1;
		end

		RESET : begin
			if(~sram_busy & ~PE_busy )n_state = IDLE;
			n_o_busy = sram_busy | PE_busy;
		end
	endcase
end

//param
always @(*) begin
	if(_param_valid & (state != CALC)) begin
		n_post_match = _match;
		n_post_mismatch = {{(`V_E_F_Bit - `Match_bit){1'd1}}, (~_mismatch + 1)};
		n_post_alpha = {{(`V_E_F_Bit - 8){1'd1}}, (~_minusAlpha + 1)};
		n_post_beta = {{(`V_E_F_Bit - 8){1'd1}}, (~_minusBeta + 1)};

	end else begin
		n_post_match = post_match;
		n_post_mismatch = post_mismatch;
		n_post_alpha = post_alpha;
		n_post_beta = post_beta;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		//control
		state <= IDLE;
		start_read_t <= 1'd0;
		start_cal <= 1'd0;

		//IO
		_set_t <= 1'd0;
		_start_cal <= 1'd0;
		o_busy <= 1'd0;
		_t <= 18'd0;
		_s <= {(`PE_Array_size*2){1'd0}};
		_s_valid <= 1'd0;
		_match <= 0;
		_mismatch <= 0;
		_minusAlpha <= 0;
		_minusBeta <= 0;
		_param_valid <= 1'd0;

		//param
		post_match <= 6;
		post_mismatch <= {`V_E_F_Bit{1'd1}};
		post_alpha <= {{(`V_E_F_Bit-1){1'd1}}, 1'd0};
		post_beta <= {`V_E_F_Bit{1'd1}};

	end else begin
		//control
		state <= n_state;
		start_read_t <= n_start_read_t;
		start_cal <= n_start_cal;

		//IO
		_set_t <= i_set_t;
		_start_cal <= i_start_cal;
		o_busy <= n_o_busy;
		_t <= i_t;
		_s <= i_s;
		_s_valid <= i_s_valid;
		_match <= i_match;
		_mismatch <= i_mismatch;
		_minusAlpha <= i_minusAlpha;
		_minusBeta <= i_minusBeta;
		_param_valid <= i_param_valid;

		//param
		post_match <= n_post_match;
		post_mismatch <= n_post_mismatch;
		post_alpha <= n_post_alpha;
		post_beta <= n_post_beta;
	end
end

SramController mem(.clk(clk), .rst_n(rst_n), .i_PE_request(dp_request_sram), .o_request_data(data_sram_to_dp), .i_PE_send(dp_store_sram), 
	.i_send_data(data_dp_to_sram), .o_T_size(t_size), .i_init(init), .i_start_read_t(start_read_t), .i_t(_t), .o_busy(sram_busy));

DataProcessor dp(.clk(clk), .rst_n(rst_n), .o_sram_request(dp_request_sram), .i_request_data(data_sram_to_dp), .o_sram_send(dp_store_sram), 
	.o_send_data(data_dp_to_sram), .i_T_size(t_size), .o_valid(dp_data_valid), .i_init(init), .i_PE_update_s(PE_update_s_w), .o_s(seq_s), 
	.o_s_last(seq_s_last), .i_PE_update_t(PE_update_t_w), .o_t(t_dp_to_PE), .o_v(v_dp_to_PE), .o_f(f_dp_to_PE), .i_t(t_PE_to_dp), 
	.i_v(v_PE_to_dp), .i_f(f_PE_to_dp), .o_t_last(seq_t_last), .o_request_s(o_request_s), .i_s(_s), .i_s_valid(_s_valid), .o_init_s_len(init_s_len), 
	.i_t_valid(t_valid), .i_start_calc(start_cal));

PEArrayController PE(.clk(clk), .rst_n(rst_n), .i_match(post_match), .i_mismatch(post_mismatch), .i_minusAlpha(post_alpha), 
	.i_minusBeta (post_beta), .i_start(start_cal), .o_busy(PE_busy), .o_result(o_result), .o_valid(o_valid), .i_data_valid(dp_data_valid), 
	.o_update_s_w(PE_update_s_w), .i_s(seq_s), .i_s_last(seq_s_last), .o_update_t_w(PE_update_t_w), .o_t(t_PE_to_dp), .o_v(v_PE_to_dp), 
	.o_f(f_PE_to_dp), .i_t(t_dp_to_PE), .i_v(v_dp_to_PE), .i_f(f_dp_to_PE), .i_t_last(seq_t_last), .o_init(init), .i_init_s_len(init_s_len), 
	.o_t_valid(t_valid));

endmodule
`endif