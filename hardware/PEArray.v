`ifdef PEARRAY
`else
`define PEARRAY

`include "PE.v"

module PEArray (
	input clk,    // Clock
	input rst_n  // Asynchronous reset active low
	
);

//IO
reg [`V_E_F_Bit-1:0] minusAlpha_r, minusBeta_r, match_r, mismatch_r, minusAlpha_w, minusBeta_w, match_w, mismatch_w;

//PE======================================
//transport line
wire PE_newline [0:`ARRAY_LENGTH];
wire [1:0] PE_t [0:`ARRAY_LENGTH];
wire [`V_E_F_Bit-1:0] PE_v [0:`ARRAY_LENGTH];
wire [`V_E_F_Bit-1:0] PE_v_alpha [0:`ARRAY_LENGTH];
wire [`V_E_F_Bit-1:0] PE_f [0:`ARRAY_LENGTH];

//reg
reg [1:0] PE_s [0:`ARRAY_LENGTH-1];
reg [1:0] n_PE_s [0:`ARRAY_LENGTH-1];

generate
	genvar idx;
	for (idx = 0; idx < `ARRAY_LENGTH; idx = idx+1) begin : PEArray
		PE PE_idx (.clk(clk), .rst(rst_n), .newLineIn(PE_newline[idx]), .newLineOut(PE_newline[idx+1]),
			.s(PE_s[idx]), .tIn(PE_t[idx]), .tOut(PE_t[idx+1]), .vIn(PE_v[idx]), .vOut(PE_v[idx+1]),
			.vIn_alpha(PE_v_alpha[idx]), .vOut_alpha(PE_v_alpha[idx+1]), .fIn(PE_f[idx]),
			.fOut(PE_f[idx+1]), .minusAlpha(minusAlpha_r), .minusBeta (minusBeta_r), .match(match_r), .mismatch(mismatch_r));

	end
endgenerate

// PE PE [0: `ARRAY_LENGTH-1 ] (.clk(clk), .rst(rst_n), .newLineIn(PE_newline[0:`ARRAY_LENGTH-1]), .newLineOut(PE_newline[1:`ARRAY_LENGTH]),
// 	.s(PE_s), .tIn(PE_t[0:`ARRAY_LENGTH-1]), .tOut(PE_t[1:`ARRAY_LENGTH]), .vIn(PE_v[0:`ARRAY_LENGTH-1]), .vOut(PE_v[1:`ARRAY_LENGTH]),
// 	.vIn_alpha(PE_v_alpha[0:`ARRAY_LENGTH-1]), .vOut_alpha(PE_v_alpha[1:`ARRAY_LENGTH]), .fIn(PE_f[0:`ARRAY_LENGTH-1]),
// 	.fOut(PE_f[1:`ARRAY_LENGTH]), .minusAlpha(minusAlpha_r), .minusBeta (minusBeta_r), .match(match_r), .mismatch(mismatch_r));

endmodule
`endif