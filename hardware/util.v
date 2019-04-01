`ifdef UTIL
`else
	`define UTIL

	//input
	`define Alpha_Beta_Bit 8
	`define V_E_F_Bit  16
	`define Match_bit  8

	module myMax (
		input  [`V_E_F_Bit-1 : 0 ] a,
		input  [`V_E_F_Bit-1 : 0 ] b,
		output [`V_E_F_Bit-1 : 0 ] result
	);
		wire compare, apbp, apbn, anbn;
		assign compare = (a[`V_E_F_Bit-2:0] >= b[`V_E_F_Bit -2:0] );
		assign apbp = (~a[`V_E_F_Bit -1]) & (~b[`V_E_F_Bit -1]);
		assign apbn = (~a[`V_E_F_Bit -1]) & ( b[`V_E_F_Bit -1]);
		assign anbn = ( a[`V_E_F_Bit -1]) & ( b[`V_E_F_Bit -1]);

		assign chooseA = apbn | (apbp & compare) | (anbn & (~compare));
		assign result = chooseA ? a : b;
	
	endmodule
`endif