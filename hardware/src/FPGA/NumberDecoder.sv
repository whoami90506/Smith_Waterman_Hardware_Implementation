`ifdef NUMBERDECODER 
`else 
`define NUMBERDECODER

module NumberDecoder(
    input clk, 
    input rst_n,

    input [26:0] i_data,
    output logic [31:0] o_seven
);
integer i;
genvar idx;

logic [31:0] n_o_seven;

logic [26:0] temp [0:6];
logic [26:0] n_temp [0:6];

assign n_o_seven[3:0] = i_data % 10;
assign n_temp[0] = (i_data - o_seven[3:0])/10;

generate
	for(idx = 1; idx < 7; idx = idx +1) begin : name3
		assign n_temp[idx] = (temp[idx-1] - o_seven[4*(idx) +: 4]) / 10;
	end

	for (idx = 0; idx < 7; idx = idx +1) begin : name4
		assign n_o_seven[4*(idx+1) +: 4] = temp[idx] % 10;
	end
endgenerate

always_ff @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		o_seven <= 32'd0;
		for(i = 0; i < 7; i = i+1) begin 
			temp[i] <= 27'd0;
		end
	end else begin
		o_seven <= n_o_seven;
		for(i = 0; i < 7; i = i+1) begin 
			temp[i] <= n_temp[i];
		end
	end
end
endmodule

`endif