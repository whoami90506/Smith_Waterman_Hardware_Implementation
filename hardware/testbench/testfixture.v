`timescale 1ns/1ps
`define CYCLE    5.0           	        // Modify your clock period here
`define TERMINATION  50000000

`include "src/util.v"

`ifdef SYN
	`define SDF
	`define SDFFILE "syn/SmithWaterman_syn.sdf"
`endif

module testfixture ();
//control
reg clk, rst_n;
reg down;
reg is_set_t, n_is_set_t;
reg prev_press;

//top
reg set_t, start;
reg [15:0] param;
wire valid, busy;
wire[`V_E_F_Bit-1:0] result;
wire top_request_s;
reg [`PE_Array_size_log : 0] s_data_valid, n_s_data_valid;

//mem
reg  [15:0] param_mem [0:1];
reg  [17:0] t_mem [0:1023];
reg [127:0] s_mem [0: 255];
reg  [15:0] s_total;

//wrappper
reg   [9:0] t_addr, n_t_addr;
reg   [7:0] s_addr, n_s_addr;
reg  [14:0] s_num,  n_s_num;
reg  [17:0] t_data, n_t_data;
reg [127:0] s_data, n_s_data;

SmithWaterman u_SmithWaterman(.clk(clk), .rst_n(rst_n), .i_set_t(set_t), .i_start_cal(start), .o_busy(busy), 
	.o_result(result), .o_valid(valid), .o_request_s (top_request_s), .i_t(t_data), .i_s(s_data), .i_s_valid(s_data_valid), 
	.i_match(param[15:12]), .i_mismatch(param[11:8]), .i_minusAlpha(param[7:4]), .i_minusBeta(param[3:0]));

initial begin
	clk = 1'b1;
	rst_n = 1'b1;
	down = 1'b0;

	set_t = 1'b0;
	start = 1'b0;
	param = 16'b0;

	//reset
	@(negedge clk); rst_n = 1'b0;
	#(`CYCLE * 3.0); rst_n = 1'b1;

	//set t
	#(`CYCLE);
	set_t = 1'b1;
	$display("[%t] start set t",$realtime() );
	#(`CYCLE); set_t = 1'b0;
	
	#(`CYCLE);  wait(busy == 0);
	$display("[%t] finish set t",$realtime() );

	//start1
	@(negedge clk); param = param_mem[0];
	#(`CYCLE); start = 1'b1;
	$display("[%t] start first calculation",$realtime() );
	#(`CYCLE); start = 1'b0;

	wait(valid); $display("[%t] result : %d",$realtime() , result);
	wait(busy == 0); $display("[%t] finish first calculation",$realtime() );

	//start2
	@(negedge clk); param = param_mem[1];
	#(`CYCLE); start = 1'b1;
	$display("[%t] start second calculation",$realtime() );
	#(`CYCLE); start = 1'b0;

	wait(valid); $display("[%t] result : %d",$realtime() , result);
	wait(busy == 0); $display("[%t] finish second calculation",$realtime() );

	down = 1'b1;
end

//s
always @(*) begin
	if(busy) begin
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
		n_is_set_t = busy | prev_press;
		n_t_addr = t_addr + 1;
		n_t_data = t_mem[t_addr];
	end else begin
		n_is_set_t = set_t;
		n_t_addr = 0;
		n_t_data = 0;
	end
end

always @(negedge clk or negedge rst_n) begin
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
		prev_press <= set_t;

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

initial begin
	$timeformat(-9, 2, " ns", 17);

	$fsdbDumpfile("sw.fsdb");
	$fsdbDumpvars;
	$fsdbDumpMDA;

	`ifdef SDF
	$sdf_annotate(`SDFFILE, u_SmithWaterman);
	`endif
	
	$readmemh($sformatf("%s_param.dat", `DATA), param_mem);
	$readmemb(`DATA_s,s_mem);
	$readmemb(`DATA_t,t_mem);
	s_total = `DATA_S_TOTAL;

	$display("======================================================================");
	$display("Start simulation !");
	$display("======================================================================");
end

always  #(`CYCLE/2.0) clk = ~clk;

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
	$display("============================================================================");
    // $display("\n");
    // $display("        ****************************              ");
    // $display("        **                        **        /|__/|");
    // $display("        **  Congratulations !!    **      / O,O  |");
    // $display("        **                        **    /_____   |");
    // $display("        **  Simulation Complete!! **   /^ ^ ^ \\  |");
    // $display("        **                        **  |^ ^ ^ ^ |w|");
    // $display("        *************** ************   \\m___m__|_|");
    // $display("\n");
    // $display("============================================================================");

	# `CYCLE $finish;
end
endmodule