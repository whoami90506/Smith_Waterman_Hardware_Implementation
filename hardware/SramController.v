`ifdef SRAM_CONTROLLER
`else
`define SRAM_CONTROLLER

`include "util.v"

module SramController (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	output reg busy,

	//sram
	input [`Sram_Word_Bit-1:0] readData_s, //QA
	output reg valid_s, // CENA
	output reg isRead_s, //WENA
	output reg [`Sram_Addr_Bit-1:0] addr_s, //AA
	output reg [`Sram_Word_Bit-1:0] writeData_s, //DA
	
	//host
	input requestRead_h,
	output reg [`Sram_Word_Bit-1:0] readData_h,
	output reg readValid_h,
	input requestWrite_h, 
	input [`Sram_Word_Bit-1:0] writeData_h,

	//main get T
	input [`User_Bit_Width-1:0] tIn,
	input [`User_Bit_Width_Log:0] tEnable
);

sram_sp_test #(.WORD_WIDTH(`Sram_Word_Bit), .ADDR_WIDTH(`Sram_Addr_Bit)) sram 
	(.QA  (readData_s), .CLKA(clk), .CENA(valid_s), .WENA(isRead_s), .AA  (addr_s), .DA  (writeData_s));

//IO
reg n_valid_s, n_isRead_s, n_busy, n_readValid_h;
reg [`Sram_Addr_Bit-1:0] n_addr_s;
reg [`Sram_Word_Bit-1:0] _readData_s, n_readData_h, n_writeData_s;

//state
reg run, n_run;
reg [`Sram_Addr_Bit-1:0] readAddr, n_readAddr, writeAddr, n_writeAddr;
endmodule
`endif