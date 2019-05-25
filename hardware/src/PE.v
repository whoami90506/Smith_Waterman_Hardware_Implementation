`ifdef PE
`else 
`define PE
`include "src/util.v"

module PE(clk, rst, enable, lock, newLineIn, newLineOut, s, tIn, tOut, vIn, vIn_alpha, vOut, vOut_alpha, fIn, fOut, minusAlpha, minusBeta, match, mismatch);

//Input & Output
input clk;
input rst;
input enable;
input lock;
input newLineIn;
output reg newLineOut;

input [1:0] s, tIn;
output reg  [1:0] tOut;
input [`V_E_F_Bit-1 : 0] minusAlpha, minusBeta, mismatch;
input [`Match_bit-1 :0] match;

input [`V_E_F_Bit-1 : 0 ] vIn, vIn_alpha, fIn;
output reg [`V_E_F_Bit-1 : 0] vOut, vOut_alpha, fOut;

//memory
reg [`V_E_F_Bit-1 : 0] vDiag, preE;

//next
reg n_newLineOut;
reg [1:0] n_tOut;
reg [`V_E_F_Bit-1:0] n_vOut, n_vOut_alpha, n_fOut, n_vDiag, n_preE;

//diag
wire [`V_E_F_Bit-1 : 0] LUT, vDiag_real, diag;
assign LUT = (s == tIn) ? match : mismatch;
assign vDiag_real = newLineIn ? {`V_E_F_Bit{1'b0}} : vDiag;
assign diag = vDiag_real + LUT;

//up
wire [`V_E_F_Bit-1 : 0] preE_real, E_beta, eOut, vOut_alpha_real;
assign preE_real = newLineIn ? {`V_E_F_Bit{1'b0}} : preE;
assign E_beta = preE_real + minusBeta;
assign vOut_alpha_real = newLineIn ? minusAlpha : vOut_alpha;
myMax calE(.a(E_beta), .b(vOut_alpha_real), .result(eOut));

//left
wire [`V_E_F_Bit-1 : 0] fIn_alpha, fResult, fIn_beta;
assign fIn_beta = fIn + minusBeta;
myMax calF(.a(vIn_alpha), .b(fIn_beta), .result(fResult));

//compute v
wire [`V_E_F_Bit-1 : 0] posDiag, maxEF, result;
myMax4 ans(.a(diag), .b(eOut), .c(fResult), .d(`V_E_F_Bit'b0), .result(result));

//next reg
always @(*) begin
	if(enable) begin
		if(lock) begin
			n_newLineOut = newLineOut;
			n_tOut = tOut;
			n_fOut = fOut;
			n_vOut = vOut;
			n_vOut_alpha = vOut_alpha;
			n_vDiag = vDiag;
			n_preE = preE;
		end else begin
			n_newLineOut = newLineIn;
			n_tOut = tIn;
			n_fOut = fResult;
			n_vOut = result;
			n_vOut_alpha = result + minusAlpha;
			n_vDiag = vIn;
			n_preE = eOut;
		end
	end else begin
		n_newLineOut = 1'd0;
		n_tOut = 2'd0;
		n_fOut = `V_E_F_Bit'd0;
		n_vOut = `V_E_F_Bit'd0;
		n_vOut_alpha = `V_E_F_Bit'd0;
		n_vDiag = `V_E_F_Bit'd0;
		n_preE = `V_E_F_Bit'd0;
	end

end

always @(posedge clk or negedge rst) begin
	if(~rst) begin
		//IO
		 newLineOut <= 1'd0;
		 tOut <= 2'd0;
		 fOut <= {`V_E_F_Bit{1'b0}};
		 vOut <= {`V_E_F_Bit{1'b0}};
		 vOut_alpha <= {`V_E_F_Bit{1'b0}};
		 //memory 
		 vDiag <= {`V_E_F_Bit{1'b0}};
		 preE <= {`V_E_F_Bit{1'b0}};
	end else begin
		//IO
		 newLineOut <=  n_newLineOut;
		 tOut <= n_tOut;
		 fOut <= n_fOut;
		 vOut <= n_vOut;
		 vOut_alpha <= n_vOut_alpha;
		 //memory
		 vDiag <= n_vDiag;
		 preE <= n_preE;

	end
end

endmodule // PE
`endif