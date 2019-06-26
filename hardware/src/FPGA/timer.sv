`ifdef TIMER 
`else 
`define TIMER

`include "src/FPGA/NumberDecoder.sv"

module timer(
	input clk, 
	input rst_n,

	input i_start,
	input i_end,

	output [31:0] o_seven
);

logic run, n_run;
logic [26:0] counter, n_counter;

NumberDecoder nd(.clk(clk), .rst_n(rst_n), .i_data(counter), .o_seven(o_seven));

always_comb begin
	if(run) begin
		n_run = ~i_end;
		n_counter = i_end ? counter : counter + 27'd1;
		
	end else begin
		n_run = i_start;
		n_counter = i_start ? 27'd1 : counter;
	end

end

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		run <= 1'b0;
		counter <= 27'd0;
	end else begin
		run <= n_run;
		counter <= n_counter;
	end
end
endmodule

`endif