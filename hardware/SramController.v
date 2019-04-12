`ifdef SRAM_CONTROLLER
`else
`define SRAM_CONTROLLER

`include "util.v"

module SramController (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	output reg busy,
	input init,
	input [`Max_T_bit-1:0] lenT,

	//sram
	input [`Sram_Word_Bit-1:0] readData_s, //QA
	output reg valid_s, // CENA
	output reg isWrite, //WENA
	output reg [`Sram_Addr_Bit-1:0] addr, //AA
	output reg [`Sram_Word_Bit-1:0] writeData_s, //DA
	
	//host
	input requestRead,
	output reg [`Sram_Word_Bit-1:0] readData_h,
	output reg readValid,
	input requestWrite, 
	input [`Sram_Word_Bit-1:0] writeData_h
);

//IO
wire n_busy;
wire [`Sram_Word_Bit-1:0] n_readData_h;
reg n_valid_s, n_isWrite;
reg [`Sram_Addr_Bit-1:0] n_addr;
reg [`Sram_Word_Bit-1:0] n_writeData_s, _readData_s;

//state
reg run, n_run;
reg [`Sram_Addr_Bit-1:0] readAddr, n_readAddr, writeAddr, n_writeAddr;

assign n_busy = (~run) & (addr == {`Sram_Word_Bit{1'b1}});
assign n_readData_h = _readData_s;

endmodule
`endif