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
	output reg o_lock,
	input i_init,

	output reg [`PE_Array_size*2-1:0] o_s,
	output reg o_s_last,
	output reg [`PE_Array_size_log-1 : 0] o_s_addr,

	output reg [1:0] o_t,
	output reg [`V_E_F_Bit-1:0] o_v,
	output reg [`V_E_F_Bit-1:0] o_v_a,
	output reg [`V_E_F_Bit-1:0] o_f,
	output reg o_t_newline,
	output reg o_enable_0,

	input i_t_valid,
	input [1:0] i_t,
	input [`V_E_F_Bit-1 : 0] i_v,
	input [`V_E_F_Bit-1 : 0] i_f,

	//top
	input i_start_calc,
	output reg o_busy,
	output reg o_request_s,
	input [`PE_Array_size*2-1:0] i_s,
	input [`PE_Array_size_log : 0] i_s_valid
);

//control
localparam IDLE   = 3'd0;
localparam RUN_S  = 3'd1;
localparam RUN_C1 = 3'd2;
localparam RUN_C2 = 3'd3;
localparam END    = 3'd4;
reg [2:0] state, n_state;
reg n_o_busy;
wire use_sram;
wire data_end;

//s
reg [`PE_Array_size*4-1:0] s_mem, n_s_mem;
reg [`PE_Array_size_log +1 : 0] s_num, n_s_num;
reg [`PE_Array_size_log-1 : 0] n_o_s_addr;
reg s_no_more, n_s_no_more;
reg n_o_request_s;
reg [`PE_Array_size*2-1:0] n_o_s;
reg n_o_s_last;

//t
reg [`Max_T_size_log-1 : 0] t_counter, n_t_counter;
reg [1:0] n_o_t;
reg [`V_E_F_Bit-1:0] n_o_v, n_o_f, n_o_v_a;
reg n_o_t_newline, n_o_t_enable_0, n_o_lock;

//sram
reg [`BIT_P_GROUP * `T_per_word *2 -1 : 0] t_mem, n_t_mem;
reg [3:0] t_num, n_t_num;
reg [`Sram_Word-1:0] n_o_send_data;
reg n_o_sram_request, n_o_sram_send;
reg [2:0] t_store_num, n_t_store_num;

//cache
reg [`BIT_P_GROUP-1 : 0]   cache [0 : 15];
reg [`BIT_P_GROUP-1 : 0] n_cache [0 : 15];
reg [3:0] cache_read_addr, n_cache_read_addr;
reg [3:0] cache_write_addr, n_cache_write_addr;
wire cache_empty;

function [`BIT_P_GROUP-1 : 0] TVF_to_group;
	input [1:0] t;
	input [`V_E_F_Bit-1 : 0] v;
	input [`V_E_F_Bit-1 : 0] f;

	TVF_to_group = {t, v[`V_E_F_Bit-2 : 0], f[`V_E_F_Bit-2 : 0]};
endfunction

assign use_sram = (i_T_size > `DP_LIMIT);
assign data_end = o_s_last & s_no_more & (t_counter == i_T_size);
assign cache_empty = (cache_read_addr == cache_write_addr);

//control
always @(*) begin
	n_o_busy = 1'd1;

	case (state)
		IDLE : begin
			if(i_start_calc) n_state = use_sram ? RUN_S : RUN_C1;
			else n_state = IDLE;

			n_o_busy = i_start_calc;
		end

		RUN_C1 : begin
			if(t_counter == i_T_size) n_state = data_end ? END : RUN_C2;
			else n_state = RUN_C2;
		end
		
		RUN_S, RUN_C2 : n_state = data_end ? END : state;
		END : n_state = i_init ? IDLE : END;
		default : n_state = 3'dx;
	endcase
end

//s
always @(*) begin
	case (state)
	
		//IDLE
		default : begin
			n_s_mem = {(`PE_Array_size*4){1'b0}};
			n_s_num = 0;
			n_o_s_addr = 0;
			n_s_no_more = 1'b0;
			n_o_request_s = 1'b0;
			n_o_s = {(`PE_Array_size*2){1'b0}};
			n_o_s_last = 1'b0;
		end
	endcase
end
endmodule
`endif//DATA_PROCESSOR