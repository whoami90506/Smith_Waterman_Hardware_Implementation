`ifdef DATA_PROCESSOR
`else 
`define DATA_PROCESSOR

`include "src/SramController.v"
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
	output reg [`PE_Array_size*2-1:0] o_s,
	output reg o_s_last,

	input i_PE_update_t,
	output reg [1:0] o_t,
	output reg [`V_E_F_Bit-1:0] o_v,
	output reg [`V_E_F_Bit-1:0] o_f,
	input [1:0] i_t,
	input [`V_E_F_Bit-1 : 0] i_v,
	input [`V_E_F_Bit-1 : 0] i_f,
	output reg o_t_last,

	//top
	output reg o_request_s,
	input [`PE_Array_size*2-1:0] i_s,
	input [`PE_Array_size_log : 0] i_s_valid
);

endmodule

`endif//DATA_PROCESSOR