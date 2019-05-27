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
reg [2:0]state, n_state;
wire use_sram;

//s
reg [`PE_Array_size*4-1:0] s_mem, n_s_mem;
reg [`PE_Array_size_log +1 : 0] s_num, n_s_num;
reg s_no_more, n_s_no_more;
reg n_o_request_s;
wire [1:0] n_o_s;
reg n_o_s_last;

//t
reg [`Max_T_size_log-1 : 0] t_counter, n_t_counter;
reg [1:0] n_o_t;
reg [`V_E_F_Bit-1:0] n_o_v, n_o_f, n_o_v_a;
reg n_o_t_newline, n_o_t_enable_0;

//sram
reg [`BIT_P_GROUP * `T_per_word *2 -1 : 0] t_mem, n_t_mem;
reg [3:0] t_num, n_t_num;
reg [`Sram_Word-1:0] n_o_send_data;
reg n_o_sram_request, n_o_sram_send;
reg [2:0] t_store_num, n_t_store_num;

//queue
reg q_take, n_q_take;
reg q_store, n_q_store;
wire [`BIT_P_GROUP-1 : 0] q_take_data;
wire q_empty;

function [`BIT_P_GROUP-1 : 0] TVF_to_group;
	input [1:0] t;
	input [`V_E_F_Bit-1 : 0] v;
	input [`V_E_F_Bit-1 : 0] f;

	TVF_to_group = {t, v[`V_E_F_Bit-2 : 0], f[`V_E_F_Bit-2 : 0]};
endfunction

assign use_sram = (i_T_size > `DP_LIMIT);

// queue cache(.clk(clk), .rst_n(rst_n), .i_init(i_init), 
// 	.i_store(i_t_valid & ~(((all_valid & i_PE_update_t) & ((t_num == 0) & q_empty)))), .i_data(TVF_to_group(i_t, i_v, i_f)),
// 	.i_take(q_take_w), .o_data(q_take_data), .o_empty_w(q_empty));

endmodule
`endif//DATA_PROCESSOR