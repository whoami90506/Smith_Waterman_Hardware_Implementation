`ifdef SRAM_CONTROLLER
`else
`define SRAM_CONTROLLER

`include "util.v"

module SramController (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	output reg busy,
	input init,

	//sram host
	input [`Sram_Word_Bit-1:0] readData_s, //QA
	output valid_s, // CENA
	output isWrite, //WENA
	output reg [`Sram_Addr_Bit-1:0] addr, //AA
	output reg [`Sram_Word_Bit-1:0] writeData_s, //DA
	
);

endmodule
`endif