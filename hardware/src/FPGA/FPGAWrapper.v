`ifdef FPGA_WRAPPER
`else
`define FPGA_WRAPPER

`include "src/top.v"

module FPGAWrapper (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low

	//user
	input i_set_t,
	input i_start_cal,
	output o_busy,
	output [`V_E_F_Bit-1:0] o_result,
	output o_valid,

	input [`Match_bit-1 : 0] i_match,
	input [`Match_bit-1 : 0] i_mismatch,
	input [`Alpha_Beta_Bit-1:0] i_minusAlpha,
	input [`Alpha_Beta_Bit-1:0] i_minusBeta
);

//control
reg is_set_t, n_is_set_t;
reg prev_press;

//mem
reg  [17:0] t_mem [0:1023];
reg [127:0] s_mem [0: 255];
reg  [15:0] s_total;

reg   [9:0] t_addr, n_t_addr;
reg   [7:0] s_addr, n_s_addr;
reg  [14:0] s_num,  n_s_num;
reg  [17:0] t_data, n_t_data;
reg [127:0] s_data, n_s_data;

//top
wire top_request_s;
reg [`PE_Array_size_log : 0] s_data_valid, n_s_data_valid;

//read
integer file_s_len;

initial begin
	$readmemb($sformatf("%s_s.dat",`DATA),s_mem);
	$readmemb($sformatf("%s_t.dat",`DATA),t_mem);
	file_s_len = $fopen($sformatf("%s_s_len.dat",`DATA),"r");
	while (!$feof(file_s_len)) $fscanf(file_s_len, "%d\n", s_total);
	$fclose(file_s_len);
end

//s
always @(*) begin
	if(o_busy) begin
		if(top_request_s && s_data_valid == 0) begin
			n_s_addr = (s_num <= 64) ? 0 : s_addr +1;
			n_s_data = s_mem[s_addr];
			n_s_num  = (s_num <= 64) ? s_total : s_num - 64;
			n_s_data_valid = (s_num <= 64) ? s_num : {(`PE_Array_size_log+1){1'b1}};
		end else begin
			n_s_addr = s_addr;
			n_s_num = s_num;
			n_s_data = 128'b0;
			n_s_data_valid = 0;
		end

	end else begin
		n_s_addr = 0;
		n_s_num  = s_total;
		n_s_data = 0;
		n_s_data_valid = 0;
	end

end

//t
always @(*) begin
	if(is_set_t) begin
		n_is_set_t = o_busy | prev_press;
		n_t_addr = t_addr + 1;
		n_t_data = t_mem[t_addr];
	end else begin
		n_is_set_t = i_set_t;
		n_t_addr = 0;
		n_t_data = 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		//control
		prev_press <= 1'b0;
		//s
		s_addr <= 0;
		s_num  <= s_total;
		s_data <= 0;
		s_data_valid <= 0;

		//t
		is_set_t <= 1'b0;
		t_addr <= 0;
		t_data <= 0;
	end else begin
		//control
		prev_press <= i_set_t;

		//s
		s_addr <= n_s_addr;
		s_num  <= n_s_num;
		s_data <= n_s_data;
		s_data_valid <= n_s_data_valid;

		//t
		is_set_t <= n_is_set_t;
		t_addr <= n_t_addr;
		t_data <= n_t_data;
	end
end

Top top(.clk(clk), .rst_n(rst_n), .i_set_t(i_set_t), .i_start_cal(i_start_cal), .o_busy(o_busy), .o_result(o_result), 
	.o_valid(o_valid), .o_request_s (top_request_s), .i_t(t_data), .i_s(s_data), .i_s_valid(s_data_valid), 
	.i_match(i_match), .i_mismatch(i_mismatch), .i_minusAlpha(i_minusAlpha), .i_minusBeta(i_minusBeta));

endmodule
`endif