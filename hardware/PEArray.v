`ifdef PEARRAY
`else
`define PEARRAY

`include "PE.v"

module PEArray2 (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [1:0] enable,
	input newLineIn,
	output newLineOut,
	input [3:0] s,
	input [1:0] tIn,
	output [1:0] tOut,
	input [`V_E_F_Bit-1:0] vIn,
	output [`V_E_F_Bit-1:0] vOut,
	input [`V_E_F_Bit-1:0] vIn_alpha,
	output [`V_E_F_Bit-1:0] vOut_alpha,
	input [`V_E_F_Bit-1:0] fIn,
	output [`V_E_F_Bit-1:0] fOut,
	input [`V_E_F_Bit-1:0] minusAlpha,
	input [`V_E_F_Bit-1:0] minusBeta,
	input [`V_E_F_Bit-1:0] match,
	input [`V_E_F_Bit-1:0] mismatch,
	output [`V_E_F_Bit-1:0] result
);

wire newLine_w;
wire [1:0] t_w;
wire [`V_E_F_Bit-1:0] v_w, v_alpha_w, f_w;

PE PE_1 (.clk(clk), .rst(rst_n), .enable(enable[0]), .newLineIn(newLineIn), .newLineOut(newLine_w), .s(s[1:0]), .tIn(tIn), 
	.tOut(t_w), .vIn(vIn), .vOut(v_w), .vIn_alpha(vIn_alpha), .vOut_alpha(v_alpha_w), .fIn(fIn), .fOut(f_w), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch));
PE PE_2 (.clk(clk), .rst(rst_n), .enable(enable[1]), .newLineIn(newLine_w), .newLineOut(newLineOut), .s(s[3:2]), .tIn(t_w), 
	.tOut(tOut), .vIn(v_w), .vOut(vOut), .vIn_alpha(v_alpha_w), .vOut_alpha(vOut_alpha), .fIn(f_w), .fOut(fOut), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch));
myMax ans (.a     (v_w), .b     (vOut), .result(result));
endmodule

module PEArray4 (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [3:0] enable,
	input newLineIn,
	output newLineOut,
	input [7:0] s,
	input [1:0] tIn,
	output [1:0] tOut,
	input [`V_E_F_Bit-1:0] vIn,
	output [`V_E_F_Bit-1:0] vOut,
	input [`V_E_F_Bit-1:0] vIn_alpha,
	output [`V_E_F_Bit-1:0] vOut_alpha,
	input [`V_E_F_Bit-1:0] fIn,
	output [`V_E_F_Bit-1:0] fOut,
	input [`V_E_F_Bit-1:0] minusAlpha,
	input [`V_E_F_Bit-1:0] minusBeta,
	input [`V_E_F_Bit-1:0] match,
	input [`V_E_F_Bit-1:0] mismatch,
	output [`V_E_F_Bit-1:0] result
);

wire newLine_w;
wire [1:0] t_w;
wire [`V_E_F_Bit-1:0] v_w, v_alpha_w, f_w, result1, result2;

PEArray2 PE_0 (.clk(clk), .rst_n(rst_n), .enable(enable[1:0]), .newLineIn(newLineIn), .newLineOut(newLine_w), .s(s[3:0]), .tIn(tIn), 
	.tOut(t_w), .vIn(vIn), .vOut(v_w), .vIn_alpha(vIn_alpha), .vOut_alpha(v_alpha_w), .fIn(fIn), .fOut(f_w), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), .result(result1));
PEArray2 PE_1 (.clk(clk), .rst_n(rst_n), .enable(enable[3:2]), .newLineIn(newLine_w), .newLineOut(newLineOut), .s(s[7:4]), .tIn(t_w), 
	.tOut(tOut), .vIn(v_w), .vOut(vOut), .vIn_alpha(v_alpha_w), .vOut_alpha(vOut_alpha), .fIn(f_w), .fOut(fOut), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), .result(result2));
myMax ans (.a     (result1), .b     (result2), .result(result));
endmodule

