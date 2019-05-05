`timescale 1ns/10ps
`define CYCLE    20           	        // Modify your clock period here
`define TERMINATION  5000
`define SEQUENCE "testbench/sram_t01.dat"

`include "src/SramController.v"

module test;


reg clk;
reg reset;
reg i_PE_request, i_PE_send;
reg [`Sram_Word-1 : 0] i_send_data;
reg i_init, i_start_read_t;
reg [17:0] i_t;

wire [`Sram_Word-1 : 0] o_request_data;
wire o_busy;
wire [`Max_T_size_log-1 : 0] o_T_size;

SramController Top(.clk(clk), .rst_n(reset), .i_PE_request(i_PE_request), .o_request_data(o_request_data), 
	.i_PE_send(i_PE_send), .i_send_data(i_send_data), .i_init(i_init), .i_start_read_t(i_start_read_t), 
	.i_t(i_t), .o_busy(o_busy), .o_T_size(o_T_size));

integer num, err, stage;
integer i;
reg [17:0]   t_mem   [0:`Sram_Addr-1];
reg [`Sram_Word-1 : 0] idx;

initial	$readmemh (`SEQUENCE, t_mem);

initial begin
$fsdbDumpfile("sram.fsdb");
$fsdbDumpvars;
$fsdbDumpMDA;
end

initial begin
   clk         = 1'b0;
   reset       = 1'b1;
   err         = 0;
   stage       = 0; 
   idx         = 0; 
   num         = 0; 
   i           = 0;

   i_PE_request = 1'd0;
   i_PE_send = 1'd0;
   i_send_data = 0;
   i_init = 1'd0;
   i_start_read_t = 1'd0;
   i_t = 18'd0;

   @(negedge o_busy);
   stage = 1;
   $display("=======");
   $display("STAGE 1");
   $display("=======");
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
   @(negedge clk)reset = 1'b0;
   #2* `CYCLE    reset = 1'b1;
   # `CYCLE;
   @(posedge clk)i_start_read_t = 1'b1;
   @(posedge clk)i_start_read_t = 1'b0;
                                  
end  


always @(posedge clk) begin
	if(o_busy) begin
		i_t = t_mem[num];
		num = num +1;
	end
end

function [`Sram_Word-1 : 0]T_to_ans;
	input [17:0] in;
	T_to_ans = {in[17:14], in[13:12], idx, idx, in[11:10], idx, idx, in[9:8], idx, idx, in[7:6], idx, idx,
	 in[5:4], idx, idx, in[3:2], idx, idx, in[1:0], idx, idx};
endfunction

always @(posedge clk) begin
	if(stage == 1) begin
		i_PE_request = 1'd1;

		if(o_request_data[`Sram_Word-1]) begin
			if(o_request_data != T_to_ans(t_mem[i])) begin
				$display("ERROR at %d: t_in %h, get %h ", i, t_mem[i], o_request_data);
				err = err +1;
			end
			i = i+1;

			if(i == num) begin
				i = 0;
				i_PE_request = 1'd0;
				$finish;
			end
		end

	end
end

initial begin
	#(`TERMINATION * `CYCLE);
	$display("================================================================================================================");
	$display("(/`n`)/ ~#  There is something wrong with your code!!"); 
	$display("Time out!! The simulation didn't finish after %d cycles!!, Please check it!!!", `TERMINATION); 
	$display("================================================================================================================");
	#`CYCLE $finish;
end

endmodule

