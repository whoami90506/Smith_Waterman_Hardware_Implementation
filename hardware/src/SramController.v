`ifdef SRAM_CONTROLLER
`else
`define SRAM_CONTROLLER

`include "src/util.v"
`include "Memory/sram_1024x8_t13/sram_1024x8_t13.v"

module SramController (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	//PE
	input i_PE_request,
	output reg [`Sram_Word-1:0] o_request_data,
	input i_PE_send, 
	input [`Sram_Word-1:0] i_send_data,

	//top
	input i_init,
	input i_start_read_t,
	input [17:0] i_t,
	output reg o_busy,
	output reg [`Max_T_size_log-1 : 0] o_T_size
);

//input output
reg [`Sram_Word-1:0] n_o_request_data;
reg n_o_busy;
reg [`Max_T_size_log-1 : 0] n_o_T_size;

//Sram
wire [`Sram_Word-1 : 0] Q; 
reg CEN, n_CEN;
reg WEN, n_WEN;
reg [`Sram_Addr_log-1:0] A, n_A;
reg [`Sram_Word-1 : 0] D, n_D;

genvar idx;
generate
	for(idx = 0; idx < 32; idx = idx +1) sram_1024x8_t13 sram(.Q(Q[8*idx+7 : 8*idx]), .CLK(clk), .CEN(CEN), 
		.WEN(WEN), .A(A), .D(D[8*idx+7 : 8*idx]));
endgenerate

//control
localparam IDLE = 2'd0;
localparam SETT = 2'd1;
localparam INIT_READ = 2'd2;
localparam INIT_WRITE = 2'd3;

reg [1:0] state , n_state;
reg [`HEADER_BIT-1 : 0] header, n_header;
reg isRequesting, n_isRequesting;

//addr
reg [`Sram_Addr_log-1 : 0] readAddr, writeAddr, dataAddr, n_readAddr, n_writeAddr, n_dataAddr;

task SramRead;
	input [`Sram_Addr_log-1 : 0] addr;
	begin
		n_CEN = 1'd0;
		n_WEN = 1'd1;
		n_A = addr;
		n_D = D;
	end
endtask

task SramWrite;
	input [`Sram_Addr_log-1 : 0] addr;
	input [`Sram_Word-1 : 0] data;
	begin
		n_CEN = 1'd0;
		n_WEN = 1'd0;
		n_A = addr;
		n_D = data;
	end
endtask

task SramNop;
	begin
		n_CEN = 1'd1;
		n_WEN = 1'd1;
		n_A = A;
		n_D = D;
	end
endtask

function [`Sram_Word-1 : 0 ] T_to_word;
	input [17:0] in;
	T_to_word = {in[17:14], in[13:12], {((`V_E_F_Bit -1)*2){1'd0}}, in[11:10], {((`V_E_F_Bit -1)*2){1'd0}}, 
					  in[ 9: 8], {((`V_E_F_Bit -1)*2){1'd0}}, in[ 7: 6], {((`V_E_F_Bit -1)*2){1'd0}}, 
					  in[ 5: 4], {((`V_E_F_Bit -1)*2){1'd0}}, in[ 3: 2], {((`V_E_F_Bit -1)*2){1'd0}},
					  in[ 1: 0], {((`V_E_F_Bit -1)*2){1'd0}}};
endfunction

always @(*) begin

	//controll
	n_state = state;
	n_header = header;
	n_isRequesting = isRequesting;

	//sram && addr
	SramNop;
	n_readAddr = readAddr;
	n_writeAddr = writeAddr;
	n_dataAddr = dataAddr;
	n_o_T_size = o_T_size;

	//IO
	n_o_request_data = o_request_data;
	n_o_busy = 1'd0;

	case (state)
		IDLE : begin
			if(i_init | i_start_read_t) begin
				if(i_init) begin
					//controll
					n_state = INIT_READ;
					n_isRequesting = 1'd0;

					//Sram && addr
					SramRead({`Sram_Addr_log{1'd0}});
					n_readAddr = {`Sram_Addr_log{1'd0}};
					n_writeAddr = {`Sram_Addr_log{1'd0}};

					//IO
					n_o_request_data = 1'd0;
					n_o_busy = 1'd1;

				end else begin //i_start_read_t
					n_isRequesting = 1'd0;
					n_readAddr = {`Sram_Addr_log{1'd0}};
					n_writeAddr = {`Sram_Addr_log{1'd0}};

					if(i_t[17]) begin //i_start_read_t valid
						if(i_t[16:14]) begin //last
							//control
							n_state = IDLE;
							n_header = i_t[17:14];

							//Sram addr
							SramWrite({`Sram_Word{1'd0}}, T_to_word(i_t));
							n_dataAddr = {`Sram_Addr_log{1'd0}};
							n_o_T_size = i_t[16:14];

							//IO
							n_o_busy = 1'd0;

						end else begin  //not last
							//control
							n_state = SETT;
							n_header = 0;

							//Sram addr
							SramWrite(0, T_to_word(i_t));
							n_dataAddr = 1;
							n_o_T_size = (`T_per_word);

							//IO
							n_o_busy = 1'd1;

						end
					end else begin  //i_start_read_t not valid

						//controll
						n_state = SETT;
						n_header = 0;

						//Sram && addr
						SramNop;
						n_o_T_size = 0;
						n_dataAddr = 0;

						//IO
						n_o_busy = 1'd1;				
					end
				end
			end else begin //normal read write

			end

		end
		
	endcase

end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		//control
		state <= IDLE;
		isRequesting <= 1'd0;
		header <= 4'd8;
		readAddr <= 0;
		writeAddr <= 0;
		dataAddr <= 0;

		//input output
		o_request_data <= 0;
		o_busy <= 1'b0;
		o_T_size <= 0;

		//Sram
		CEN <= 1'b1;
		WEN <= 1'b1;
		A <= 0;
		D <= 0;

	end else begin
	end
end
endmodule
`endif