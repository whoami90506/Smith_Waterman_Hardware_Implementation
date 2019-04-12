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
	output reg isRead, //WENA
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
reg n_valid_s, n_isRead, n_busy, n_readValid;
reg [`Sram_Addr_Bit-1:0] n_addr;
reg [`Sram_Word_Bit-1:0] _readData_s, n_readData_h;
wire [`Sram_Word_Bit-1:0] n_writeData_s;

//state
reg run, n_run;
reg [`Sram_Addr_Bit-1:0] readAddr, n_readAddr, writeAddr, n_writeAddr;

assign n_writeData_s = writeData_h;

always @(*) begin
	if(~run) begin
		//state
		n_run = (addr == {`Sram_Addr_Bit{1'd1}} );
		n_readAddr = `Sram_Addr_Bit'd0;
		n_writeAddr = `Sram_Addr_Bit'd0;

		//IO
		n_busy = (addr != {`Sram_Addr_Bit{1'd1}} );
		n_valid_s = (addr == {`Sram_Addr_Bit{1'd1}} );
		n_isRead = 1'd0;
		n_addr = addr + `Sram_Addr_Bit'd1;
		n_readData_h = `Sram_Word_Bit'd0;
		n_readValid = 1'd0;
	end else begin
		if(init) begin
			//state
			n_run = 1'd0;
			n_readAddr = `Sram_Addr_Bit'd0;
			n_writeAddr = `Sram_Addr_Bit'd0;

			//IO
			n_busy = 1'd1;
			n_valid_s = 1'd0;
			n_isRead = 1'd0;
			n_addr = `Sram_Addr_Bit'd0;
			n_readData_h = `Sram_Word_Bit'd0;
			n_readValid = 1'd0;
		end else begin
			n_run = 1'd1;
			n_busy = 1'd0;
			n_readValid = 1'd0;
			n_readAddr = `Sram_Addr_Bit'd0;
			n_writeAddr = `Sram_Addr_Bit'd0;

			//IO
			n_valid_s = 1'd0;
			n_isRead = 1'd0;
			n_addr = `Sram_Addr_Bit'd0;
			n_readData_h = `Sram_Word_Bit'd0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		//IO
		busy <= 1'd1;
		valid_s <= 1'd0;
		isRead <= 1'd0;
		addr <= `Sram_Addr_Bit'd0;
		writeData_s <= `Sram_Word_Bit'd0;
		readData_h <= `Sram_Word_Bit'd0;
		readValid <= 1'd0;
		_readData_s <= `Sram_Word_Bit'd0;

		//state
		run <= 1'b0;
		readAddr <= `Sram_Addr_Bit'd0;
		writeAddr <= `Sram_Addr_Bit'd0;

	end else begin
		//IO
		busy <= n_busy;
		valid_s <= n_valid_s;
		isRead <= n_isRead;
		addr <= n_addr;
		writeData_s <= n_writeData_s;
		readData_h <= n_readData_h;
		readValid <= n_readValid;
		_readData_s <= readData_s;

		//state
		run <= n_run;
		readAddr <= n_readAddr;
		writeAddr <= n_writeAddr;
	end
end

endmodule
`endif