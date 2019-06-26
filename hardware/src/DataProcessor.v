`ifdef DATA_PROCESSOR
`else 
`define DATA_PROCESSOR

`include "src/SramController.v"
`include "src/util.v"

module DataProcessor (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	
	//sramController
	output reg o_sram_request,
	input [`Sram_Word-1:0] i_request_data,
	output reg o_sram_send, 
	output reg [`Sram_Word-1:0] o_send_data,
	input [`Max_T_size_log-1 : 0] i_T_size,
	output reg o_sram_init,

	//PEArrayController
	output reg o_lock,
	input i_init,
	input i_finish,

	output reg [`PE_Array_size*2-1:0] o_s,
	output reg o_s_last,
	output reg [`PE_Array_size_log-1 : 0] o_s_addr,

	output reg [1:0] o_t,
	output reg [`V_E_F_Bit-1:0] o_v,
	output reg [`V_E_F_Bit-1:0] o_v_a,
	output reg [`V_E_F_Bit-1:0] o_f,
	output reg o_t_newline,
	output reg o_t_enable_0,

	input i_t_valid,
	input [1:0] i_t,
	input [`V_E_F_Bit-1 : 0] i_v,
	input [`V_E_F_Bit-1 : 0] i_f,

	//top
	input i_start_calc,
	output reg o_busy,
	output reg o_request_s,
	input [`PE_Array_size*2-1:0] i_s,
	input [`PE_Array_size_log : 0] i_s_valid,
	input [`V_E_F_Bit-1 : 0] i_minusA
);
integer i;

//control
localparam IDLE          = 3'd0;
localparam SRAM_ST       = 3'd1;
localparam SRAM_T        = 3'd2;
localparam CACHE_INIT_ST = 3'd3;
localparam CACHE_INIT_T  = 3'd4;
localparam CACHE_ST      = 3'd5;
localparam CACHE_T       = 3'd6;
localparam END           = 3'd7;
reg [2:0] state, n_state;
reg need_init_sram, n_need_init_sram;
reg n_o_busy;
wire use_sram_w;
wire t_nxt_last_w, s_nxt_last_w;
wire s_empty_w;
reg t_empty_w;
reg valid_w;

//s
reg [`PE_Array_size*4-1:0] s_mem, n_s_mem;
reg [`PE_Array_size_log +1 : 0] s_num, n_s_num;
reg [`PE_Array_size_log-1 : 0] n_o_s_addr;
reg s_no_more, n_s_no_more;
reg n_o_request_s;
reg [`PE_Array_size*2-1:0] n_o_s;
reg n_o_s_last;

//t
reg [`Max_T_size_log-1 : 0] t_counter, n_t_counter;
reg [1:0] n_o_t;
reg [`V_E_F_Bit-1:0] n_o_v, n_o_f, n_o_v_a;
reg n_o_t_newline, n_o_t_enable_0, n_o_lock;

//sram
reg [`BIT_P_GROUP * `T_per_word *2 -1 : 0] t_sram_mem, n_t_sram_mem;
reg [3:0] t_sram_PE_num, n_t_sram_PE_num;
reg [`Sram_Word-1:0] n_o_send_data;
reg n_o_sram_request, n_o_sram_send;
reg [2:0] t_store_num, n_t_store_num;
reg [`Max_T_size_log-1 : 0] t_store_counter, n_t_store_counter;
reg n_o_sram_init;

//cache
reg [`BIT_P_GROUP-1 : 0]   cache [0 : 15];
reg [`BIT_P_GROUP-1 : 0] n_cache [0 : 15];
reg [3:0] cache_read_addr, n_cache_read_addr;
reg [3:0] cache_write_addr, n_cache_write_addr;
wire cache_empty_w;

