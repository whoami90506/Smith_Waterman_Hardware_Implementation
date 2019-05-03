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
	output reg [`Sram_Word-1:0] o_request_data,
	output reg o_request_valid,
	input i_PE_send, 
	input [`Sram_Word-1:0] i_send_data,

	//top
	input i_init,
	input i_start_read_t,
	input [7:0] i_t,
	input i_t_valid,
	output reg o_busy
);

//input output
wire [`Sram_Word-1:0] n_o_request_data;
wire n_o_request_valid, n_o_busy;

//Sram
reg CEN, n_CEN;
reg WEN, n_WEN;
reg [`Sram_Addr_log-1:0] A, n_A;
reg [`Sram_Word-1 : 0] D, n_D;

genvar idx;
generate
	for(idx = 0; idx < 32; idx = idx +1) sram_1024x8_t13 sram(.Q(n_o_request_data[8*idx+7 : 8*idx]), .CLK(clk), .CEN(CEN), 
		.WEN(WEN), .A(A), .D(D[8*idx+7 : 8*idx]));
endgenerate

//controll
reg [1:0] state , n_state;



endmodule
`endif