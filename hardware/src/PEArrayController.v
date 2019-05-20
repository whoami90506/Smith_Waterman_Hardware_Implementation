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
reg t_valid_buf, t_valid_buf1;
reg n_o_busy, n_o_valid, n_t_valid_buf;
reg [1:0] t_buf;
reg [`V_E_F_Bit-1:0] v_buf, f_buf, v_a_buf;
wire [`V_E_F_Bit-1:0] n_v_a_buf;

//control
localparam IDLE    = 3'd0;
localparam READ_ST = 3'd1;
localparam READ_T  = 3'd2;
localparam FINAL_T = 3'd3;
localparam WAIT    = 3'd4;
localparam RESULT  = 3'd5;

reg [3:0] state, n_state;
reg [`PE_Array_size_log-1 : 0] counter, n_counter;
reg first_itr, n_first_itr;

//PE 
reg newline, n_newline, newline_buf;
reg PE_lock, n_PE_lock;
reg [`PE_Array_size_log-1 : 0] s_using, n_s_using;

reg [ `PE_Array_size-1 : 0] PE_enable;
reg [ `PE_Array_size-1 : 0] n_PE_enable;
reg [1:0] PE_s [0: `PE_Array_size-1];
reg [1:0] n_PE_s [0: `PE_Array_size-1];

wire [ `PE_Array_size : 0] PE_newline;
wire [1:0] PE_t [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_v [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_v_a [0 : `PE_Array_size];
wire [`V_E_F_Bit-1 :0] PE_f [0 : `PE_Array_size];

//Max
wire [`V_E_F_Bit * `PE_Array_size -1 : 0] PE_v_1D;

//assignment
assign PE_t[0] = t_buf;
assign PE_v[0] = v_buf;
assign PE_v_a[0] = v_a_buf;
assign PE_f[0] = f_buf;
assign PE_newline[0] = newline_buf;

