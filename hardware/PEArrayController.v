`ifdef PE_ARRAY_CONTROLLER
`else
`define PE_ARRAY_CONTROLLER

`include "PEArray.v"

module PEArrayController (
	input clk,    // Clock
	input rst_n  // Asynchronous reset active low
	
);
`endif