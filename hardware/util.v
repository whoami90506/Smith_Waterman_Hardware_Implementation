`ifdef UTIL
`else
	`define UTIL

	//input
	`define Alpha_Beta_Bit 8
	`define V_E_F_Bit  16
	`define Match_bit  8

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

		assign chooseA = apbn | (apbp & compare) | (anbn & (~compare));
		assign result = chooseA ? a : b;
	
	endmodule
`endif