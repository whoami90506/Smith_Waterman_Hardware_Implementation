`ifdef SRAM_CONTROLLER
`else
`define SRAM_CONTROLLER

`include "src/util.v"
`include "Memory/sram_1024x8_t13/sram_1024x8_t13.v"

module SramController (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	//PE
	input i_PE_request,
	output reg [`Sram_Word_Bit-1:0] o_request_data,
	output reg o_request_valid,
	input i_PE_send, 
	input [`Sram_Word_Bit-1:0] i_send_data,

	//top
	input i_init,
	input i_start_read_t,
	input [7:0] i_t,
	input i_t_valid,
	output reg o_busy
);

//state
reg run, n_run;
reg [`Sram_Addr_Bit-1:0] readAddr, n_readAddr, writeAddr, n_writeAddr;
endmodule
`endif