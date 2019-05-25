`ifdef QUEUE
`else
`define QUEUE

`include "src/util.v"

module queue (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input i_init,

	input i_store,
	input [`BIT_P_GROUP-1 : 0] i_data,
	input i_take,
	output reg [`BIT_P_GROUP -1 : 0] o_data,
	output o_empty_w
);

integer i;
genvar idx;

//IO
reg [`BIT_P_GROUP-1 : 0] n_o_data;
wire [`BIT_P_GROUP-1 : 0] nr_o_data;

//contorl
reg [`QUEUE_SIZE_LOG-1 : 0] r_addr, n_r_addr;
reg [`QUEUE_SIZE_LOG-1 : 0] w_addr, n_w_addr;
wire [`QUEUE_SIZE_LOG-1 : 0] nr_r_addr, nr_w_addr;

//mem
reg [`BIT_P_GROUP-1 : 0] mem [0 : `QUEUE_SIZE -1];
reg [`BIT_P_GROUP-1 : 0] n_mem [0 : `QUEUE_SIZE -1];
wire [`BIT_P_GROUP-1 : 0] nr_mem [0 : `QUEUE_SIZE -1];

//store
always @(*) begin
	for(i = 0; i < `QUEUE_SIZE; i = i+1)n_mem[i] = mem[i];

	n_w_addr = i_store ? w_addr +1 : w_addr;
	if(i_store)n_mem[w_addr] = i_data;
end

//take
always @(*) begin
	n_r_addr = i_take ? r_addr+1 : r_addr;
	n_o_data = o_data;
	
	if(i_take)n_o_data = (i_store & (r_addr+1 == w_addr))  ? i_data : mem[r_addr+1];
end

assign o_empty_w = (r_addr == w_addr);
assign nr_o_data = i_init ? {`BIT_P_GROUP{1'b0}} : n_o_data;
assign nr_r_addr = i_init ? 0 : n_r_addr;
assign nr_w_addr = i_init ? 0 : n_w_addr;
generate
	for(idx = 0; idx < `QUEUE_SIZE; idx = idx +1)assign nr_mem[idx] = i_init ? {`BIT_P_GROUP{1'b0}} : n_mem[idx];
endgenerate

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		 o_data <= {`BIT_P_GROUP{1'b0}};
		 r_addr <= 0;
		 w_addr <= 0;
		 for(i = 0; i < `QUEUE_SIZE; i = i +1)mem[i] <= {`BIT_P_GROUP{1'b0}};
	end else begin
		 o_data <= nr_o_data;
		 r_addr <= nr_r_addr;
		 w_addr <= nr_w_addr;
		 for(i = 0; i < `QUEUE_SIZE; i = i +1)mem[i] <= nr_mem[i];
	end
end

endmodule
`endif //QUEUE