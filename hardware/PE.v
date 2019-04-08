`ifdef PE
`else 
`define PE
`include "util.v"

module PE(clk, rst, newLineIn, newLineOut, s, tIn, tOut, vIn, vIn_alpha, vOut, vOut_alpha, fIn, fOut, minusAlpha, minusBeta, match, mismatch);

//Input & Output
input clk;
input rst;
input newLineIn;
output reg newLineOut;

input [1:0] s, tIn;
output reg  [1:0] tOut;
input [`V_E_F_Bit-1 : 0] minusAlpha, minusBeta, match, mismatch;

input [`V_E_F_Bit-1 : 0 ] vIn, vIn_alpha, fIn;
output reg [`V_E_F_Bit-1 : 0] vOut, vOut_alpha, fOut;

//memory
reg [`V_E_F_Bit-1 : 0] vDiag_reg, preE;

//diag
wire [`V_E_F_Bit-1 : 0] LUT, vDiag_real, diag;
assign LUT = (s == tIn) ? match : mismatch;
assign vDiag_real = newLineIn ? {`V_E_F_Bit{1'b0}} : vDiag_reg;
assign diag = vDiag_real + LUT;

//up
wire [`V_E_F_Bit-1 : 0] preE_real, E_beta, eOut;
assign preE_real = newLineIn ? {`V_E_F_Bit{1'b0}} : preE;
assign E_beta = preE_real + minusBeta;
myMax calE(.a(E_beta), .b(vOut_alpha), .result(eOut));

//left
wire [`V_E_F_Bit-1 : 0] fIn_alpha, n_fOut, fIn_beta;
assign fIn_beta = fIn + minusBeta;
myMax calF(.a(vIn_alpha), .b(fIn_beta), .result(n_fOut));

//compute v
wire [`V_E_F_Bit-1 : 0] posDiag, maxEF, n_vOut, n_vOut_alpha;
myMax4 ans(.a(diag), .b(eOut), .c(n_fOut), .d(`V_E_F_Bit'b0), .result(n_vOut));
assign n_vOut_alpha = n_vOut + minusAlpha;

always @(posedge clk or negedge rst) begin
	if(~rst) begin
		//IO
		 newLineOut <= 1'd0;
		 tOut <= 2'd0;
		 fOut <= {`V_E_F_Bit{1'b0}};
		 vOut <= {`V_E_F_Bit{1'b0}};
		 vOut_alpha <= {`V_E_F_Bit{1'b0}};
		 //memory
		 vDiag_reg <= {`V_E_F_Bit-1{1'b0}};
		 preE <= {`V_E_F_Bit{1'b0}};
	end else begin
		//IO
		 newLineOut <= newLineIn;
		 tOut <= tIn;
		 fOut <= n_fOut;
		 vOut <= n_vOut;
		 vOut_alpha <= n_vOut_alpha;
		 //memory
		 vDiag_reg <= vIn;
		 preE <= eOut;

	end
end

endmodule // PE
`endif