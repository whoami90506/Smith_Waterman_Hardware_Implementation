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
	output [`V_E_F_Bit-1:0] o_result,
	output reg o_valid,

	//sram
	input [`Max_T_size_log-1 : 0] i_t_size,

	//Data Processor
	input i_lock,

	input [`PE_Array_size*2-1:0] i_s,
	input i_s_last,
	input [`PE_Array_size_log-1 : 0] i_s_addr,

	output reg [1:0] o_t,
	output reg [`V_E_F_Bit-1:0] o_v,
	output reg [`V_E_F_Bit-1:0] o_f,
	output reg o_t_valid,

	input [1:0] i_t,
	input [`V_E_F_Bit-1 : 0] i_v,
	input [`V_E_F_Bit-1 : 0] i_v_a,
	input [`V_E_F_Bit-1 : 0] i_f,
	input i_t_newline,
	input i_enable_0
);
genvar idx;
integer i;

//IO
reg n_o_valid;
reg t_valid_buf;
wire n_t_valid_buf;
reg n_o_t_valid;
wire [1:0] n_o_t;
wire [`V_E_F_Bit-1 : 0] n_o_v, n_o_f;

//control
localparam IDLE = 2'd0;
localparam OPEN = 2'd1;
localparam CALC = 2'd2;
localparam END  = 2'd3;
reg [1:0] state, n_state;
reg [`PE_Array_size_log-1 : 0] s_using, n_s_using;

//PE 
reg [ `PE_Array_size-2 : 0] PE_enable, n_PE_enable;
wire [`PE_Array_size-1 : 0] PE_enable_all;
wire [ `PE_Array_size-1 : 0] PE_newline;
wire [1:0] PE_t [0 : `PE_Array_size-1];
wire [`V_E_F_Bit-1 :0] PE_v [0 : `PE_Array_size-1];
wire [`V_E_F_Bit-1 :0] PE_v_a [0 : `PE_Array_size-1];
wire [`V_E_F_Bit-1 :0] PE_f [0 : `PE_Array_size-1];

//Max
wire [`V_E_F_Bit * `PE_Array_size -1 : 0] PE_v_1D;

//assign
assign n_t_valid_buf = ~i_lock;
assign n_o_t = PE_t[s_using];
assign n_o_v = PE_v[s_using];
assign n_o_f = PE_f[s_using];
assign PE_enable_all[0] = i_enable_0;
assign PE_enable_all[`PE_Array_size-1 : 1] = PE_enable;
generate
	for(idx = 0; idx < `PE_Array_size; idx = idx+1) assign PE_v_1D[`V_E_F_Bit * idx +: `V_E_F_Bit] = PE_v[idx];
endgenerate

always @(*) begin
	n_state = state;
	n_s_using = s_using;
	n_PE_enable = PE_enable;
	n_o_valid = 1'b0;
	n_o_t_valid = 1'b0;

	case (state)
		IDLE : begin
			n_state = i_start ? OPEN : IDLE;
			n_s_using = 0;
			n_PE_enable = 0;
		end

		OPEN : begin
			if(~i_lock) begin
				n_state = (i_s_last || (i_s_addr == `PE_Array_size-1) || (i_s_addr == i_t_size -1) ) ? CALC : OPEN;
				n_s_using = i_s_addr;
				n_PE_enable[i_s_addr] = ~i_s_last;
			end
		end

		CALC :begin
			n_state = (PE_enable_all == {`PE_Array_size{1'b0}})  ? END : CALC;
			n_s_using = i_s_last ? i_s_addr : s_using;
			n_o_t_valid = t_valid_buf && (s_using == `PE_Array_size-1);

			if(~i_lock) begin
				for(i = 0; i < `PE_Array_size-1; i = i+1)n_PE_enable[i] = PE_enable_all[i] ? PE_enable[i] : 1'b0;
				n_PE_enable[i_s_addr] = i_s_last | ~PE_enable_all[i_s_addr] ? 1'b0 : PE_enable[i_s_addr]; 
			end
		end

		END : begin
			n_state = IDLE;
			n_s_using = 0;
			n_PE_enable = 0;
			n_o_valid = 1'b1;
			n_o_t_valid = 1'b0;
		end
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		//control
		state <= IDLE;
		s_using <= 0;

		//IO
		o_valid <= 1'b0;
		o_t <= 2'd0;
		o_v <= 0;
		o_f <= 0;
		o_t_valid <= 1'b0;
		t_valid_buf <= 1'b0;

		//PE
		PE_enable <= {(`PE_Array_size-1){1'b0}};
	end else begin
		//control
		state <= n_state;
		s_using <= n_s_using;

		//IO
		o_valid <= n_o_valid;
		o_t <= n_o_t;
		o_v <= n_o_v;
		o_f <= n_o_f;
		o_t_valid <= n_o_t_valid;
		t_valid_buf <= n_t_valid_buf;

		//PE
		PE_enable <= n_PE_enable;
	end
end

PE PE_cell_first(.clk(clk), .rst(rst_n), .enable(i_enable_0), .lock(i_lock), .newLineIn(i_t_newline), .newLineOut(PE_newline[0]), 
	.s(i_s[1:0]), .tIn(i_t), .tOut(PE_t[0]), .minusAlpha(i_minusAlpha), .minusBeta(i_minusBeta), 
	.mismatch(i_mismatch), .match(i_match), .vIn(i_v), .vIn_alpha(i_v_a), .fIn(i_f), .vOut(PE_v[0]), .vOut_alpha(PE_v_a[0]), 
	.fOut(PE_f[0]));

generate
	for(idx = 0; idx < `PE_Array_size-1; idx = idx+1) PE PE_cell(.clk(clk), .rst(rst_n), .enable(PE_enable[idx]), .lock(i_lock), 
		.newLineIn (PE_newline[idx]), .newLineOut(PE_newline[idx+1]), .s(i_s[2*(idx+1) +: 2]), .tIn(PE_t[idx]), 
		.tOut(PE_t[idx+1]), .minusAlpha(i_minusAlpha), .minusBeta(i_minusBeta), .mismatch(i_mismatch), .match(i_match), 
		.vIn(PE_v[idx]), .vIn_alpha(PE_v_a[idx]), .fIn(PE_f[idx]), .vOut(PE_v[idx+1]), .vOut_alpha(PE_v_a[idx+1]), .fOut(PE_f[idx+1]));
endgenerate

myMax64 maxTree(.clk(clk), .rst_n(rst_n), .in(PE_v_1D), .result(o_result), .init(o_valid));

endmodule // PEArrayController
`endif