module PEArray8 (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [7:0] enable,
	input newLineIn,
	output newLineOut,
	input [15:0] s,
	input [1:0] tIn,
	output [1:0] tOut,
	input [`V_E_F_Bit-1:0] vIn,
	output [`V_E_F_Bit-1:0] vOut,
	input [`V_E_F_Bit-1:0] vIn_alpha,
	output [`V_E_F_Bit-1:0] vOut_alpha,
	input [`V_E_F_Bit-1:0] fIn,
	output [`V_E_F_Bit-1:0] fOut,
	input [`V_E_F_Bit-1:0] minusAlpha,
	input [`V_E_F_Bit-1:0] minusBeta,
	input [`V_E_F_Bit-1:0] match,
	input [`V_E_F_Bit-1:0] mismatch,
	output [`V_E_F_Bit-1:0] result
);

wire newLine_w;
wire [1:0] t_w;
wire [`V_E_F_Bit-1:0] v_w, v_alpha_w, f_w, result1, result2;

PEArray4 PE_0 (.clk(clk), .rst_n(rst_n), .enable(enable[3:0]), .newLineIn(newLineIn), .newLineOut(newLine_w), .s(s[7:0]), .tIn(tIn), 
	.tOut(t_w), .vIn(vIn), .vOut(v_w), .vIn_alpha(vIn_alpha), .vOut_alpha(v_alpha_w), .fIn(fIn), .fOut(f_w), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), .result(result1));
PEArray4 PE_1 (.clk(clk), .rst_n(rst_n), .enable(enable[7:4]), .newLineIn(newLine_w), .newLineOut(newLineOut), .s(s[15:8]), .tIn(t_w), 
	.tOut(tOut), .vIn(v_w), .vOut(vOut), .vIn_alpha(v_alpha_w), .vOut_alpha(vOut_alpha), .fIn(f_w), .fOut(fOut), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), .result(result2));
myMax ans (.a     (result1), .b     (result2), .result(result));
endmodule

module PEArray64 (
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
	input [63:0] enable,
	input newLineIn,
	output newLineOut,
	input [127:0] s,
	input [1:0] tIn,
	output [1:0] tOut,
	input [`V_E_F_Bit-1:0] vIn,
	output [`V_E_F_Bit-1:0] vOut,
	input [`V_E_F_Bit-1:0] vIn_alpha,
	output [`V_E_F_Bit-1:0] vOut_alpha,
	input [`V_E_F_Bit-1:0] fIn,
	output [`V_E_F_Bit-1:0] fOut,
	input [`V_E_F_Bit-1:0] minusAlpha,
	input [`V_E_F_Bit-1:0] minusBeta,
	input [`V_E_F_Bit-1:0] match,
	input [`V_E_F_Bit-1:0] mismatch,
	output reg [`V_E_F_Bit-1:0] result
);

wire newLine_w [0:6];
wire [1:0] t_w [0:6];
wire [`V_E_F_Bit-1:0] v_w [0:6];
wire [`V_E_F_Bit-1:0] v_alpha_w [0:6];
wire [`V_E_F_Bit-1:0] f_w [0:6];

reg [`V_E_F_Bit*8 -1:0] result_mid;
wire [`V_E_F_Bit*8 -1:0] n_result_mid;

wire [`V_E_F_Bit-1:0] n_result;
integer idx;

PEArray8 PE_0 (.clk(clk), .rst_n(rst_n), .enable(enable[7:0]), .newLineIn(newLineIn), .newLineOut(newLine_w[0]), .s(s[15:0]), 
	.tIn(tIn), .tOut(t_w[0]), .vIn(vIn), .vOut(v_w[0]), .vIn_alpha(vIn_alpha), .vOut_alpha(v_alpha_w[0]), .fIn(fIn), .fOut(f_w[0]), 
	.minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), 
	.result(n_result_mid[`V_E_F_Bit-1:0]));

PEArray8 PE_1 (.clk(clk), .rst_n(rst_n), .enable(enable[15:8]), .newLineIn(newLine_w[0]), .newLineOut(newLine_w[1]), .s(s[31:16]), 
	.tIn(t_w[0]), .tOut(t_w[1]), .vIn(v_w[0]), .vOut(v_w[1]), .vIn_alpha(v_alpha_w[0]), .vOut_alpha(v_alpha_w[1]), .fIn(f_w[0]), 
	.fOut(f_w[1]), .minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), 
	.result(n_result_mid[`V_E_F_Bit*2-1:`V_E_F_Bit]));

