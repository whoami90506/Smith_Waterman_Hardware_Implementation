`timescale 1ns/1ps
`define CYCLE    20.0           	        // Modify your clock period here
`define TERMINATION  50000

`include "src/FPGAWrapper.v"

module testfixture_fpga ();
//control
reg down;

//top
reg clk, rst_n;
reg set_t, start;
reg [15:0] param;
wire valid, busy;
wire[`V_E_F_Bit-1:0] result;

//mem
reg [15:0] param_mem [0:1];

FPGAWrapper top(.clk(clk), .rst_n(rst_n), .i_set_t(set_t), 
	.i_start_cal(start), .o_busy(busy), .o_result(result), .o_valid(valid), 
	.i_match(param[15:12]), .i_mismatch(param[11:8]), .i_minusAlpha(param[7:4]), .i_minusBeta(param[3:0]));

initial begin
	clk = 1'b0;
	rst_n = 1'b1;
	down = 1'b0;

	set_t = 1'b0;
	start = 1'b0;
	param = 16'b0;

	//reset
	@(negedge clk); rst_n = 1'b0;
	#(`CYCLE * 3.0); rst_n = 1'b1;

	//set t
	$display("[%t] start set t\n",$realtime() );
	set_t = 1'b1;
	#(`CYCLE); set_t = 1'b0;
	
	#(`CYCLE);  wait(busy == 0);
	$display("[%t] finish set t\n",$realtime() );

	//start1
	@(negedge clk); param = param_mem[0];
	#(`CYCLE); start = 1'b1;
	$display("[%t] start first calculation\n",$realtime() );
	#(`CYCLE); start = 1'b0;

	wait(valid); $display("[%t] result : %d\n",$realtime() , result);
	wait(busy == 0); $display("[%t] finish first calculation\n",$realtime() );

	//start2
	@(negedge clk); param = param_mem[1];
	#(`CYCLE); start = 1'b1;
	$display("[%t] start second calculation\n",$realtime() );
	#(`CYCLE); start = 1'b0;

	wait(valid); $display("[%t] result : %d\n",$realtime() , result);
	wait(busy == 0); $display("[%t] finish second calculation\n",$realtime() );

	down = 1'b1;
end

initial begin
	$timeformat(-9, 2, "ns", 20);

	$fsdbDumpfile("sw_fpga.fsdb");
	$fsdbDumpvars;
	$fsdbDumpMDA;
	
	$readmemh($sformatf("%s_param.dat", `DATA), param_mem);

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

	# `CYCLE $finish;
end
endmodule