assign use_sram_w = (i_T_size > `DP_LIMIT);
assign t_nxt_last_w = (t_counter+2 == i_T_size);
assign s_nxt_last_w = (s_num <= 1) && s_no_more;
assign cache_empty_w = (cache_read_addr == cache_write_addr);
assign s_empty_w = (s_num == 0) && (~s_no_more);

//control
always @(*) begin
	n_o_busy = 1'd1;
	n_o_sram_init = 1'b0;
	n_need_init_sram = need_init_sram;

	case (state)
		IDLE : begin
			n_o_busy = i_start_calc;
			n_need_init_sram = 1'b0;
			t_empty_w = 1'b0;
			valid_w = 1'b0;

			if(i_start_calc) n_state = use_sram_w ? SRAM_ST : CACHE_INIT_ST;
			else n_state = IDLE;
		end

		//len(T) > 64
		SRAM_ST : begin
			t_empty_w = (t_sram_PE_num == 0);
			valid_w = (~s_empty_w) & (~t_empty_w);

			n_state = (valid_w && (s_nxt_last_w || (o_s_addr == `PE_Array_size-2) ) ) ? SRAM_T : SRAM_ST;
		end

		//len(T) > 64
		SRAM_T : begin
			t_empty_w = (t_sram_PE_num == 0);
			valid_w = (~t_empty_w);

			n_o_sram_init = valid_w & t_nxt_last_w & o_s_last & need_init_sram;
			if(need_init_sram)n_need_init_sram = 1'b1;
			else n_need_init_sram = valid_w & t_nxt_last_w;

			if(valid_w & t_nxt_last_w) n_state = o_s_last ? END : SRAM_ST;
			else n_state = SRAM_T;
		end

		END : begin
			t_empty_w = 1'b0;
			valid_w   = 1'b0;

			n_state = i_finish ? IDLE : END;
			n_need_init_sram = 1'b0;
		end

		default : begin
			t_empty_w = 1'b1;
			valid_w = 1'b0;

			n_state = IDLE;
		end
	endcase
end

//s
always @(*) begin
	n_o_s = o_s;
	n_s_mem = s_mem;
	n_s_num = s_num;
	n_o_s_addr = o_s_addr;
	n_s_no_more = s_no_more;
	n_o_request_s = 1'b0;
	n_o_s_last = o_s_last;

	case (state)
		IDLE : begin
			n_s_num = 0;
			n_o_s_addr = {`PE_Array_size_log{1'b1}};
			n_s_no_more = 1'b0;
			n_o_s_last = 1'b0;
		end

		SRAM_ST : begin
			case ({valid_w, (i_s_valid != 0)})
				2'b11 : begin
					if(o_s_addr != 6'd63) n_o_s[2*(o_s_addr+6'd1) +: 2] = s_mem[(`PE_Array_size*4 -1) -: 2];
					else n_o_s[1:0] = s_mem[(`PE_Array_size*4 -1) -: 2];
					n_s_mem = s_mem << 2;
					n_s_mem[ (`PE_Array_size*2 - s_num +1)*2 -1 -: `PE_Array_size*2] = i_s;
					n_s_num = (~i_s_valid) ? s_num + i_s_valid -1 : s_num + `PE_Array_size -1;
					n_o_s_addr = o_s_addr+1;
					n_s_no_more = (~i_s_valid) ? 1'b1 : 1'b0;
					n_o_s_last = 1'b0;
				end
				2'b10 : begin
					if(o_s_addr != 6'd63) n_o_s[2*(o_s_addr+6'd1) +: 2] = s_mem[(`PE_Array_size*4 -1) -: 2];
					else n_o_s[1:0] = s_mem[(`PE_Array_size*4 -1) -: 2];
					n_s_mem = s_mem << 2;
					n_s_num = s_num -1;
					n_o_s_addr = o_s_addr+1;
					n_o_request_s = (s_num < `PE_Array_size) && (~s_no_more);
					n_o_s_last = s_nxt_last_w;
				end
				2'b01 : begin
					n_s_mem[ (`PE_Array_size*2 - s_num)*2 -1 -: `PE_Array_size*2] = i_s;
					n_s_num = (~i_s_valid) ? s_num + i_s_valid : s_num + `PE_Array_size;
					n_s_no_more = (~i_s_valid) ? 1'b1 : 1'b0;
					n_o_s_last = 1'b0;
				end
				2'b00 : begin
					n_o_request_s = (s_num < `PE_Array_size) && (~s_no_more);
					n_o_s_last = s_nxt_last_w;
				end
			endcase
		end//SRAM_ST

		SRAM_T : begin
			if(i_s_valid) begin
				n_s_mem[ (`PE_Array_size*2 - s_num)*2 -1 -: `PE_Array_size*2] = i_s;
				n_s_num = (~i_s_valid) ? s_num + i_s_valid[`PE_Array_size_log-1 : 0] : s_num + `PE_Array_size;
				n_s_no_more = (~i_s_valid) ? 1'b1 : 1'b0;
				n_o_s_last = 1'b0;

			end else begin
				n_o_request_s = (s_num < `PE_Array_size) && (~s_no_more);
				n_o_s_last = s_nxt_last_w;
			end
		end //SRAM_T

		//END need nothing
	endcase
