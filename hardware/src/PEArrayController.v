`ifdef PE_ARRAY_CONTROLLER
`else
`define PE_ARRAY_CONTROLLER

`include "src/PE.v"

module PEArrayController (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//S & T
	output reg requestS,
	input [`PE_Array_size*2-1:0] sIn,
	input [`PE_Array_size-1:0] sValid,
	input sLast,
	output reg requestT,
	input [`PE_Array_size*2-1:0] tIn,
	input [`PE_Array_size-1:0] tValid,
	input tLast,

	//parameter
	input [`V_E_F_Bit-1:0] match,
	input [`V_E_F_Bit-1:0] mismatch,
	input [`V_E_F_Bit-1:0] minusAlpha,
	input [`V_E_F_Bit-1:0] minusBeta,

	//sram
	output reg readSram,
	input [`Sram_Word_Bit-1:0] readData,
	input readValid,
	output reg writeSram,
	output reg [`Sram_Word_Bit-1:0] writeData,

	//output
	output reg [`V_E_F_Bit-1:0] result,
	output reg outValid
);
endmodule // PEArrayController
`endif