assign n_v_a_buf = i_v + i_minusAlpha;
assign n_o_t = PE_t[{1'b0, s_using} +1];
assign n_o_v = PE_v[{1'b0, s_using} +1];
assign n_o_f = PE_f[{1'b0, s_using} +1];


//control
always @(*) begin
	n_state = state;
	n_counter = counter;
	n_first_itr = first_itr;

	case (state)
		IDLE : begin
			if(i_start)n_state = READ_ST;
			n_counter = 0;
			n_first_itr = 1'b1;
		end //IDLE

		READ_ST : begin
			if(i_data_valid) begin
				if(i_s_last | i_t_last | (counter == s_using) ) begin
					n_counter = 0;
					n_first_itr = 1'b0;
				end else n_counter = counter +1;

				case ({i_s_last, i_t_last})
					2'b11 : n_state = WAIT;
					2'b10 : n_state = FINAL_T;
					2'b01 : n_state = READ_ST;
					2'b00 : begin
						if (counter == s_using) n_state = READ_T;
					end
					
				endcase
			end
		end //READ_ST

		READ_T : if(i_data_valid & i_t_last) n_state = READ_ST;

		FINAL_T : if(i_data_valid & i_t_last) n_state = WAIT;

		WAIT : if(~PE_enable) n_state = RESULT;

		RESULT : n_state = IDLE;
	endcase
end

//IO
always @(*) begin
	n_o_busy = 1'b1;
	n_o_valid = 1'b0;
	n_t_valid_buf = 1'b0;
	o_update_s_w = 1'b0;
	o_update_t_w = 1'b0;
	

	case (state)
		IDLE : begin
			n_o_busy = i_start;
			o_update_s_w = 1'b1;
			o_update_t_w = 1'b1;
		end//IDLE

		READ_ST : begin
			o_update_s_w = 1'b1;
			o_update_t_w = 1'b1;

			if(i_data_valid) begin
				n_t_valid_buf = ~first_itr;
				case ({i_s_last, i_t_last})
					2'b11 : begin //WAIT
						o_update_t_w = 1'd0;
						o_update_s_w = 1'd0;
					end 
					2'b10 : begin // final T
						o_update_t_w = 1'd1;
						o_update_s_w = 1'd0;
					end
					2'b00 : begin
						if (counter == s_using) begin //READ_T
							o_update_t_w = 1'd1;
							o_update_s_w = 1'd0;
						end
					end
					
					//2'b01 remain the same
				endcase
			end		
		end//READ_ST

		READ_T : begin
			o_update_t_w = 1'd1;
			o_update_s_w = 1'd0;

			if(i_data_valid) begin
				n_t_valid_buf = 1'd1;
				if(i_t_last) o_update_s_w = 1'b1;
			end
		end //READ_T

		FINAL_T : begin
			o_update_t_w = ~(i_data_valid & i_t_last);
			o_update_s_w = 1'd0;
		end //FINAL_T

		//Wait is default

		RESULT : n_o_valid = 1'd1;
	endcase
end

//PE
always @(*) begin
	n_newline = newline;
	n_PE_lock = ~i_data_valid;
	n_s_using = s_using;
	for(i = 0; i < `PE_Array_size; i = i+1) begin
		n_PE_enable[i] = PE_enable[i];
		n_PE_s[i] = PE_s[i];
	end

	case (state)
		IDLE : begin
			n_newline = 1'b1;
			n_PE_lock = 1'b1;
		end //IDLE

		READ_ST : begin
			if(i_data_valid) begin
				n_PE_s[counter] = i_s;
				n_PE_enable[counter] = 1'd1;
				n_newline = i_t_last;
				if(i_s_last) n_s_using = counter;
			end
		end //READ_ST

		READ_T : begin
			if(i_data_valid) n_newline = i_t_last;
		end //READ_T

		FINAL_T : begin
			if(i_data_valid) begin
				if(s_using < `PE_Array_size -1) n_PE_enable[s_using +1] = 1'd0;

				for(i = 0; i < `PE_Array_size; i = i+1) begin
					if( (i > s_using) & (~PE_enable[i-1]) )n_PE_enable[i] = 1'd0;
				end
			end
		end //FINAL_T

		WAIT : begin
			n_PE_lock = 1'd0;

			n_PE_enable[0] = 1'd0;
			n_PE_enable[s_using+1] = 1'd0;
			for(i = 1; i < `PE_Array_size; i = i+1) begin
				if(~PE_enable[i-1]) n_PE_enable[i] = 1'd0;
			end
		end //WAIT

		RESULT : begin
			n_newline = 1'd1;
			n_PE_lock = 1'd1;
			n_s_using = `PE_Array_size -1;
			for(i = 0; i < `PE_Array_size; i = i+1) n_PE_enable[i] = 1'd0;
		end // RESULT
	endcase
end

always @(posedge clk or negedge rst_n) begin
	if (~rst_n) begin
		//control
		state <= IDLE;
		counter <= 0;
		first_itr <= 1'd1;

		//IO
		o_busy <= 1'd0;
		o_valid <= 1'd0;
		o_t <= 2'd0;
		o_v <= 0;
		o_f <= 0;
		o_t_valid <= 1'd0;
		t_buf <= 2'd0;
		v_buf <= 0;
		f_buf <= 0;
		v_a_buf <= 0;
		t_valid_buf <= 1'b0;
		t_valid_buf1 <= 1'b0;

		//PE
		newline <= 1'd1;
		newline_buf <= 1'd1;
		s_using <= `PE_Array_size -1;
		PE_lock <= 1'd0;

		for(i = 0; i < `PE_Array_size; i = i+1) begin
			PE_enable[i] <= 1'b0;
			PE_s[i] <= 2'd0;
		end
	end else begin
		//control
		state <= n_state;
		counter <= n_counter;
		first_itr <= n_first_itr;

		//IO
		o_busy <= n_o_busy;
		o_valid <= n_o_valid;
		o_t <= n_o_t;
		o_v <= n_o_v;
		o_f <= n_o_f;
		o_t_valid <= t_valid_buf1;
		t_buf <= i_t;
		v_buf <= i_v;
		f_buf <= i_f;
		v_a_buf <= n_v_a_buf;
		t_valid_buf1 <= t_valid_buf;
		t_valid_buf <= n_t_valid_buf;

		//PE
		newline <= n_newline;
		newline_buf <= newline;
		s_using <= n_s_using;
		PE_lock <= n_PE_lock;

		for(i = 0; i < `PE_Array_size; i = i+1) begin
			PE_enable[i] <= n_PE_enable[i];
			PE_s[i] <= n_PE_s[i];
		end
	end
end

generate
	for(idx = 0; idx < `PE_Array_size; idx = idx+1) PE PE_cell(.clk(clk), .rst(rst_n), .enable(PE_enable[idx]), 
		.lock(PE_lock), .newLineIn(PE_newline[idx]), .newLineOut(PE_newline[idx+1]), .s(PE_s[idx]), 
		.tIn(PE_t[idx]), .tOut(PE_t[idx+1]), .match(i_match), .mismatch(i_mismatch), .minusAlpha(i_minusAlpha), 
		.minusBeta(i_minusBeta), .vIn(PE_v[idx]), .vIn_alpha(PE_v_a[idx]), .fIn(PE_f[idx]), .vOut(PE_v[idx+1]), 
		.vOut_alpha(PE_v_a[idx+1]), .fOut(PE_f[idx+1]));
endgenerate

myMax64 maxTree(.clk(clk), .rst_n(rst_n), .in(PE_v_1D), .result(o_result), .init(o_valid));

generate
	for(idx = 0; idx < `PE_Array_size; idx = idx+1)
		assign PE_v_1D[`V_E_F_Bit * (idx+1) -1 : `V_E_F_Bit * idx] = PE_v[idx+1];
endgenerate

endmodule // PEArrayController
`endif