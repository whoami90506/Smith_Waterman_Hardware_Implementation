`ifdef SRAM_CONTROLLER
`else
`define SRAM_CONTROLLER

`include "src/util.v"

`ifdef STANDARD_SRAM
`include "Memory/sram_1024x8_t13/sram_1024x8_t13.v"
`endif

module SramController (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	//DataProcessor
	input i_PE_request,
	output reg [`Sram_Word-1:0] o_request_data,
	input i_PE_send, 
	input [`Sram_Word-1:0] i_send_data,
	output reg [`Max_T_size_log-1 : 0] o_T_size,
	input i_init,
	
	//top
	input i_start_read_t,
	input [17:0] i_t,
	output reg o_busy
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

`ifdef STANDARD_SRAM
generate
	for(idx = 0; idx < 32; idx = idx +1) sram_1024x8_t13 sram(.Q(Q[8*idx+7 : 8*idx]), .CLK(clk), .CEN(CEN), 
		.WEN(WEN), .A(A), .D(D[8*idx+7 : 8*idx]));
endgenerate
`else 
sram_sp_test sram(.QA(Q), .CLKA(clk), .CENA(CEN), .WENA(WEN), .AA(A), .DA(D));
`endif

//control
localparam IDLE = 3'd0;
localparam SETT = 3'd1;
localparam INIT_READ = 3'd4;
localparam INIT_TEMP = 3'd5;
localparam INIT_WRITE = 3'd6;

reg [2:0] state , n_state;
reg [`HEADER_BIT-1 : 0] header, n_header;
reg [1:0] isRequesting, n_isRequesting;

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

function [`Sram_Word-1 : 0 ] word_reset;
	input [`Sram_Word-1:0] in;
	word_reset = {in[255:252], in[251:250], 34'd0, in[215:214], 34'd0, in[179:178], 34'd0, in[143:142], 34'd0,
	 						   in[107:106], 34'd0, in[ 71: 70], 34'd0, in[ 35: 34], 34'd0};
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
	n_o_request_data = 0;
	n_o_busy = 1'd0;

	case (state)
		IDLE : begin
			if(i_init | i_start_read_t) begin
				if(i_init) begin
					//controll
					n_state = INIT_READ;
					n_isRequesting = 2'd0;

					//Sram && addr
					SramRead({`Sram_Addr_log{1'd0}});
					n_readAddr = {`Sram_Addr_log{1'd0}};
					n_writeAddr = {`Sram_Addr_log{1'd0}};

					//IO
					n_o_busy = 1'd1;
				end else begin //i_start_read_t
					n_isRequesting = 1'd0;
					n_readAddr = {`Sram_Addr_log{1'd0}};
					n_writeAddr = {`Sram_Addr_log{1'd0}};
					n_o_busy = 1'd1;

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

				//control
				if(isRequesting)n_isRequesting = (isRequesting == 2'd3) ? 2'd0 : isRequesting + 2'd1;

				if(i_PE_send) begin
					if(writeAddr == dataAddr) begin
						SramWrite(writeAddr, {header, i_send_data[`Sram_Word - `HEADER_BIT -1 : 0]});
						n_writeAddr = 0;
					end else begin
						SramWrite(writeAddr, {1'd1, {(`HEADER_BIT-1){1'd0}}, i_send_data[`Sram_Word - `HEADER_BIT -1 : 0]});
						n_writeAddr = (writeAddr == dataAddr) ? 0 : writeAddr+1;
					end
					
				end else if (i_PE_request & isRequesting == 2'd0) begin
					SramRead(readAddr);
					n_readAddr = (readAddr == dataAddr) ? 0 : readAddr +1;
					n_isRequesting = 2'd1;
				end

				if(isRequesting == 2'd2) n_o_request_data = Q;
			end
		end //IDLE

		SETT : begin
			n_o_busy = 1'd1;

			if(i_t[17]) begin //i_start_read_t valid
				SramWrite(dataAddr, T_to_word(i_t));

				if(i_t[16:14]) begin //last
					//control
					n_state = IDLE;
					n_header = i_t[17:14];

					//Sram addr
					n_o_T_size = o_T_size + i_t[16:14];

					//IO
					n_o_busy = 1'd0;
				end else begin  //not last
					
					if(dataAddr == {`Sram_Addr_log{1'b1}} ) begin // full
						SramWrite(dataAddr, T_to_word(i_t) | {4'b111, {(`Sram_Word -4){1'b0}}});

						n_state = IDLE;
						n_header = 4'b1111;
						n_o_T_size = o_T_size + `T_per_word;
						n_o_busy = 1'd0;
					end else begin
						n_dataAddr = dataAddr +1;
						n_o_T_size = o_T_size + `T_per_word;
					end
				end
			end
		end //SETT

		INIT_READ : begin
			//controll
			n_state = INIT_TEMP;
			n_isRequesting = 2'd0;

			//Sram && addr
			SramNop;

			//IO
			n_o_busy = 1'd1;
		end//INIT_READ

		INIT_TEMP : begin
			//control
			n_state = (readAddr == dataAddr) ? IDLE : INIT_WRITE;
			n_isRequesting = 2'd0;

			//Sram && addr
			SramWrite(readAddr, word_reset(Q));
			n_readAddr = (readAddr == dataAddr) ? 0 : readAddr +1;

			//IO
			n_o_busy = (readAddr != dataAddr);
		end //INIT_TEMP

		INIT_WRITE : begin 
			//control
			n_state = INIT_READ;
			n_isRequesting = 2'd0;

			//Sram && addr
			SramRead(readAddr);

			//IO
			n_o_busy = 1'b1;
		end

		default : begin
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
			n_o_request_data = 0;
			n_o_busy = 1'd0;
		end
		
	endcase

end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		//control
		state <= IDLE;
		isRequesting <= 2'd0;
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
		state <= n_state;
		isRequesting <= n_isRequesting;
		header <= n_header;
		readAddr <= n_readAddr;
		writeAddr <= n_writeAddr;
		dataAddr <= n_dataAddr;

		//input output
		o_request_data <= n_o_request_data;
		o_busy <= n_o_busy;
		o_T_size <= n_o_T_size;

		//Sram
		CEN <= n_CEN;
		WEN <= n_WEN;
		A <= n_A;
		D <= n_D;
	end
end
endmodule
`endif