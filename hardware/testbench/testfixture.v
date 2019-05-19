`timescale 1ns/1ps
`define CYCLE    20           	        // Modify your clock period here
`define TERMINATION  50000
`define ERROR_SUM 10

`include "src/top.v"
`define DATA "testbench/dat/TA"

module test;

//tb
reg clk;
reg rst_n;
integer err, stage;
reg down;

//data
reg [17:0]   t_mem   [0:`Sram_Addr-1];
reg [`PE_Array_size*2-1:0] s_mem [0:99999];
reg [23:0] param;
integer s_num_itr, s_len_itr, t_itr;
integer s_num, s_len;
integer fp_s_len, fp_param, cnt;


//top
reg set_t, start_cal, param_valid;
reg [17:0] seq_t;
reg [`PE_Array_size*2-1:0] seq_s;
reg [`PE_Array_size_log : 0] seq_s_valid;

wire busy, valid, request_s;
wire [`V_E_F_Bit-1 : 0] result;

Top top(.clk(clk), .rst_n(rst_n), .i_set_t(set_t), .i_start_cal(start_cal), .o_busy(busy), .o_result(result), .o_valid(valid), 
	.i_t(seq_t), .o_request_s(request_s), .i_s(seq_s), .i_s_valid(seq_s_valid), .i_match(param[23:20]), .i_mismatch(param[19:16]), 
	.i_minusAlpha (param[15:8]), .i_minusBeta(param[7:0]), .i_param_valid(param_valid));

initial begin
	//tb
	clk         = 1'b0;
	rst_n       = 1'b1;
	err         = 0;
	stage       = 0;  
	down        = 1'b0;

	//data
	s_num_itr = 0;
	s_len_itr = 0;
	t_itr = 0;

	//top
	set_t = 1'd0;
	start_cal = 1'd0;
	param_valid = 1'd0;
	seq_t = 18'd0;
	seq_s = {(`PE_Array_size*2){1'd0}};
	seq_s_valid = {(`PE_Array_size_log+1){1'd0}};

	@(negedge clk)rst_n = 1'b0;
	#(2* `CYCLE)  rst_n = 1'b1;

	//stage = 1
	#(0.01* `CYCLE);
	stage = 2;
	set_t = 1'd1;
end

initial begin
	$fsdbDumpfile("sw.fsdb");
	$fsdbDumpvars;
	$fsdbDumpMDA;
	
	fp_s_len = $fopen($sformatf("%s_lenS.dat", `DATA), "r");
	fp_param = $fopen($sformatf("%s_param.dat", `DATA), "r");
	cnt = $fscanf(fp_s_len, "%d\n", s_num);
	$readmemb($sformatf("%s_t.dat", `DATA), t_mem);

	$display("======================================================================");
	$display("Start simulation !");
	$display("======================================================================");
end

always @(negedge clk) begin
	set_t = 1'd0;
	start_cal = 1'd0;
	param_valid = 1'd0;
	seq_t = 18'd0;
	seq_s = {(`PE_Array_size*2){1'd0}};
	seq_s_valid = {(`PE_Array_size_log+1){1'd0}};

	case(stage)

		2 : begin //wait high busy
			seq_t = t_mem[0];
			t_itr = 1;
			if(seq_t[16:14]) stage = 4;
			else stage = 3;
		end

		3 : begin // send t
			seq_t = t_mem[t_itr];
			t_itr = t_itr +1;
			if(seq_t[16:14]) stage = 4;
		end

		4 : begin //wait busy to low
			if(~busy) stage = 5;
		end

		5 : begin //set file
			cnt = $fscanf(fp_s_len, "%d\n", s_len);
			cnt = $fscanf(fp_param, "%b\n", param);
			$readmemb($sformatf("%s_s_%0d.dat", `DATA, s_num_itr), s_mem);
			param_valid = 1'd1;
			stage = 6;
		end

		6 : begin //start calc
			down = 1'd1;
		end
	endcase
end

always  #(`CYCLE/2) clk = ~clk;

always @(*) begin 
	if(err >= `ERROR_SUM) begin
		$display("================================================================================================================");
		$display("There are more than %d errors in the code!!!", `ERROR_SUM); 
		$display("================================================================================================================");
		#`CYCLE $finish;
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

initial begin
	@(posedge down);
	if(err) begin
		$display("============================================================================");
     	$display("\n (T_T) ERROR found!! There are %d errors in total.\n", err);
        $display("============================================================================");
	end else begin
		$display("============================================================================");
        $display("\n");
        $display("        ****************************              ");
        $display("        **                        **        /|__/|");
        $display("        **  Congratulations !!    **      / O,O  |");
        $display("        **                        **    /_____   |");
        $display("        **  Simulation Complete!! **   /^ ^ ^ \\  |");
        $display("        **                        **  |^ ^ ^ ^ |w|");
        $display("        *************** ************   \\m___m__|_|");
        $display("\n");
        $display("============================================================================");
	end

	# `CYCLE $finish;
end

endmodule