PEArray8 PE_2 (.clk(clk), .rst_n(rst_n), .enable(enable[23:16]), .newLineIn(newLine_w[1]), .newLineOut(newLine_w[2]), .s(s[47:32]), 
	.tIn(t_w[1]), .tOut(t_w[2]), .vIn(v_w[1]), .vOut(v_w[2]), .vIn_alpha(v_alpha_w[1]), .vOut_alpha(v_alpha_w[2]), .fIn(f_w[1]), 
	.fOut(f_w[2]), .minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), 
	.result(n_result_mid[`V_E_F_Bit*3-1:`V_E_F_Bit*2]));

PEArray8 PE_3 (.clk(clk), .rst_n(rst_n), .enable(enable[31:24]), .newLineIn(newLine_w[2]), .newLineOut(newLine_w[3]), .s(s[63:48]), 
	.tIn(t_w[2]), .tOut(t_w[3]), .vIn(v_w[2]), .vOut(v_w[3]), .vIn_alpha(v_alpha_w[2]), .vOut_alpha(v_alpha_w[3]), .fIn(f_w[2]), 
	.fOut(f_w[3]), .minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), 
	.result(n_result_mid[`V_E_F_Bit*4-1:`V_E_F_Bit*3]));

PEArray8 PE_4 (.clk(clk), .rst_n(rst_n), .enable(enable[39:32]), .newLineIn(newLine_w[3]), .newLineOut(newLine_w[4]), .s(s[79:64]), 
	.tIn(t_w[3]), .tOut(t_w[4]), .vIn(v_w[3]), .vOut(v_w[4]), .vIn_alpha(v_alpha_w[3]), .vOut_alpha(v_alpha_w[4]), .fIn(f_w[3]), 
	.fOut(f_w[4]), .minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), 
	.result(n_result_mid[`V_E_F_Bit*5-1:`V_E_F_Bit*4]));

PEArray8 PE_5 (.clk(clk), .rst_n(rst_n), .enable(enable[47:40]), .newLineIn(newLine_w[4]), .newLineOut(newLine_w[5]), .s(s[95:80]), 
	.tIn(t_w[4]), .tOut(t_w[5]), .vIn(v_w[4]), .vOut(v_w[5]), .vIn_alpha(v_alpha_w[4]), .vOut_alpha(v_alpha_w[5]), .fIn(f_w[4]), 
	.fOut(f_w[5]), .minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), 
	.result(n_result_mid[`V_E_F_Bit*6-1:`V_E_F_Bit*5]));

PEArray8 PE_6 (.clk(clk), .rst_n(rst_n), .enable(enable[55:48]), .newLineIn(newLine_w[5]), .newLineOut(newLine_w[6]), .s(s[111:96]), 
	.tIn(t_w[5]), .tOut(t_w[6]), .vIn(v_w[5]), .vOut(v_w[6]), .vIn_alpha(v_alpha_w[5]), .vOut_alpha(v_alpha_w[6]), .fIn(f_w[5]), 
	.fOut(f_w[6]), .minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), 
	.result(n_result_mid[`V_E_F_Bit*7-1:`V_E_F_Bit*6]));

PEArray8 PE_7 (.clk(clk), .rst_n(rst_n), .enable(enable[63:56]), .newLineIn(newLine_w[6]), .newLineOut(newLineOut), .s(s[127:112]), 
	.tIn(t_w[6]), .tOut(tOut), .vIn(v_w[6]), .vOut(vOut), .vIn_alpha(v_alpha_w[6]), .vOut_alpha(vOut_alpha), .fIn(f_w[6]), 
	.fOut(fOut), .minusAlpha(minusAlpha), .minusBeta (minusBeta), .match(match), .mismatch(mismatch), 
	.result(n_result_mid[`V_E_F_Bit*8-1:`V_E_F_Bit*7]));

myMax8 ans (.in    (result_mid), .result(n_result));

always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		 result_mid <= {(`V_E_F_Bit*8){1'b0}};
		 result <= {`V_E_F_Bit{1'b0}};
	end else begin
		 result_mid <= n_result_mid;
		 result <= n_result;
	end
end
endmodule
`endif