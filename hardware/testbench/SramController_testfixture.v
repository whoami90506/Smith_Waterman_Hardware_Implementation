`timescale 1ns/10ps
`define CYCLE    20           	        // Modify your clock period here
`define TERMINATION  50000
`define SEQUENCE

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


integer i, j, k, l, err;

reg   [2:0]   cmd_mem   [0:CMD_N_PAT-1];

SramController Top(.clk(clk), .rst_n(reset), .i_PE_request(i_PE_request), .o_request_data(o_request_data), 
	.i_PE_send(i_PE_send), .i_send_data(i_send_data), .i_init(i_init), .i_start_read_t(i_start_read_t), 
	.i_t(i_t), .o_busy(o_busy), .o_T_size(o_T_size));

//initial $sdf_annotate(`SDFFILE, top);
initial	$readmemh (`CMD,    cmd_mem);
initial	$readmemh (`EXPECT, out_mem);

initial begin
$fsdbDumpfile("sram.fsdb");
$fsdbDumpvars;
$fsdbDumpMDA;
end

initial begin
   clk         = 1'b0;
   reset       = 1'b0;
   over	       = 1'b0;
   l	       = 0;
   err         = 0;   
end

always begin #(`CYCLE/2) clk = ~clk; end

initial begin
   @(negedge clk)  reset = 1'b1;
   #t_reset        reset = 1'b0;
                                  
end  


always @(negedge clk)
begin

	begin
	if (l < CMD_N_PAT)
	begin
		if(!busy) 
		begin
        	cmd = cmd_mem[l];
        	cmd_valid = 1'b1;
		l=l+1;
		end  
		else
		cmd_valid = 1'b0;
	end
	else
	l=l;
	end
end


initial @(posedge done) 
begin
   for(k=0;k<64;k=k+1)begin
         if( IRB_1.mem[k] !== out_mem[k]) 
		begin
         	$display("ERROR at %d:output %h !=expect %h ",k, IRB_1.mem[k], out_mem[k]);
         	err = err+1 ;
		end
         else if ( out_mem[k] === 8'dx)
                begin
                $display("ERROR at %d:output %h !=expect %h ",k, IRB_1.mem[k], out_mem[k]);
		err=err+1;
                end   
 over=1'b1;
end
        begin
	if (err === 0 &&  over===1'b1  )  begin
	            $display("All data have been generated successfully!\n");
	            $display("-------------------PASS-------------------\n");
		    #10 $finish;
	         end
	         else if( over===1'b1 )
		 begin 
	            $display("There are %d errors!\n", err);
	            $display("---------------------------------------------\n");
		    #10 $finish;
         	 end
	
	end
end

endmodule

