`ifdef UTIL
`else
`define UTIL

//SRAM
`define Sram_Word 256
`define Sram_Addr 1024
`define Sram_Word_log $clog2(`Sram_Word)
`define Sram_Addr_log $clog2(`Sram_Addr)
`define T_per_word 7

//PEARRAY
`define PE_Array_size 64
`define PE_Array_size_log $clog2(`PE_Array_size)

//Top
`define TOP_STATE_BIT 2

//input
`define Alpha_Beta_Bit 8
`define V_E_F_Bit 18 // 17 value + 1 signed
`define Match_bit  4 // 4 value
`define Max_T_size `Sram_Addr * `T_per_word
`define Max_T_size_log $clog2(`Max_T_size)


module myMax #(parameter DATA_WIDTH = `V_E_F_Bit)(
	input  [DATA_WIDTH-1 : 0 ] a,
	input  [DATA_WIDTH-1 : 0 ] b,
	output [DATA_WIDTH-1 : 0 ] result
);
	wire compare, apbp, apbn, anbn;
	assign compare = (a[DATA_WIDTH-2:0] >= b[DATA_WIDTH -2:0] );
	assign apbp = (~a[DATA_WIDTH -1]) & (~b[DATA_WIDTH -1]);
	assign apbn = (~a[DATA_WIDTH -1]) & ( b[DATA_WIDTH -1]);
	assign anbn = ( a[DATA_WIDTH -1]) & ( b[DATA_WIDTH -1]);

	assign chooseA = apbn | (apbp & compare);
	assign result = anbn ? {DATA_WIDTH{1'b0}} :
					chooseA ? a : b;
	
endmodule

module myMax4 #(parameter DATA_WIDTH = `V_E_F_Bit) (
	input [DATA_WIDTH-1 : 0] a,
	input [DATA_WIDTH-1 : 0] b,
	input [DATA_WIDTH-1 : 0] c,
	input [DATA_WIDTH-1 : 0] d,
	output [DATA_WIDTH-1 : 0] result
		
);
	wire [DATA_WIDTH-1 : 0] result1, result2;
	myMax #(.DATA_WIDTH(DATA_WIDTH)) m1(.a(a), .b(b), .result(result1));
	myMax #(.DATA_WIDTH(DATA_WIDTH)) m2(.a(c), .b(d), .result(result2));
	myMax #(.DATA_WIDTH(DATA_WIDTH)) mFinal(.a(result1), .b(result2), .result(result));
	
endmodule

module myMax8 #(parameter DATA_WIDTH = `V_E_F_Bit) (
	input clk,
	input rst_n,
	input [DATA_WIDTH*8 -1 : 0] in,
	output reg [DATA_WIDTH-1 : 0] result
		
);
	wire [DATA_WIDTH-1 : 0] result1, result2, n_result;
	myMax4 #(.DATA_WIDTH(DATA_WIDTH)) m1(.a(in[DATA_WIDTH-1 : 0]), .b(in[DATA_WIDTH*2-1:DATA_WIDTH]),
		.c(in[DATA_WIDTH*3-1 : DATA_WIDTH*2]), .d(in[DATA_WIDTH*4-1 : DATA_WIDTH*3]), .result(result1));
	myMax4 #(.DATA_WIDTH(DATA_WIDTH)) m2(.a(in[DATA_WIDTH*5-1 : DATA_WIDTH*4]), .b(in[DATA_WIDTH*6-1:DATA_WIDTH*5]),
		.c(in[DATA_WIDTH*7-1 : DATA_WIDTH*6]), .d(in[DATA_WIDTH*8-1 : DATA_WIDTH*7]), .result(result2));
	myMax  #(.DATA_WIDTH(DATA_WIDTH)) mFinal(.a(result1), .b(result2), .result(n_result));

	always @(posedge clk or negedge rst_n) begin :
		if(~rst_n) result <= {DATA_WIDTH{1'b0}};
		else result <= n_result;
	end
endmodule

module myMax64 #(parameter DATA_WIDTH = `V_E_F_Bit) (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [DATA_WIDTH*64 -1 : 0] in,
	output [DATA_WIDTH-1 : 0] result
);

	wire [DATA_WIDTH*8 -1 : 0] middle;

	genvar idx;
	generate
		for (idx = 0; idx < 8; idx = idx+1) 
			myMax8 #(.DATA_WIDTH(DATA_WIDTH)) layer1(.clk(clk), .rst_n(rst_n), 
				.in(in[DATA_WIDTH*(idx+1)*8-1 : DATA_WIDTH*idx*8]), .result(middle[DATA_WIDTH*(idx+1)-1 : DATA_WIDTH*idx]));
	endgenerate

	myMax8 layer2 (.clk(clk), .rst_n (rst_n), .in(middle), .result(result));

endmodule

// module sram_sp_test #(parameter WORD_WIDTH = 128, parameter ADDR_WIDTH = 11) (QA, CLKA, CENA, WENA, AA, DA);
// output reg [WORD_WIDTH-1:0] QA;   
// input                     CLKA;
// input                     CENA;
// input                     WENA;
// input      [ADDR_WIDTH-1:0] AA;
// input      [WORD_WIDTH-1:0] DA;

// localparam WIDTH = WORD_WIDTH;
// localparam DEPTH = 1 << (ADDR_WIDTH);

// reg [WIDTH-1:0] data [0:DEPTH-1];
// wire INVALIDA = AA >= DEPTH;

// always@(posedge CLKA) begin
//     QA <= ~CENA & WENA & ~INVALIDA ? data[AA] : 128'dz;
//     if(~WENA & ~CENA & ~INVALIDA) begin
//         data[AA] <= DA;
//     end
// end
// endmodule
`endif