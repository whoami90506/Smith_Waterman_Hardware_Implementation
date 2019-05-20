`ifdef DATA_PROCESSOR
`else 
`define DATA_PROCESSOR

`include "src/SramController.v"
`include "src/queue.v"
`include "src/util.v"

module DataProcessor (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	//sramController
	output reg o_sram_request,
	input [`Sram_Word-1:0] i_request_data,
	output reg o_sram_send, 
	output reg [`Sram_Word-1:0] o_send_data,
	input [`Max_T_size_log-1 : 0] i_T_size,

	//PEArrayController
	output reg o_valid,
	input i_init,

	input i_PE_update_s,
	output reg [1:0] o_s,
	output reg o_s_last,

	input i_PE_update_t,
	output reg [1:0] o_t,
	output reg [`V_E_F_Bit-1:0] o_v,
	output reg [`V_E_F_Bit-1:0] o_f,
	input i_t_valid,
	input [1:0] i_t,
	input [`V_E_F_Bit-1 : 0] i_v,
	input [`V_E_F_Bit-1 : 0] i_f,
	output reg o_t_last,

	//top
	input i_start_calc,
	output reg o_request_s,
	input [`PE_Array_size*2-1:0] i_s,
	input [`PE_Array_size_log : 0] i_s_valid
);
//IO
wire n_o_valid;


//control
reg run, n_run;
wire use_sram;
wire all_valid;

//s
wire s_valid_w;
reg [`PE_Array_size*4-1:0] s_mem, n_s_mem;
reg [`PE_Array_size_log +1 : 0] s_num, n_s_num;
reg s_no_more, n_s_no_more;
reg n_o_request_s;
wire [1:0] n_o_s;
reg n_o_s_last;

//t
reg t_valid_w;
reg [`BIT_P_GROUP * `T_per_word *2 -1 : 0] t_mem, n_t_mem;
reg [3:0] t_num, n_t_num;
reg t_first_round, n_t_first_round;
reg [`Max_T_size_log-1 : 0] t_counter, n_t_counter;
reg [1:0] n_o_t;
reg [`V_E_F_Bit-1:0] n_o_v, n_o_f;
reg n_o_t_last;
reg [`Sram_Word-1:0] n_o_send_data;
reg n_o_sram_request, n_o_sram_send;
reg [2:0] t_store_num, n_t_store_num;

//queue
reg q_store, n_q_store;
reg [`BIT_P_GROUP-1 : 0] q_store_data, n_q_store_data;
reg q_take, n_q_take;
wire [`BIT_P_GROUP-1 : 0] q_take_data;
wire q_empty;

function [`BIT_P_GROUP-1 : 0] TVF_to_group;
	input [1:0] t;
	input [`V_E_F_Bit-1 : 0] v;
	input [`V_E_F_Bit-1 : 0] f;

	TVF_to_group = {t, v[`V_E_F_Bit-2 : 0], f[`V_E_F_Bit-2 : 0]};
endfunction

assign s_valid_w = (s_num != 0);
assign use_sram = (i_T_size > `DP_LIMIT);
assign all_valid = (~i_PE_update_t | t_valid_w) & (~i_PE_update_s | s_valid_w);
assign n_o_valid = all_valid;
assign n_o_s = s_mem[`PE_Array_size*4 -1 : `PE_Array_size*4 -2];

//control
always @(*) begin
	if(run) n_run = ~i_init;
	else n_run = i_start_calc;
end

//s
always @(*) begin
	n_s_mem = s_mem;
	n_s_num = s_num;
	//n_o_request_s = o_request_s;
	n_o_s_last = o_s_last;
	n_s_no_more = s_no_more;

	if(run) begin
		n_o_request_s = (s_num < `PE_Array_size) && (i_s_valid == 0) && (~s_no_more);

		if(all_valid & i_PE_update_s) begin
			n_s_mem = s_mem << 2;

			if(i_s_valid) begin
				n_s_mem[`PE_Array_size*2 - {s_num, 1'b0} -2 +: `PE_Array_size*2] = i_s;
				n_s_num = (~i_s_valid) ? s_num + i_s_valid -1 : s_num + `PE_Array_size -1;
				n_o_s_last = 1'd0;
				n_s_no_more = ((~i_s_valid) != 0);

				
			end else begin
				n_s_num = s_num -1;
				n_o_s_last = (s_num == 1);

			end
		end else begin
			if(i_s_valid) begin
				n_s_mem[`PE_Array_size*2 - {s_num, 1'b0} +: `PE_Array_size*2] = i_s;
				n_s_num = (~i_s_valid) ? s_num + i_s_valid : s_num + `PE_Array_size;
				n_s_no_more = ((~i_s_valid) != 0);
			end
		end

	end else begin //~run
		n_s_mem = s_mem;
		n_s_num = 0;
		n_o_request_s = i_start_calc;
		n_o_s_last = 1'b0;
		n_s_no_more = 1'b0;
	end

end

//t
always @(*) begin
	n_t_mem = t_mem;
	n_t_num = t_num;
	n_t_first_round = t_first_round;
	n_t_counter = t_counter;
	n_o_t = o_t;
	n_o_v = o_v;
	n_o_f = o_f;
	n_o_t_last = o_t_last;
	n_o_sram_request = 1'd0;
	n_o_sram_send = 1'd0;
	n_o_send_data = o_send_data;
	n_t_store_num = t_store_num;

	if(run) begin
		t_valid_w = (t_num != 0);

		if(use_sram) begin
			n_o_sram_request = (t_num < `T_per_word) && (~i_request_data[`Sram_Word-1]);

			//store
			if(i_t_valid) begin
				n_o_send_data[`BIT_P_GROUP * (`T_per_word - t_store_num)-1 -: `BIT_P_GROUP] = TVF_to_group(i_t, i_v, i_f);
				n_t_store_num = (t_store_num == 6) ? 0 : t_store_num +1;
				n_o_sram_send = (t_store_num == 6);
			end

			if(i_request_data[`Sram_Word-1] & i_PE_update_t) begin
				n_o_t = t_mem[`BIT_P_GROUP * `T_per_word *2 -1 -: 2];
				n_o_v = {1'b0, t_mem[`BIT_P_GROUP * `T_per_word *2 -3 -: `V_E_F_Bit-1]};
				n_o_f = {1'b0, t_mem[`BIT_P_GROUP * `T_per_word *2  -`V_E_F_Bit-1 -3 -: `V_E_F_Bit-1]};
				n_t_mem = t_mem << `BIT_P_GROUP;

				n_t_counter = (t_counter +1 == i_T_size) ? 0 : t_counter;
				n_o_t_last = (t_counter +1 == i_T_size);
				if(t_first_round)n_t_first_round = ~(t_counter +1 == i_T_size);

				if(i_request_data[`Sram_Word-1]) begin
					n_t_mem[`BIT_P_GROUP * (`T_per_word *2 - t_num-1) -1 -: `BIT_P_GROUP * `T_per_word] = i_request_data[`Sram_Word-5 : 0]; 
					n_t_num = i_request_data[`Sram_Word-2 -: 3] ? t_num + i_request_data[`Sram_Word-2 -: 3] -1 : t_num + 7 -1;
				end else begin // no new data
					n_t_num = t_num -1;
				end
			end else begin //no update data
				if(i_request_data[`Sram_Word-1]) begin
					n_t_mem[`BIT_P_GROUP * (`T_per_word *2 - t_num) -1 -: `BIT_P_GROUP * `T_per_word] = i_request_data[`Sram_Word-5 : 0];
					n_t_num = i_request_data[`Sram_Word-2 -: 3] ? t_num + i_request_data[`Sram_Word-2 -: 3]: t_num + 7;
				end
			end


		end else begin // ~use_sram

		end
	end else begin//~run
		t_valid_w = 1'd0;
		n_t_num = 0;
		n_t_first_round = 1'd1;
		n_t_counter = 0;
		n_o_t_last = 1'd0;
		n_t_store_num = 0;

	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		//IO
		o_valid <= 1'b0;

		//cotrol
		run <= 1'b0;

		//s
		s_mem <= {(`PE_Array_size*4){1'd0}};
		s_num <= 0;
		o_request_s <= 1'd0;
		o_s <= 2'd0;
		o_s_last <= 1'b0;
		s_no_more <= 1'b0;

		//t
		t_mem <= {(`BIT_P_GROUP * `T_per_word *2){1'd0}};
		t_num <= 4'd0;
		t_first_round <= 1'b1;
		t_counter <= 0;
		o_t <= 2'd0;
		o_v <= 0;
		o_f <= 0;
		o_t_last <= 1'd0;
		o_send_data <= {(`Sram_Word){1'd0}};
		o_sram_request <= 1'b0;
		o_sram_send <= 1'b0;
		t_store_num <= 3'd0;
	end else begin
		 
	end
end

queue cache(.clk(clk), .rst_n(rst_n), .i_init(i_init), 
	.i_store(q_store), .i_data(q_store_data), .i_take(q_take), .o_data(q_take_data), .o_empty_w(q_empty));

endmodule
`endif//DATA_PROCESSOR