end

//t to PE
always @(*) begin
	n_t_counter = t_counter;
	n_o_t = o_t;
	n_o_v = o_v;
	n_o_v_a = o_v_a;
	n_o_f = o_f;
	n_o_t_newline = 1'd0;
	n_o_t_enable_0 = 1'd1;
	n_o_lock = 1'd0;

	n_t_sram_mem = t_sram_mem;
	n_t_sram_PE_num = t_sram_PE_num;
	n_o_sram_request = 1'b0;

	n_cache_read_addr = cache_read_addr;

	case (state)
		SRAM_ST, SRAM_T : begin
			if(valid_w) begin
				n_t_counter = (t_counter >= i_T_size -1) ? 0 : t_counter +1;
				n_o_t   = t_sram_mem[`BIT_P_GROUP * `T_per_word * 2 -1 -: 2];
				n_o_v   = {1'b0, t_sram_mem[`BIT_P_GROUP * `T_per_word * 2 -3 -: `V_E_F_Bit-1]};
				n_o_v_a = {1'b0, t_sram_mem[`BIT_P_GROUP * `T_per_word * 2 -3 -: `V_E_F_Bit-1]} + i_minusA;
				n_o_f   = {1'b0, t_sram_mem[`BIT_P_GROUP * `T_per_word * 2 - `V_E_F_Bit -2 -: `V_E_F_Bit-1]};
				n_o_t_newline = (t_counter +1 >= i_T_size);

				n_t_sram_mem = t_sram_mem << `BIT_P_GROUP;
				n_t_sram_PE_num = t_sram_PE_num - 4'd1;
				n_o_sram_request = (t_sram_PE_num < `T_per_word + 4'd1); 

				if(i_request_data[`Sram_Word-1]) begin
					n_t_sram_mem[`BIT_P_GROUP * (2 * `T_per_word - t_sram_PE_num +1)-1 -: `BIT_P_GROUP * `T_per_word] = i_request_data[0 +: `BIT_P_GROUP * `T_per_word];
					n_t_sram_PE_num = (i_request_data[`Sram_Word-2 -: `HEADER_BIT-1]) ?  
						t_sram_PE_num + {1'b0, i_request_data[`Sram_Word-2 -: `HEADER_BIT-1]} - 4'd1 : 
						t_sram_PE_num + `T_per_word - 4'd1;
					n_o_sram_request = 1'b0;
				end

			end else begin
				n_o_lock = 1'd1;
				n_o_sram_request = (t_sram_PE_num < `T_per_word + 4'd1);

				if(i_request_data[`Sram_Word-1]) begin
					n_t_sram_mem[`BIT_P_GROUP * (2 * `T_per_word - t_sram_PE_num)-1 -: `BIT_P_GROUP * `T_per_word] = i_request_data[0 +: `BIT_P_GROUP * `T_per_word];
					n_t_sram_PE_num = (i_request_data[`Sram_Word-2 -: `HEADER_BIT-1]) ?  
						t_sram_PE_num + {1'b0, i_request_data[`Sram_Word-2 -: `HEADER_BIT-1]} : 
						t_sram_PE_num + `T_per_word;
					n_o_sram_request = 1'b0;
				end
			end
		end

		END : begin
			n_o_t_enable_0 = 1'b0;
			n_cache_read_addr = 4'd0;
		end
	
		//IDLE
		default : begin
			n_t_counter = {`Max_T_size_log{1'b1}};
			n_o_t_enable_0 = 1'd0;
			n_o_lock = 1'd1;

			n_t_sram_PE_num = 4'd0;
			n_o_sram_request = 1'b0;

			n_cache_read_addr = 4'd0;

		end
	endcase
end

//t to sram/cache
always @(*) begin
	n_o_send_data = o_send_data;
	n_o_sram_send = 1'b0;
	n_t_store_num = t_store_num;
	n_t_store_counter = t_store_counter;

	n_cache_write_addr = cache_write_addr;
	for(i = 0; i < 16; i = i+1)n_cache[i] = cache[i];

	case (state)
		SRAM_ST, SRAM_T : begin
			if(i_t_valid) begin
				n_o_send_data[(`BIT_P_GROUP * (`T_per_word - t_store_num))-1 -: `BIT_P_GROUP] = {i_t, i_v[`V_E_F_Bit-2 : 0], i_f[`V_E_F_Bit-2 : 0]};
				n_o_sram_send = (t_store_num == `T_per_word -1 || t_store_counter == i_T_size -1);
				n_t_store_counter = (t_store_counter == i_T_size -1) ? 0 : t_store_counter + 1;
				n_t_store_num = (t_store_num == `T_per_word -1 || t_store_counter == i_T_size -1) ? 3'd0 : t_store_num + 3'd1;
			end
		end
	
		//IDLE END
		default : begin
			n_t_store_num = 3'd0;
			n_t_store_counter = 0;

			n_cache_write_addr = 4'd0;
		end
	endcase

end

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		//control
		state <= IDLE;
		o_busy <= 1'd0;
		need_init_sram <= 1'b0;

		//s
		s_mem <= {(`PE_Array_size*4){1'b0}};
		s_num <= 0;
		o_s_addr <= {`PE_Array_size_log{1'b1}};
		s_no_more <= 1'b0;
		o_request_s <= 1'b0;
		o_s <= {(`PE_Array_size*2){1'b0}};
		o_s_last <= 1'b0;

		//t
		t_counter <= {`Max_T_size_log{1'b1}};
		o_t <= 2'd0;
		o_v <= 0;
		o_f <= 0;
		o_v_a <= 0;
		o_t_newline <= 1'd0;
		o_t_enable_0 <= 1'd0;
		o_lock <= 1'd1;

		//sram
		t_sram_mem <= {(`BIT_P_GROUP * `T_per_word *2){1'b1}};
		t_sram_PE_num <= 4'd0;
		o_send_data <= {(`Sram_Word){1'b1}};
		o_sram_request <= 1'b0;
		o_sram_send <= 1'b0;
		t_store_num <= 3'd0;
		t_store_counter <= 0;
		o_sram_init <= 1'b0;

		//cache
		for(i = 0; i < 16; i = i +1)cache[i] <= {(`BIT_P_GROUP){1'b1}};
		cache_read_addr <= 0;
		cache_write_addr <= 0;

	end else begin
		//control
		state <= n_state;
		o_busy <= n_o_busy;
		need_init_sram <= n_need_init_sram;

		//s
		s_mem <= n_s_mem;
		s_num <= n_s_num;
		o_s_addr <= n_o_s_addr;
		s_no_more <= n_s_no_more;
		o_request_s <= n_o_request_s;
		o_s <= n_o_s;
		o_s_last <= n_o_s_last;

		//t
		t_counter <= n_t_counter;
		o_t   <= n_o_t;
		o_v   <= n_o_v;
		o_f   <= n_o_f;
		o_v_a <= n_o_v_a;
		o_t_newline  <= n_o_t_newline;
		o_t_enable_0 <= n_o_t_enable_0;
		o_lock <= n_o_lock;

		//sram
		t_sram_mem <= n_t_sram_mem;
		t_sram_PE_num <= n_t_sram_PE_num;
		o_send_data <= n_o_send_data;
		o_sram_request <= n_o_sram_request;
		o_sram_send <= n_o_sram_send;
		t_store_num <= n_t_store_num;
		t_store_counter <= n_t_store_counter;
		o_sram_init <= n_o_sram_init;

		//cache
		for(i = 0; i < 16; i = i +1)cache[i] <= n_cache[i];
		cache_read_addr <= n_cache_read_addr;
		cache_write_addr <= n_cache_write_addr;
	end
end
endmodule
`endif//DATA_PROCESSOR